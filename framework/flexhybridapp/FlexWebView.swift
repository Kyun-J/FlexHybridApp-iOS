//
//  FlexWebView.swift
//  flexhybridapp
//
//  Created by dvkyun on 2020/04/13.
//  Copyright © 2020 dvkyun. All rights reserved.
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
    
    required public init?(coder: NSCoder) {
        component = FlexComponent()
        component.beforeWebViewInit()
        super.init(coder: coder)
        component.afterWebViewInit(self)
    }
        
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        component = FlexComponent()
        component.config = configuration
        component.beforeWebViewInit()
        super.init(frame: frame, configuration: component.config)
        component.afterWebViewInit(self)
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
    
    public func evalFlexFunc(_ funcName: String, _ returnAs: @escaping (_ data: Any?) -> Void) {
        let TID = Int.random(in: 1..<10000)
        component.returnFromWeb[TID] = returnAs
        component.evalJS("(async function() { const V = await $flex.web.\(funcName)(); $flex.flexreturn({ TID: \(TID), Value: V }); })(); void 0")
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any) {
        do {
            component.evalJS("$flex.web.\(funcName)(\(try FlexFunc.convertValue(sendData)))")
        } catch FlexError.UnuseableTypeCameIn {
            FlexMsg.err(FlexString.ERRPR5)
        } catch {
            FlexMsg.err(error)
        }
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any, _ returnAs: @escaping (_ data: Any?) -> Void) {
        do {
            let TID = Int.random(in: 1..<10000)
            component.returnFromWeb[TID] = returnAs
            component.evalJS("(async function() { const V = await $flex.web.\(funcName)(\(try FlexFunc.convertValue(sendData))); $flex.flexreturn({ TID: \(TID), Value: V }); })(); void 0")
        } catch FlexError.UnuseableTypeCameIn {
            FlexMsg.err(FlexString.ERRPR5)
        } catch {
            FlexMsg.err(error)
        }
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

open class FlexComponent: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
   
    private var interfaces: [String:(_ arguments: Array<Any?>?) -> Any?] = [:]
    private var actions: [String: FlexAction] = [:]
    fileprivate var returnFromWeb: [Int:(_ data: Any?) -> Void] = [:]
    private var flexWebView: FlexWebView?
    private var jsString: String?
    private var userNavigation: WKNavigationDelegate?
    fileprivate var config: WKWebViewConfiguration = WKWebViewConfiguration()
    
    fileprivate func beforeWebViewInit() {
        for n in FlexString.FLEX_DEFINE {
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
            jsString = jsString?.replacingOccurrences(of: "keysfromios", with: "'[\"\(FlexString.FLEX_DEFINE.joined(separator: "\",\""))\",\"\( interfaces.keys.joined(separator: "\",\""))\",\"\(actions.keys.joined(separator: "\",\""))\"]'")
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
            if self.flexWebView == nil {
                FlexMsg.err(FlexString.ERRPR6)
                return
            }
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
    
    public func setAction(_ name: String, _ action: FlexAction) {
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
            return
        }
        if actions[name] != nil {
            
            return
        }
        if name.contains("flex") {
            FlexMsg.err(FlexString.ERROR3)
            return
        }
        actions[name] = action
    }
    
    public func getAction(_ name: String) -> FlexAction? {
        return actions[name]
    }
            
    public func setInterface(_ name: String, _ action: @escaping (_ arguments: Array<Any?>?) -> Any?) {
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
            return
        }
        if interfaces[name] != nil {
            
            return
        }
        if name.contains("flex") {
            FlexMsg.err(FlexString.ERROR3)
            return
        }
        interfaces[name] = action
    }
                    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let data: [String:Any] = message.body as? Dictionary {
            let mName = message.name
            let fName = data["funName"] as! String
            if FlexString.FLEX_DEFINE.contains(mName) {
                switch(mName) {
                    // WebLogs
                    case FlexString.FLEX_DEFINE[0], FlexString.FLEX_DEFINE[1], FlexString.FLEX_DEFINE[2], FlexString.FLEX_DEFINE[3]:
                        FlexMsg.webLog(mName, data["arguments"])
                        evalJS("window.\(fName)()")
                        break;
                    // $flex.web func return
                    case FlexString.FLEX_DEFINE[4]:
                        let webData = data["arguments"] as! Array<Dictionary<String, Any>>
                        if let TID = webData[0]["TID"] as? Int {
                            returnFromWeb[TID]?(webData[0]["Value"])
                            returnFromWeb[TID] = nil
                        }
                        evalJS("window.\(fName)()")
                        break;
                    default:
                        break;
                }
            } else if interfaces[mName] != nil {
                DispatchQueue.global(qos: .background).async {
                    let value: Any? = self.interfaces[mName]!(data["arguments"] as? Array<Any?>)
                    if value == nil {
                        self.evalJS("window.\(fName)()")
                    } else {
                        do {
                            self.evalJS("window.\(fName)(\(try FlexFunc.convertValue(value!)))")
                        } catch FlexError.UnuseableTypeCameIn {
                            FlexMsg.err(FlexString.ERRPR5)
                        } catch {
                            FlexMsg.err(error)
                        }
                    }
                }
            } else if actions[mName] != nil {
                let action = actions[mName]!
                action.mComponent = self
                DispatchQueue.global(qos: .background).async {
                    action.doAction(action, data["arguments"] as? Array<Any?>)
                    action.funcName = fName
                }
            }
        }
    }
        
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        userNavigation?.webView?(webView, didCommit: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        flexInitInPage()
        userNavigation?.webView?(webView, didFinish: navigation)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
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
    fileprivate var funcName: String? = nil {
        didSet {
            onReady?()
        }
    }
    fileprivate var mComponent: FlexComponent? = nil
    private var onReady: (() -> Void)? = nil
    
    private func action(_ response: Any?) {
        if response == nil {
            mComponent?.evalJS("window.\(funcName!)()")
        } else {
            do {
                mComponent?.evalJS("window.\(funcName!)(\(try FlexFunc.convertValue(response!)))")
            } catch FlexError.UnuseableTypeCameIn {
                FlexMsg.err(FlexString.ERRPR5)
            } catch {
                FlexMsg.err(error)
            }
        }
        funcName = nil
        mComponent = nil
    }
        
    public func PromiseReturn(_ response: Any?) {
        if funcName != nil {
            action(response)
        } else {
            onReady = { () -> Void in
                self.onReady = nil
                self.action(response)
            }
        }
    }
    
    public init (_ action: @escaping (_ this: FlexAction, _ arguments: Array<Any?>?) -> Void) {
        self.doAction = action
    }
    
}
