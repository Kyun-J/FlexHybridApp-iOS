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
    case UnauthorizedProtocol
}

struct FlexString {
    static let ERROR1 = "After the FlextWebView is initialized, BaseUrl, Interface, Action cannot be added."
    static let ERROR2 = "You cannot set the interface or FlexAction name with flex";
    static let ERROR3 = "Only possible Int, Double, Float, Character, String, Dictionary<String,Any>, Array<Any>"
    static let ERROR4 = "FlexWebView to run javascript is null."
    static let ERROR5 = "The Interface or Action with the same name is already registered."
    static let ERROR6 = "The BaseUrl can only use file, http, https protocols."
    
    static let FLEX_DEFINE = ["flexlog","flexerror","flexdebug","flexinfo","flexreturn"]
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
        case FlexString.FLEX_DEFINE[0]:
            t = "LOG"
        case FlexString.FLEX_DEFINE[1]:
            t = "ERROR"
        case FlexString.FLEX_DEFINE[2]:
            t = "DEBUG"
        case FlexString.FLEX_DEFINE[3]:
            t = "INFO"
        default:
            t = type
        }
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxx"
        print("\(date.string(from: Date())) : \(t) on FlexWebView\n\(msg ?? "nil")")
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
