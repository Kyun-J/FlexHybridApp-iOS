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

class ViewController: UIViewController, WKNavigationDelegate {

    var mWebView: FlexWebView!
    var component = FlexComponent()

    override func viewDidLoad() {
        super.viewDidLoad()

        // add js interface
        component.addInterface("test1") { (arguments) -> Any? in
            // Action work in background...
            if arguments != nil {
                return arguments![0] as! Int + 1
            } else {
                return nil
            }
        }
        component.addInterface("test2") { (arguments) -> Any? in
            // Action work in background...
            
            // call $flex.web function
            // same as $flex.web.help("Help me Flex!") in js
            self.mWebView.evalFlexFunc("help", arguments: "Help me Flex!")
            { (value) -> Void in
                // Retrun from $flex.web.help func
                print("Web Func Retrun ---------------")
                print(value)
                print("-------------------------------")
            }
            return nil
        }
        // add FlexAction
        component.addAction("testAction", FlexAction { (this, arguments) -> Void in
            // Action work in background...
            // do Anything....
            // ....
            var returnValue: [String:Any] = [:]
            var dictionaryValue: [String:Any] = [:]
            dictionaryValue["subkey1"] = ["dictionaryValue",0.12]
            dictionaryValue["subkey2"] = 1000.100
            returnValue["key1"] = "value1"
            returnValue["key2"] = dictionaryValue
            returnValue["key3"] = ["arrayValue1",100]
            // Promise return to Web
            // PromiseReturn can be called at any time.
            this.PromiseReturn(returnValue)
            // or use like this
            // if this.isReady {
            //     this.PromiseReturn("testSuccess!")
            // }
        })

        mWebView = FlexWebView(frame: self.view.frame, component: component)
        mWebView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mWebView)

        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
            let safeArea = self.view.safeAreaLayoutGuide
            mWebView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            mWebView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            mWebView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            mWebView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        } else if #available(iOS 11.0, *) {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        mWebView.navigationDelegate = self
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("suc")
    }

}

