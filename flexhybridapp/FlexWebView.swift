//
//  FlexWebView.swift
//  flexhybridapp
//
//  Created by 황견주 on 2020/04/13.
//  Copyright © 2020 황견주. All rights reserved.
//

import Foundation
import WebKit

@IBDesignable
open class FlexWebView : WKWebView {

    public let component: FlexComponent
    
    open override var navigationDelegate: WKNavigationDelegate? {
        didSet {
            component.checkDelegateChange()
        }
    }
    
    required convenience public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    convenience public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        let _component = FlexComponent()
        _component.config = configuration
        self.init(frame: frame, component: _component)
    }
            
    public init (frame: CGRect, component: FlexComponent) {
        self.component = component
        self.component.beforeWebViewInit()
        super.init(frame: frame, configuration: self.component.config)
        self.component.afterWebViewInit(self)
    }
    
    public func evalFlexFunc(_ funcName: String) {
        component.evalJS("$flex.web.\(funcName)()")
    }
    
    public func evalFlexFunc(_ funcName: String, prompt: String) {
        component.evalJS("$flex.web.\(funcName)(\"\(prompt)\")")
    }
    
    public func flexInitInPage() {
        component.flexInitInPage()
    }
    
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
}

open class FlexComponent: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
   
    private var interfaces: [String:(_ arguments: Array<Any?>?) -> String?] = [:]
    private var actions: [String: FlexAction] = [:]
    private var flexWebView: FlexWebView?
    private var jsString: String?
    private var userNavigation: WKNavigationDelegate?
    fileprivate var config: WKWebViewConfiguration = WKWebViewConfiguration()
    
    fileprivate func beforeWebViewInit() {
        for n in FlexString.FLEX_LOGS {
            config.userContentController.add(self, name: n)
        }
        for (n, _) in interfaces {
            config.userContentController.add(self, name: n)
        }
        for (n, _) in actions {
            config.userContentController.add(self, name: n)
        }
    }
    
    fileprivate func afterWebViewInit(_ webView: FlexWebView) {
        flexWebView = webView
        checkDelegateChange()
        do {
            jsString = try String(contentsOfFile: Bundle.main.privateFrameworksPath! + "/FlexHybridApp.framework/FlexHybridiOS.min.js", encoding: .utf8)
            jsString = jsString?.replacingOccurrences(of: "keysfromios", with: "'[\"\(FlexString.FLEX_LOGS.joined(separator: "\",\""))\",\"\( interfaces.keys.joined(separator: "\",\""))\",\"\(actions.keys.joined(separator: "\",\""))\"]'")
        } catch {
            FlexMsg.err(error.localizedDescription)
        }
    }
    
    fileprivate func checkDelegateChange() {
        if !(flexWebView?.navigationDelegate?.isEqual(self) ?? true){
            if flexWebView?.navigationDelegate != nil {
                userNavigation = flexWebView?.navigationDelegate
            }
            flexWebView?.navigationDelegate = self
        }
    }
    
    fileprivate func evalJS(_ js: String) {
        DispatchQueue.main.async {
            self.flexWebView?.evaluateJavaScript(js, completionHandler: { (result, error) in
                if error != nil {
                    FlexMsg.err(error!.localizedDescription)
                }
            })
        }
    }
    
    fileprivate func flexInitInPage() {
        evalJS(jsString!)
    }
    
    public var FlexWebView: FlexWebView? {
        flexWebView
    }
       
    public var configration: WKWebViewConfiguration {
        config
    }
    
    public func addAction(_ name: String, _ action: FlexAction) {
        if name.contains("flex") {
            FlexMsg.err(FlexString.ERROR3)
            return
        }
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
            return
        }
        action.mComponent = self
        actions[name] = action
    }
    
    public func getAction(_ name: String) -> FlexAction? {
        return actions[name]
    }
    
    public func setAction(_ name: String, _ action: FlexAction) {
        if actions[name] == nil {
            FlexMsg.err(FlexString.ERROR2)
            return
        }
        action.mComponent = self
        actions[name] = action
    }
            
    public func addInterface(_ name: String, _ action: @escaping (_ arguments: Array<Any?>?) -> String?) {
        if name.contains("flex") {
            FlexMsg.err(FlexString.ERROR3)
            return
        }
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
            return
        }
        interfaces[name] = action
    }
    
    public func setInterface(_ name: String, _ action: @escaping (_ arguments: Array<Any?>?) -> String?) {
        if interfaces[name] == nil {
            FlexMsg.err(FlexString.ERROR2)
            return
        }
        interfaces[name] = action
    }
                    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let data: [String:Any] = message.body as? Dictionary {
            let mName = message.name
            let fName = data["funName"] as! String
            let argu = data["arguments"] as? Array<Any?>
            if FlexString.FLEX_LOGS.contains(mName) {
                FlexMsg.webLog(mName, data["arguments"])
                self.evalJS("window[\"\(fName)\"]()")
            } else if interfaces[mName] != nil {
                DispatchQueue.global(qos: .background).async {
                    let value: String = self.interfaces[mName]!(argu) ?? ""
                    self.evalJS("window[\"\(fName)\"](\"\(value)\")")
                }
            } else if actions[mName] != nil {
                let action = actions[mName]!
                DispatchQueue.global(qos: .background).async {
                    action.doAction(action, argu)
                    action.funcName = fName
                    action.onReady?()
                }
            }
        }
    }
        
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        userNavigation?.webView?(webView, didCommit: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        userNavigation?.webView?(webView, didFinish: navigation)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        flexInitInPage()
        userNavigation?.webView?(webView, didStartProvisionalNavigation: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        FlexMsg.err(error.localizedDescription)
        userNavigation?.webView?(webView, didFail: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        userNavigation?.webView?(webView, didReceiveServerRedirectForProvisionalNavigation: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        userNavigation?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        (userNavigation?.webView ?? inWeb)(webView, challenge, completionHandler)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        (userNavigation?.webView ?? inWeb)(webView, navigationAction, decisionHandler)
    }
            
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if (navigationResponse.response is HTTPURLResponse) {
            let response = navigationResponse.response as? HTTPURLResponse
            FlexMsg.log(String(format: "response.statusCode: %ld", response?.statusCode ?? 0))
        }
        (userNavigation?.webView ?? inWeb)(webView, navigationResponse, decisionHandler)
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        (userNavigation?.webView ?? inWeb)(webView, navigationAction, preferences, decisionHandler)
    }
    
    private func inWeb(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
    
    private func inWeb(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.url?.absoluteString.hasPrefix("http:"))! || (navigationAction.request.url?.absoluteString.hasPrefix("https:"))! {
            decisionHandler(.allow)
        } else {
            if let aString = URL(string: (navigationAction.request.url?.absoluteString)!) {
                UIApplication.shared.open(aString, options: [:], completionHandler: {success in
                    if success {
                        FlexMsg.log("Opend \(navigationAction.request.url?.absoluteString ?? "")")
                    } else {
                        FlexMsg.log("Failed \(navigationAction.request.url?.absoluteString ?? "")")
                    }
                })
            }
            decisionHandler(.cancel)
        }
    }
    
    private func inWeb(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
        
    @available(iOS 13.0, *)
    private func inWeb(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        decisionHandler(.allow, preferences)
    }
    
}


open class FlexAction {
    
    fileprivate var doAction: (_ this: FlexAction, _ arguments: Array<Any?>?) -> Void
    fileprivate var funcName: String? = nil
    fileprivate var mComponent: FlexComponent? = nil
    
    public var isReady: Bool {
        funcName != nil
    }
    
    public var onReady: (() -> Void)? = nil
    
    public func PromiseReturn(_ response: String?) {
        if isReady {
            mComponent?.evalJS("window[\"\(funcName!)\"](\"\(response ?? "")\")")
            funcName = nil
        }
    }
    
    public init (_ action: @escaping (_ this: FlexAction, _ arguments: Array<Any?>?) -> Void) {
        self.doAction = action
    }
    
    public convenience init (_ action: @escaping (_ this: FlexAction, _ arguments: Array<Any?>?) -> Void, _ readyAction: @escaping (() -> Void)) {
        self.init(action)
        self.onReady = readyAction
    }
    
}
