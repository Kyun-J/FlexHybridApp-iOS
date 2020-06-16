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
    
    public var enableScroll: Bool = true
    
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
            FlexMsg.err(FlexString.ERROR3)
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
            FlexMsg.err(FlexString.ERROR3)
        } catch {
            FlexMsg.err(error)
        }
    }
    
}


open class FlexComponent: NSObject, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
   
    private var interfaces: [String:(_ arguments: Array<Any?>) -> Any?] = [:]
    private var actions: [String: (_ action: FlexAction, _ arguments: Array<Any?>) -> Void?] = [:]
    private var options: [String: Any] = [:]
    private var dependencies: [String] = []
    fileprivate var returnFromWeb: [Int:(_ data: Any?) -> Void] = [:]
    private var flexWebView: FlexWebView? = nil
    private var jsString: String? = nil
    private var baseUrl: String? = nil
    private var userNavigation: WKNavigationDelegate? = nil
    private let queue = DispatchQueue(label: "FlexibleHybridApp", qos: DispatchQoS.background, attributes: .concurrent)
    fileprivate var config: WKWebViewConfiguration = WKWebViewConfiguration()
            
    public var BaseUrl: String? {
        baseUrl
    }
    
    public var FlexWebView: FlexWebView? {
        flexWebView
    }
       
    public var configration: WKWebViewConfiguration {
        config
    }
    
    public func setBaseUrl(_ url: String) {
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
        } else if url.prefix(7) != "file://" && url.prefix(7) != "http://" && url.prefix(8) != "https://" {
            FlexMsg.err(FlexString.ERROR6)
        } else {
            baseUrl = url
        }
    }
    
    public func setInterfaceTimeout(_ timeout: Int) {
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
        } else {
            options["timeout"] = timeout
        }
    }
    
    public func setDependency(_ js: String) {
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
        } else {
            dependencies.append(js)
        }
    }
    
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
        flexWebView?.scrollView.delegate = self
        checkDelegateChange()
        do {
            jsString = try String(contentsOfFile: Bundle.main.privateFrameworksPath! + "/FlexHybridApp.framework/FlexHybridiOS.js", encoding: .utf8)
            var keys = ""
            keys.append("[\"")
            keys.append(FlexString.FLEX_DEFINE.joined(separator: "\",\""))
            if(interfaces.count > 0) {
                keys.append("\",\"")
                keys.append(interfaces.keys.joined(separator: "\",\""))
            }
            if(actions.count > 0) {
                keys.append("\",\"")
                keys.append(actions.keys.joined(separator: "\",\""))
            }
            keys.append("\"]")
            jsString = jsString?.replacingOccurrences(of: "keysfromios", with: keys)
            jsString = jsString?.replacingOccurrences(of: "optionsfromios", with: try FlexFunc.convertValue(options))
            jsString = jsString?.replacingOccurrences(of: "deviceinfofromios", with: try FlexFunc.convertValue(DeviceInfo.getInfo()))
        } catch {
            FlexMsg.err(error)
        }
    }
    
    fileprivate func checkDelegateChange() {
        if flexWebView?.navigationDelegate != nil {
            if !(flexWebView?.navigationDelegate!.isEqual(self) ?? false) {
                userNavigation = flexWebView?.navigationDelegate
                flexWebView?.navigationDelegate = self
            }
        } else {
            flexWebView?.navigationDelegate = self
        }
    }
    
    fileprivate func evalJS(_ js: String) {
        DispatchQueue.main.async {
            if self.flexWebView == nil {
                FlexMsg.err(FlexString.ERROR4)
                return
            }
            self.flexWebView?.evaluateJavaScript(js, completionHandler: { (result, error) in
                if error != nil {
                    FlexMsg.err(error!.localizedDescription)
                }
            })
        }
    }
                
    public func setInterface(_ name: String, _ interface: @escaping (_ arguments: Array<Any?>) -> Any?) {
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
        } else if interfaces[name] != nil || actions[name] != nil {
            FlexMsg.err(FlexString.ERROR5)
        } else if name.contains("flex") {
            FlexMsg.err(FlexString.ERROR2)
        } else {
            interfaces[name] = interface
        }
    }
    
    public func setAction(_ name: String, _ action: @escaping (_ action: FlexAction, _ arguments: Array<Any?>) -> Void) {
        if flexWebView != nil {
            FlexMsg.err(FlexString.ERROR1)
        } else if interfaces[name] != nil || actions[name] != nil {
            FlexMsg.err(FlexString.ERROR5)
        } else if name.contains("flex") {
            FlexMsg.err(FlexString.ERROR2)
        } else {
            actions[name] = action
        }
    }
        
    public func evalFlexFunc(_ funcName: String) {
        evalJS("$flex.web.\(funcName)()")
    }
    
    public func evalFlexFunc(_ funcName: String, _ returnAs: @escaping (_ data: Any?) -> Void) {
        let TID = Int.random(in: 1..<10000)
        returnFromWeb[TID] = returnAs
        evalJS("!async function(){try{const e=await $flex.web.\(funcName)();$flex.flexreturn({TID:\(TID),Value:e,Error:!1})}catch(e){$flex.flexreturn({TID:\(TID),Value:e,Error:!0})}}();void 0;")
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any) {
        do {
            evalJS("$flex.web.\(funcName)(\(try FlexFunc.convertValue(sendData)))")
        } catch FlexError.UnuseableTypeCameIn {
            FlexMsg.err(FlexString.ERROR3)
        } catch {
            FlexMsg.err(error)
        }
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any, _ returnAs: @escaping (_ data: Any?) -> Void) {
        do {
            let TID = Int.random(in: 1..<10000)
            returnFromWeb[TID] = returnAs
            evalJS("!async function(){try{const e=await $flex.web.\(funcName)(\(try FlexFunc.convertValue(sendData)));$flex.flexreturn({TID:\(TID),Value:e,Error:!1})}catch(e){$flex.flexreturn({TID:\(TID),Value:e,Error:!0})}}();void 0;")
        } catch FlexError.UnuseableTypeCameIn {
            FlexMsg.err(FlexString.ERROR3)
        } catch {
            FlexMsg.err(error)
        }
    }
    
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = flexWebView
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
                                
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let data: [String:Any] = message.body as? Dictionary {
            let mName = message.name
            let fName = data["funName"] as! String
            if FlexString.FLEX_DEFINE.contains(mName) {
                queue.async {
                    switch(mName) {
                        // WebLogs
                        case FlexString.FLEX_DEFINE[0], FlexString.FLEX_DEFINE[1], FlexString.FLEX_DEFINE[2], FlexString.FLEX_DEFINE[3]:
                            FlexMsg.webLog(mName, data["arguments"])
                            self.evalJS("$flex.flex.\(fName)(true)")
                            break;
                        // $flex.web func return
                        case FlexString.FLEX_DEFINE[4]:
                            let webData = data["arguments"] as! Array<Dictionary<String, Any?>>
                            if let TID = webData[0]["TID"] as? Int {
                                self.returnFromWeb[TID]?(webData[0]["Value"] as Any?)
                                self.returnFromWeb[TID] = nil
                            }
                            self.evalJS("$flex.flex.\(fName)(true)")
                            break;
                        default:
                            break;
                    }
                }
            } else if interfaces[mName] != nil {
                queue.async {
                    let value: Any? = self.interfaces[mName]!(data["arguments"] as! Array<Any?>)
                    if value is FlexReject {
                        let reason = (value as! FlexReject).reason == nil ? "null" : "\"\((value as! FlexReject).reason!)\""
                        self.evalJS("$flex.flex.\(fName)(false, \(reason))")
                    } else if value == nil || value is Void {
                        self.evalJS("$flex.flex.\(fName)(true)")
                    } else {
                        do {
                            self.evalJS("$flex.flex.\(fName)(true, null, \(try FlexFunc.convertValue(value!)))")
                        } catch FlexError.UnuseableTypeCameIn {
                            FlexMsg.err(FlexString.ERROR3)
                        } catch {
                            FlexMsg.err(error)
                        }
                    }
                }
            } else if actions[mName] != nil {
                queue.async {
                    self.actions[mName]!(FlexAction(fName, self), data["arguments"] as! Array<Any?>)
                }
            }
        }
    }
    
    /*
     WKNavigationDelegate
     */
        
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        userNavigation?.webView?(webView, didCommit: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if baseUrl == nil || (baseUrl != nil && webView.url != nil && webView.url!.absoluteString.contains(baseUrl!)) {
            evalJS(jsString!)
            dependencies.forEach { (js) in
                evalJS(js)
            }
        }
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
        if (navigationAction.request.url?.absoluteString.hasPrefix("http:"))! || (navigationAction.request.url?.absoluteString.hasPrefix("https:"))! || (navigationAction.request.url?.absoluteString.hasPrefix("file:"))! {
            decisionHandler(.allow)
        } else {
            if let aString = URL(string: (navigationAction.request.url?.absoluteString)!) {
                UIApplication.shared.open(aString, options: [:], completionHandler: {success in
                    if success {
                        FlexMsg.log("Opend \(navigationAction.request.url?.absoluteString ?? "")")
                    } else {
                        FlexMsg.err("Failed \(navigationAction.request.url?.absoluteString ?? "")")
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
        if (navigationAction.request.url?.absoluteString.hasPrefix("http:"))! || (navigationAction.request.url?.absoluteString.hasPrefix("https:"))! || (navigationAction.request.url?.absoluteString.hasPrefix("file:"))! {
            decisionHandler(.allow, preferences)
        } else {
            if let aString = URL(string: (navigationAction.request.url?.absoluteString)!) {
                UIApplication.shared.open(aString, options: [:], completionHandler: {success in
                    if success {
                        FlexMsg.log("Opend \(navigationAction.request.url?.absoluteString ?? "")")
                    } else {
                        FlexMsg.err("Failed \(navigationAction.request.url?.absoluteString ?? "")")
                    }
                })
            }
            decisionHandler(.cancel, preferences)
        }
    }
    
    /*
    UIScrollViewDelegate
    */
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !flexWebView!.enableScroll {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
}


public class FlexAction {
    
    private let funcName: String
    private let mComponent: FlexComponent
    private var isCall = false
    
    fileprivate init (_ name: String, _ component: FlexComponent) {
        funcName = name
        mComponent = component
    }
    
    private func pRetrun(_ response: Any?) {
        if isCall {
            FlexMsg.err(FlexString.ERROR7)
            return
        }
        isCall = true
        if response is FlexReject {
            let reason = (response as! FlexReject).reason == nil ? "null" : "\"\((response as! FlexReject).reason!)\""
            mComponent.evalJS("$flex.flex.\(funcName)(false, \(reason))")
        } else if response == nil || response is Void {
            mComponent.evalJS("$flex.flex.\(funcName)(true)")
        } else {
            do {
                mComponent.evalJS("$flex.flex.\(funcName)(true, null, \(try FlexFunc.convertValue(response!)))")
            } catch FlexError.UnuseableTypeCameIn {
                FlexMsg.err(FlexString.ERROR3)
            } catch {
                FlexMsg.err(error)
            }
        }
    }
    
    public func promiseReturn(_ response: Void) {
        pRetrun(response)
    }
       
    public func promiseReturn(_ response: String) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: Int) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: Float) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: Double) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: Character) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: Bool) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: Array<Any?>) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: Dictionary<String,Any?>) {
        pRetrun(response)
    }
    
    public func promiseReturn(_ response: FlexReject) {
        pRetrun(response)
    }
    
    public func resolveVoid() {
        if isCall {
            FlexMsg.err(FlexString.ERROR7)
            return
        }
        isCall = true
        mComponent.evalJS("$flex.flex.\(funcName)(true)")
    }
    
    public func reject(reason: FlexReject) {
        if isCall {
            FlexMsg.err(FlexString.ERROR7)
            return
        }
        isCall = true
        let rejectReson = reason.reason == nil ? "null" : "\"\(reason.reason!)\""
        mComponent.evalJS("$flex.flex.\(funcName)(false, \(rejectReson))")
    }
    
    public func reject(reason: String) {
        if isCall {
            FlexMsg.err(FlexString.ERROR7)
            return
        }
        isCall = true
        mComponent.evalJS("$flex.flex.\(funcName)(false, \"\(reason)\")")
    }
    
    public func reject() {
        if isCall {
            FlexMsg.err(FlexString.ERROR7)
            return
        }
        isCall = true
        mComponent.evalJS("$flex.flex.\(funcName)(false)")
    }
    
}

public class FlexReject {
    let reason: String?
    public init(_ Reason: String) {
        reason = Reason
    }
    public init() {
        reason = nil
    }
}
