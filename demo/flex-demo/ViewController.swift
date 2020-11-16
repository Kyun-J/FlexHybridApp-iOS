//
//  ViewController.swift
//  FlexHybridApp-demo
//
//  Created by dvkyun on 2020/04/24.
//  Copyright © 2020 dvkyun. All rights reserved.
//

import UIKit
import WebKit
import FlexHybridApp

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var mWebView: FlexWebView!
    var component = FlexComponent()
    
    enum TestError: Error {
        case test
    }
                
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // add js interface
        component.intInterface("test1")
        { (arguments) -> Int in
            // code works in background...
            return arguments[0].asInt()! + 1
        }
        component.voidInterface("test2")
        { (arguments) -> Void in
            // code works in background...
            
            // call $flex.web function
            // same as $flex.web.help("Help me Flex!") in js
            self.mWebView.evalFlexFunc("help", sendData: "Help me Flex!")
            { (value) -> Void in
                // Retrun from $flex.web.help func
                let arr = value.asArray()!
                let data1: String = arr[0].reified()!
                let data2: String? = arr[1].reified()
                print("Web Func Retrun ---------------")
                print("\(data1) \(data2 ?? "this is null")")
                print("-------------------------------")
            }
        }
        
        component.arrayInterface("testReceive")
        { (arguments) -> Array<Any?> in
            let data = arguments[0].asDictionary()!
            let dicData: [String:FlexData] = data["d2"]!.reified()!
            print("\(data["d1"]!.asInt()!) \(dicData)")
            var returnValue: [Any?] = []
            returnValue.append(10)
            returnValue.append(24123.54235234)
            returnValue.append([])
            returnValue.append(false)
            returnValue.append("test value")
            return returnValue
        }
                
        // add FlexAction
        component.setAction("testAction")
        { (action, arguments) -> Void in
            action.onFinished = {
                print("action finished!")
            }
            // code works in background...
            var returnValue: [String:Any] = [:]
            var dictionaryValue: [String:Any] = [:]
            dictionaryValue["subkey1"] = ["dictionaryValue",0.12]
            dictionaryValue["subkey2"] = 1000.100
            returnValue["key1"] = "value1"
            returnValue["key2"] = dictionaryValue
            returnValue["key3"] = ["arrayValue1",nil]
            // Promise return to Web
            // PromiseReturn can be called at any time.
            action.promiseReturn(returnValue)
        }
        
        // test JS Reject
        component.dictionaryInterface("testReject1")
        { arguemnts -> Dictionary<String,Any?> in
            throw TestError.test
        }
        
        component.setAction("testReject2")
        { (action, arguemnts) -> Void in
            action.reject()
        }
        
        component.evalFlexFunc("directTest") { value -> Void in
            print("dirct test suc!!")
        }
        
        // setBaseUrl
        component.setBaseUrl("file://")
        component.setInterfaceTimeout(0)
        component.setFlexOnloadWait(0)
        component.setAllowsUrlAccessInFile(true)
        
        mWebView = FlexWebView(frame: self.view.frame, component: component)
        
        mWebView.translatesAutoresizingMaskIntoConstraints = false
        mWebView.scrollView.bounces = false
        mWebView.scrollView.isScrollEnabled = true
        mWebView.enableScroll = true
        
        view.addSubview(mWebView)
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
            let safeArea = self.view.safeAreaLayoutGuide
            mWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        else if #available(iOS 11.0, *) {
            view.backgroundColor = UIColor.white
            let safeArea = self.view.safeAreaLayoutGuide
            mWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        } else {
            view.backgroundColor = UIColor.white
            mWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        }
        mWebView.load(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "html")!)))
        
        // add user-custom contentController
        component.configration.userContentController.add(self, name: "userCC")
    }

    override func viewWillAppear(_ animated: Bool) {
        // set user-custom navigationDelegate
        mWebView.navigationDelegate = self
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("user navigationDelegate")
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        print("user decidePolicyFor")
        decisionHandler(.allow, preferences)
    }
    
        
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("userCC")
    }

}

