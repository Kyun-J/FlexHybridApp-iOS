//
//  FlexError.swift
//  flexhybridapp
//
//  Created by 황견주 on 2020/04/24.
//  Copyright © 2020 황견주. All rights reserved.
//

import Foundation

enum FlexError: Error {
    case FlexWebViewAlreadyInit
}

struct FlexString {
    static let ERROR1 = "After FlextWebView is initialized, you cannot add interfaces"
    static let ERROR2 = "You can only change interfaces that have already been added."
    static let ERROR3 = "You cannot set the interface name with flex";
    
    static let FLEX_LOGS = ["flexlog","flexerror","flexdebug","flexinfo"]
}

struct FlexMsg {
    static func log(_ msg: String) {
        print("Log in FlextWebView  ——————————————")
        print(msg)
        print("———————————————————————————————————")
    }
    static func err(_ err: String) {
        print("Error in FlextWebView  ————————————")
        print(err)
        print("———————————————————————————————————")
    }
    static func err(_ err: Error) {
        print("Error in FlextWebView  ————————————")
        print(err.localizedDescription)
        print("———————————————————————————————————")
    }
    static func webLog(_ type: String, _ msg: Any?) {
        var t = ""
        switch type {
        case FlexString.FLEX_LOGS[0]:
            t = "LOG"
        case FlexString.FLEX_LOGS[1]:
            t = "ERROR"
        case FlexString.FLEX_LOGS[2]:
            t = "DEBUG"
        case FlexString.FLEX_LOGS[3]:
            t = "INFO"
        default:
            t = type
        }
        print("\(t) on FlexWebView --- \(msg ?? "nil")")
    }
}
