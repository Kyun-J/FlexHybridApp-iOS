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
        super.init(coder: coder)
        component.config = configuration
        component.afterWebViewInit(self)
    }
        
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        component = FlexComponent()
        component.config = configuration
        super.init(frame: frame, configuration: component.config)
        component.afterWebViewInit(self)
    }
            
    public init (frame: CGRect, component: FlexComponent) {
        self.component = component
        super.init(frame: frame, configuration: self.component.config)
        self.component.afterWebViewInit(self)
    }
    
    
    public func evalFlexFunc(_ funcName: String) {
        component.evalFlexFunc(funcName)
    }
    
    public func evalFlexFunc(_ funcName: String, _ returnAs: @escaping (_ data: FlexData) -> Void) {
        component.evalFlexFunc(funcName, returnAs)
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any) {
        component.evalFlexFunc(funcName, sendData: sendData)
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any, _ returnAs: @escaping (_ data: FlexData) -> Void) {
        component.evalFlexFunc(funcName, sendData: sendData, returnAs)
    }
    
}


open class FlexComponent: NSObject, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
   
    private var interfaces: [String:(_ arguments: Array<FlexData>) throws -> Any?] = [:]
    private var actions: [String: (_ action: FlexAction, _ arguments: Array<FlexData>) -> Void] = [:]
    private var options: [String: Any] = [:]
    private var dependencies: [String] = []
    private var returnFromWeb: [Int:(_ data: FlexData) -> Void] = [:]
    private var flexWebView: FlexWebView? = nil
    private var jsString: String? = nil
    private var baseUrl: String? = nil
    private var userNavigation: WKNavigationDelegate? = nil
    private let queue = DispatchQueue(label: "FlexibleHybridApp", qos: DispatchQoS.background, attributes: .concurrent)
    internal var config: WKWebViewConfiguration = WKWebViewConfiguration()
    private var beforeFlexLoadEvalList : Array<BeforeFlexEval> = []
    private var isFlexLoad = false
    private var isFirstPageLoad = false
            
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
        if isFirstPageLoad {
            FlexMsg.err(FlexString.ERROR1)
        } else if url.prefix(7) != "file://" && url.prefix(7) != "http://" && url.prefix(8) != "https://" {
            FlexMsg.err(FlexString.ERROR6)
        } else {
            baseUrl = url
        }
    }
    
    public func setInterfaceTimeout(_ timeout: Int) {
        if isFirstPageLoad {
            FlexMsg.err(FlexString.ERROR1)
        } else {
            options["timeout"] = timeout
        }
    }
    
    public func setFlexOnloadWait(_ time: Int) {
        if isFirstPageLoad {
            FlexMsg.err(FlexString.ERROR1)
        } else {
            options["flexLoadWait"] = time
        }
    }
    
    public func setDependency(_ js: String) {
        if isFirstPageLoad {
            FlexMsg.err(FlexString.ERROR1)
        } else {
            dependencies.append(js)
        }
    }
    
    public func setAllowsUrlAccessInFile(_ allow: Bool) {
        config.preferences.setValue(allow, forKey: "allowFileAccessFromFileURLs")
        config.setValue(allow, forKey: "allowUniversalAccessFromFileURLs")
    }
    
    private func flexInterfaceInit() {
        if !isFirstPageLoad {
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
                for n in FlexString.FLEX_DEFINE {
                    config.userContentController.add(self, name: n)
                }
                for (n, _) in interfaces {
                    config.userContentController.add(self, name: n)
                }
                for (n, _) in actions {
                    config.userContentController.add(self, name: n)
                }
                isFirstPageLoad = true
            } catch {
                FlexMsg.err(error)
            }
        }
    }
    
    internal func afterWebViewInit(_ webView: FlexWebView) {
        flexWebView = webView
        flexWebView?.scrollView.delegate = self
        checkDelegateChange()
    }
    
    internal func checkDelegateChange() {
        if flexWebView?.navigationDelegate != nil {
            if !(flexWebView?.navigationDelegate!.isEqual(self) ?? false) {
                userNavigation = flexWebView?.navigationDelegate
                flexWebView?.navigationDelegate = self
            }
        } else {
            flexWebView?.navigationDelegate = self
        }
    }
    
    public func evalJS(_ js: String) {
        DispatchQueue.main.async {
            if self.flexWebView == nil {
                FlexMsg.err(FlexString.ERROR4)
                return
            }
            self.flexWebView?.evaluateJavaScript(js + ";void 0;", completionHandler: { (result, error) in
                if error != nil {
                    FlexMsg.err(error!.localizedDescription)
                }
            })
        }
    }
                
    private func setInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Any?) {
        if isFirstPageLoad {
            FlexMsg.err(FlexString.ERROR1)
        } else if interfaces[name] != nil || actions[name] != nil {
            FlexMsg.err(FlexString.ERROR5)
        } else if name.contains("flex") {
            FlexMsg.err(FlexString.ERROR2)
        } else {
            interfaces[name] = interface
        }
    }
    
    public func voidInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Void) {
        setInterface(name, interface)
    }
    
    public func intInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Int) {
        setInterface(name, interface)
    }
    
    public func doubleInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Double) {
        setInterface(name, interface)
    }
    
    public func floatInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Float) {
        setInterface(name, interface)
    }
    
    public func boolInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Bool) {
        setInterface(name, interface)
    }
    
    public func stringInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> String) {
        setInterface(name, interface)
    }
    
    public func arrayInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Array<Any?>) {
        setInterface(name, interface)
    }
    
    public func dictionaryInterface(_ name: String, _ interface: @escaping (_ arguments: Array<FlexData>) throws -> Dictionary<String,Any?>) {
        setInterface(name, interface)
    }
    
    public func setAction(_ name: String, _ action: @escaping (_ action: FlexAction, _ arguments: Array<FlexData>) -> Void) {
        if isFirstPageLoad {
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
        if(!isFlexLoad) {
            beforeFlexLoadEvalList.append(BeforeFlexEval(funcName))
        } else {
            evalJS("$flex.web.\(funcName)()")
        }
    }
    
    public func evalFlexFunc(_ funcName: String, _ returnAs: @escaping (_ data: FlexData) -> Void) {
        if(!isFlexLoad) {
            beforeFlexLoadEvalList.append(BeforeFlexEval(funcName, returnAs))
        } else {
            let TID = Int.random(in: 1..<10000)
            returnFromWeb[TID] = returnAs
            evalJS("!async function(){try{const e=await $flex.web.\(funcName)();$flex.flexreturn({TID:\(TID),Value:e,Error:!1})}catch(e){$flex.flexreturn({TID:\(TID),Value:e,Error:!0})}}();")
        }
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any) {
        if(!isFlexLoad) {
            beforeFlexLoadEvalList.append(BeforeFlexEval(funcName, sendData))
        } else {
            do {
                evalJS("$flex.web.\(funcName)(\(try FlexFunc.convertValue(sendData)))")
            } catch FlexError.UnuseableTypeCameIn {
                FlexMsg.err(FlexString.ERROR3)
            } catch {
                FlexMsg.err(error)
            }
        }
    }
    
    public func evalFlexFunc(_ funcName: String, sendData: Any, _ returnAs: @escaping (_ data: FlexData) -> Void) {
        if(!isFlexLoad) {
            beforeFlexLoadEvalList.append(BeforeFlexEval(funcName, sendData, returnAs))
        } else {
            do {
                let TID = Int.random(in: 1..<10000)
                returnFromWeb[TID] = returnAs
                evalJS("!async function(){try{const e=await $flex.web.\(funcName)(\(try FlexFunc.convertValue(sendData)));$flex.flexreturn({TID:\(TID),Value:e,Error:!1})}catch(e){$flex.flexreturn({TID:\(TID),Value:e,Error:!0})}}();")
            } catch FlexError.UnuseableTypeCameIn {
                FlexMsg.err(FlexString.ERROR3)
            } catch {
                FlexMsg.err(error)
            }
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
                // framework inner interface
                queue.async {
                    switch(mName) {
                        // WebLogs
                        case FlexString.FLEX_DEFINE[0], FlexString.FLEX_DEFINE[1], FlexString.FLEX_DEFINE[2], FlexString.FLEX_DEFINE[3]:
                            FlexMsg.webLog(mName, data["arguments"])
                            self.evalJS("$flex.flex.\(fName)(true)")
                        // $flex.web func return
                        case FlexString.FLEX_DEFINE[4]:
                            let webData = data["arguments"] as! Array<Dictionary<String, Any?>>
                            let iData = webData[0]
                            let TID = iData["TID"] as! Int
                            let value = iData["Value"] as Any?
                            let error = iData["Error"] as! Bool
                            if(error) {
                                var errMsg: String = ""
                                if(value == nil) { errMsg = "null" }
                                else { errMsg = value as! String }
                                self.returnFromWeb[TID]?(FlexFunc.anyToFlexData(BrowserException(errMsg)))
                            } else {
                                self.returnFromWeb[TID]?(FlexFunc.anyToFlexData(value))
                            }
                            self.returnFromWeb[TID] = nil
                            self.evalJS("$flex.flex.\(fName)(true)")
                        case FlexString.FLEX_DEFINE[5]:
                            if self.isFlexLoad {
                                self.evalJS("$flex.flex.\(fName)(true)")
                                break
                            }
                            self.isFlexLoad = true
                            self.beforeFlexLoadEvalList.forEach { item in
                                if(item.sendData != nil && item.response != nil) {
                                    self.evalFlexFunc(item.name, sendData: item.sendData!, item.response!)
                                } else if(item.sendData != nil && item.response == nil) {
                                    self.evalFlexFunc(item.name, sendData: item.sendData!)
                                } else if(item.sendData == nil && item.response != nil) {
                                    self.evalFlexFunc(item.name, item.response!)
                                } else {
                                    self.evalFlexFunc(item.name)
                                }
                            }
                            self.beforeFlexLoadEvalList.removeAll()
                            self.evalJS("$flex.flex.\(fName)(true)")
                        default:
                            break
                    }
                }
            } else if interfaces[mName] != nil {
                // user interface
                queue.async {
                    do {
                        let value: Any? = try self.interfaces[mName]!(FlexFunc.arrayToFlexData(data["arguments"] as? Array<Any?>))
                        if value is BrowserException {
                            let reason = (value as! BrowserException).reason == nil ? "null" : "\"\((value as! BrowserException).reason!)\""
                            self.evalJS("$flex.flex.\(fName)(false, \(reason))")
                        } else if value == nil || value is Void {
                            self.evalJS("$flex.flex.\(fName)(true)")
                        } else {
                            self.evalJS("$flex.flex.\(fName)(true, null, \(try FlexFunc.convertValue(value!)))")
                        }
                    } catch FlexError.UnuseableTypeCameIn {
                        FlexMsg.err(FlexString.ERROR3)
                        self.evalJS("$flex.flex.\(fName)(false, \"\(FlexString.ERROR3)\")")
                    } catch {
                        FlexMsg.err(error)
                        self.evalJS("$flex.flex.\(fName)(false, \"\(error.localizedDescription)\")")
                    }
                }
            } else if actions[mName] != nil {
                // user action interface
                queue.async {
                    self.actions[mName]!(FlexAction(fName, self), FlexFunc.arrayToFlexData(data["arguments"] as? Array<Any?>))
                }
            }
            
        }
    }
    
    /*
     WKNavigationDelegate
     */
        
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if baseUrl == nil || (baseUrl != nil && webView.url != nil && webView.url!.absoluteString.contains(baseUrl!)) {
            isFlexLoad = false
            flexInterfaceInit()
            evalJS(jsString!)
            dependencies.forEach { (js) in
                evalJS(js)
            }
            evalJS("window.$FCheck = true;")
        }
        userNavigation?.webView?(webView, didCommit: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if baseUrl == nil || (baseUrl != nil && webView.url != nil && webView.url!.absoluteString.contains(baseUrl!)) {
            evalJS("if(typeof window.$flex === 'undefined') { \(jsString!) }")
            evalJS("const evalFrames=e=>{for(let o=0;o<e.frames.length;o++){if(void 0===e.frames[o].$flex){Object.defineProperty(e.frames[o],\"$flex\",{value:window.$flex,writable:!1,enumerable:!0});let n=void 0;\"function\"==typeof e.frames[o].onFlexLoad&&(n=e.frames[o].onFlexLoad),Object.defineProperty(e.frames[o],\"onFlexLoad\",{set:function(e){window.onFlexLoad=e},get:function(){return window._onFlexLoad}}),\"function\"==typeof n&&(e.frames[o].onFlexLoad=n)}evalFrames(e.frames[o])}};evalFrames(window);")
            dependencies.forEach { (js) in
                evalJS("if(typeof window.$FCheck === 'undefined') { \(js) }")
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
                if UIApplication.shared.openURL(aString) {
                    FlexMsg.log("Opend \(navigationAction.request.url?.absoluteString ?? "")")
                } else {
                    FlexMsg.err("Failed \(navigationAction.request.url?.absoluteString ?? "")")
                }
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
