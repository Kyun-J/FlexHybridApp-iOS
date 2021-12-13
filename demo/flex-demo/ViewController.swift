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
        
    let testReceive = FlexClosure.interface { (arguments) in
        let data = arguments[0].asDictionary()!
        let dicData: [String:FlexData] = data["d2"]!.reified()!
        print("\(data["d1"]!.asInt()!) \(String(describing: dicData["data"]!.toString()))")
        var returnValue: [Any?] = []
        returnValue.append(10)
        returnValue.append(24123.54235234)
        returnValue.append([])
        returnValue.append(false)
        returnValue.append("test value")
        return returnValue
    }
    
    let testAction = FlexClosure.action { (action, arguments) in
        action.onFinished = {
            print("action finished!")
        }
        // code works in background...
        var returnValue: [String:Any] = [:]
        var dictionaryValue: [String:Any] = [:]
        dictionaryValue["subkey1"] = ["dictionaryValue",0.12]
        dictionaryValue["subkey2"] = 1000.100
        returnValue["key1"] = "value1\ntest"
        returnValue["key2"] = dictionaryValue
        returnValue["key3"] = ["arrayValue1",nil]
        returnValue["key4"] = true
        // Promise return to Web
        // PromiseReturn can be called at any time.
        action.promiseReturn(returnValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        component.addEventListener { (type, funcName, url, msg) in
            var typeTxt = "";
            if type == FlexEvent.SUCCESS {
                typeTxt = "SUCCESS"
            } else if type == FlexEvent.TIMEOUT {
                typeTxt = "TIMEOUT"
            } else if type == FlexEvent.EXCEPTION {
                typeTxt = "EXCEPTION"
            } else if type == FlexEvent.INIT {
                typeTxt = "INIT"
            }
            print("\nEVENT --------- \(typeTxt)")
            print("FUNCTUIN ------ $flex.\(funcName)")
//            print("URL ----------- \(url)")
            print("MSG ----------- \(msg ?? "nil")\n")
        }
                                
        // add js interface
        component.setInterface("test1")
        { (arguments) in
            // code works in background...
            return arguments[0].asInt()! + 1
        }
        component.setInterface("test2")
        { (arguments) in
            // code works in background...
            
            // call $flex.web function
            // same as $flex.web.help("Help me Flex!") in js
            self.mWebView.evalFlexFunc("help", sendData: "Help me Flex!")
            { (value) in
                // Retrun from $flex.web.help func
                let arr = value.asArray()!
                let data1: String = arr[0].reified()!
                let data2: Bool = arr[1].reified()!
                print("Web Func Retrun ---------------")
                print("\(data1) \(data2)")
                print("-------------------------------")
            }
        }
        
        component.setInterface("testReceive", nil, testReceive)
                
        // add FlexAction
        component.setAction("testAction", nil, testAction)
        
        // test JS Reject
        component.setInterface("testReject1")
        { arguemnts in
            throw TestError.test
        }
        
        component.setAction("testReject2")
        { (action, arguemnts) in
            action.reject()
        }
        
        component.setAction("modelTest1")
        { (action, model: TestModel1?) in
            print("Model Test 1 ------------")
            print("\(String(describing: model?.string)) \(String(describing: model?.integer))")
            print("-------------------------")
            action.promiseReturn()
        }
        
        component.setInterface("modelTest2")
        { (model: TestModel2?) -> Void in
            print("Model Test 2 ------------")
            print("\(String(describing: model?.array)) \(String(describing: model?.dic))")
            print("\(String(describing: model?.model.bool))")
            print("-------------------------")
        }
        
//        component.setInterface("modelTest3")
//        { arguments -> TestModel2 in
//            return TestModel2(array: ["test1"], dic: ["test2": "test3"], model: TestModel3(bool: true))
//        }
        
        component.setAction("modelTest3")
        { (action, arguments) in
            action.promiseReturn(TestModel2(array: ["test1"], dic: ["test2": "test3"], model: TestModel3(bool: true)))
        }
        
        component.evalFlexFunc("directTest") { value -> Void in
            print("dirct test suc!!")
        }
        
        // setBaseUrl
        component.setBaseUrl("file://")
        component.setInterfaceTimeout(0)
//        component.setFlexOnloadWait(0)
        component.setAllowsUrlAccessInFile(true)
        component.setShowWebViewConsole(true)
        
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
        component.configuration.userContentController.add(self, name: "userCC")
    }

    override func viewWillAppear(_ animated: Bool) {
        // set user-custom navigationDelegate
        mWebView.navigationDelegate = self
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("--------- user navigationDelegate")
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        print("--------- user decidePolicyFor")
        decisionHandler(.allow, preferences)
    }
    
        
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("-------- userContentController")
    }

}

