//
//  FlexUtil.swift
//  flexhybridapp
//
//  Created by dvkyun on 2020/04/24.
//  Copyright © 2020 dvkyun. All rights reserved.
//

import Foundation

enum FlexError: Error {
    case FlexWebViewAlreadyInit
    case UnuseableTypeCameIn
}

struct FlexString {
    static let ERROR1 = "After FlextWebView is initialized, you cannot add interfaces"
    static let ERROR2 = "You can only change interfaces that have already been added."
    static let ERROR3 = "You cannot set the interface or FlexAction name with flex";
    static let ERROR4 = "You can only change FlexAction that have already been added."
    static let ERRPR5 = ""
    
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

struct FlexFunc {
    static func convertValue(_ value: Any) throws -> String {
        if value is Int || value is Double || value is Float || value is Bool {
            return "\(value)"
        } else if value is String || value is Character {
            return "\"\(value)\""
        } else if value is Array<Any> {
            let _vArray = value as! Array<Any>
            var _vString = "["
            for e in _vArray {
                if e is Int || e is Double || e is Float || e is Bool {
                    _vString.append("\(e),")
                } else if e is String || e is Character {
                    _vString.append("\"\(e)\",")
                } else if e is Array<Any> || e is Dictionary<String,Any> {
                    _vString.append("\(try convertValue(e)),")
                }
            }
            _vString.append("]")
            return _vString
        } else if value is Dictionary<String,Any> {
            let _vArray = value as! Dictionary<String,Any>
            var _vString = "{"
            for (_name, e) in _vArray {
                if e is Int || e is Double || e is Float || e is Bool {
                    _vString.append("\(_name):\(e),")
                } else if e is String || e is Character {
                    _vString.append("\(_name):\"\(e)\",")
                } else if e is Array<Any> || e is Dictionary<String,Any> {
                    _vString.append("\(_name):\(try convertValue(e)),")
                }
            }
            _vString.append("}")
            return _vString
        } else {
            throw FlexError.UnuseableTypeCameIn
        }
    }
}
