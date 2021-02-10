//
//  FlexUtil.swift
//  flexhybridapp
//
//  Created by dvkyun on 2020/04/24.
//  Copyright © 2020 dvkyun. All rights reserved.
//

import Foundation
import UIKit

enum FlexError: Error {
    case FlexWebViewAlreadyInit
    case UnuseableTypeCameIn
    case UnauthorizedProtocol
}

struct FlexString {
    static let ERROR1 = "After the FlextWebView is initialized, BaseUrl, Options, Interfaces cannot be added."
    static let ERROR2 = "You cannot set the interface or FlexAction name with flex"
    static let ERROR3 = "Only possible nil, Int, Double, Float, Character, String, Dictionary<String,Any>, Array<Any>, FlexReject."
    static let ERROR4 = "FlexWebView to run javascript is null."
    static let ERROR5 = "The Interface or Action with the same name is already registered."
    static let ERROR6 = "The BaseUrl can only use file, http, https protocols."
    static let ERROR7 = "PromiseReturn cannot be called twice in a single FlexAction."
    static let ERROR8 = "The type of data stored in FlexData and the type called are not identical."
    
    static let FLEX_DEFINE = ["flexlog","flexerror","flexdebug","flexinfo","flexreturn","flexload","flexSuccess","flexException","flexTimeout","flexInit"]
    
    static let CHECKBOOL = UUID().uuidString
}

struct FlexMsg {
    static let date = DateFormatter()
    static func log(_ msg: String) {
        date.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxx"
        print("Log in FlextWebView \(date.string(from: Date())) ::: \(msg)")
    }
    static func err(_ err: String) {
        date.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxx"
        print("Error in FlextWebView \(date.string(from: Date())) ::: \(err)")
    }
    static func err(_ err: Error) {
        date.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxx"
        print("Error in FlextWebView \(date.string(from: Date())) ::: \(err.localizedDescription)")
    }
    static func debug(_ msg: String) {
        date.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxx"
        print("Debug in FlextWebView \(date.string(from: Date())) ::: \(msg)")
    }
    static func webLog(_ type: String, _ msg: Array<Any?>) {
        date.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxx"
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
        if(msg.count == 0) {
            print("\(date.string(from: Date())) :: FlexWebView \(t) : ")
            return
        }
        var data:Any? = msg;
        if(msg.count == 1) {
            data = msg[0];
        }
        print("\(date.string(from: Date())) :: FlexWebView \(t) : \(convertValueForLog(data))")
    }
    static func convertValueForLog(_ value: Any?) -> String {
        if value == nil {
            return "null"
        } else if value is Int || value is Double || value is Float || value is Bool {
            return "\(value!)"
        } else if value is String || value is Character {
            return "\(value!)"
        } else if value is Array<Any?> {
            let _vArray = value as! Array<Any?>
            var _vString = "["
            for e in _vArray {
                if e is Int || e is Double || e is Float || e is Bool {
                    _vString.append("\(e!),")
                } else if e is String || e is Character {
                    _vString.append("\(e!),")
                } else if e is Array<Any?> || e is Dictionary<String,Any?> {
                    _vString.append("\(convertValueForLog(e)),")
                } else if e == nil {
                    _vString.append("null")
                } else {
                    return "UnuseableTypeCameIn"
                }
            }
            _vString.append("]")
            return _vString
        } else if value is Dictionary<String,Any?> {
            let _vDic = value as! Dictionary<String,Any?>
            if(_vDic.count == 1 && _vDic[FlexString.CHECKBOOL] is Int) {
                let b = _vDic[FlexString.CHECKBOOL] as! Int
                if(b == 0) {
                    return "false"
                } else if(b == 1) {
                    return "true"
                } else {
                    return "UnuseableTypeCameIn"
                }
            } else if(_vDic.count == 1 && _vDic[FlexString.CHECKBOOL] is Bool) {
                let b = _vDic[FlexString.CHECKBOOL] as! Bool
                if(b) {
                    return "true"
                } else {
                    return "false"
                }
            }
            var _vString = "{"
            for (_name, e) in _vDic {
                if e is Int || e is Double || e is Float || e is Bool {
                    _vString.append("\(_name):\(e!),")
                } else if e is String || e is Character {
                    _vString.append("\(_name):\(e!),")
                } else if e is Array<Any?> || e is Dictionary<String,Any?> {
                    _vString.append("\(_name):\(convertValueForLog(e)),")
                } else if e == nil {
                    _vString.append("\(_name):null,")
                } else {
                    return "UnuseableTypeCameIn"
                }
            }
            _vString.append("}")
            return _vString
        } else {
            return "UnuseableTypeCameIn"
        }
    }
}

struct FlexFunc {
    static func convertValue(_ value: Any?) throws -> String {
        if value == nil {
            return "null"
        } else if value is Int || value is Double || value is Float || value is Bool {
            return "\(value!)"
        } else if value is String || value is Character {
            return "`\(value!)`"
        } else if value is Array<Any?> {
            let _vArray = value as! Array<Any?>
            var _vString = "["
            for e in _vArray {
                if e is Int || e is Double || e is Float || e is Bool {
                    _vString.append("\(e!),")
                } else if e is String || e is Character {
                    _vString.append("`\(e!)`,")
                } else if e is Array<Any?> || e is Dictionary<String,Any?> {
                    _vString.append("\(try convertValue(e)),")
                } else if e == nil {
                    _vString.append("null")
                } else {
                    throw FlexError.UnuseableTypeCameIn
                }
            }
            _vString.append("]")
            return _vString
        } else if value is Dictionary<String,Any?> {
            let _vDic = value as! Dictionary<String,Any?>
            var _vString = "{"
            for (_name, e) in _vDic {
                if e is Int || e is Double || e is Float || e is Bool {
                    _vString.append("\(_name):\(e!),")
                } else if e is String || e is Character {
                    _vString.append("\(_name):`\(e!)`,")
                } else if e is Array<Any?> || e is Dictionary<String,Any?> {
                    _vString.append("\(_name):\(try convertValue(e)),")
                } else if e == nil {
                    _vString.append("\(_name):null,")
                } else {
                    throw FlexError.UnuseableTypeCameIn
                }
            }
            _vString.append("}")
            return _vString
        } else {
            throw FlexError.UnuseableTypeCameIn
        }
    }
    
    static func arrayToFlexData(_ value: Array<Any?>?) -> Array<FlexData> {
        var res: Array<FlexData> = []
        value?.forEach({ (ele) in
            if(ele == nil) {
                res.append(FlexData())
            } else if(ele is Int) {
                res.append(FlexData(ele as! Int))
            } else if(ele is Float) {
                res.append(FlexData(ele as! Float))
            } else if(ele is Double) {
                res.append(FlexData(ele as! Double))
            } else if(ele is String) {
                res.append(FlexData(ele as! String))
            } else if(ele is Array<Any?>) {
                res.append(FlexData(arrayToFlexData(ele as? Array<Any?>)))
            } else if(ele is Dictionary<String, Any?>) {
                let e = ele as? Dictionary<String, Any?>
                if(e?.count == 1 && e?[FlexString.CHECKBOOL] is Int) {
                    let b = e?[FlexString.CHECKBOOL] as? Int
                    if(b == 0) {
                        res.append(FlexData(false))
                    } else if(b == 1) {
                        res.append(FlexData(true))
                    } else {
                        res.append(FlexData([:]))
                    }
                } else if(e?.count == 1 && e?[FlexString.CHECKBOOL] is Bool) {
                    let b = e?[FlexString.CHECKBOOL] as? Bool
                    if(b ?? false) {
                        res.append(FlexData(true))
                    } else {
                        res.append(FlexData(false))
                    }
                } else {
                    res.append(FlexData(dictionaryToFlexData(e)))
                }
            }
        })
        return res
    }
    
    static func dictionaryToFlexData(_ value: Dictionary<String, Any?>?) -> Dictionary<String,FlexData> {
        var res: Dictionary<String,FlexData> = [:]
        value?.keys.forEach({ (key) in
            let ele = value![key]
            if(ele == nil) {
                res[key] = FlexData()
            } else if(ele is Int) {
                res[key] = FlexData(ele as! Int)
            } else if(ele is Float) {
                res[key] = FlexData(ele as! Float)
            } else if(ele is Double) {
                res[key] = FlexData(ele as! Double)
            } else if(ele is String) {
                res[key] = FlexData(ele as! String)
            } else if(ele is Array<Any?>) {
                res[key] = FlexData(arrayToFlexData(ele as? Array<Any?>))
            } else if(ele is Dictionary<String, Any?>) {
                let e = ele as? Dictionary<String, Any?>
                if(e?.count == 1 && e?[FlexString.CHECKBOOL] is Int) {
                    let b = e?[FlexString.CHECKBOOL] as? Int
                    if(b == 0) {
                        res[key] = FlexData(false)
                    } else if(b == 1) {
                        res[key] = FlexData(true)
                    } else {
                        res[key] = FlexData([:])
                    }
                } else if(e?.count == 1 && e?[FlexString.CHECKBOOL] is Bool) {
                    let b = e?[FlexString.CHECKBOOL] as? Bool
                    if(b ?? false) {
                        res[key] = FlexData(true)
                    } else {
                        res[key] = FlexData(false)
                    }
                } else {
                    res[key] = FlexData(dictionaryToFlexData(e))
                }
            }
        })
        return res
    }
    
    static func anyToFlexData(_ value: Any?) -> FlexData {
        if(value == nil) {
            return FlexData()
        } else if(value is Int) {
            return FlexData(value as! Int)
        } else if(value is Float) {
            return FlexData(value as! Float)
        } else if(value is Double) {
            return FlexData(value as! Double)
        } else if(value is String) {
            return FlexData(value as! String)
        } else if(value is Array<Any?>) {
            return FlexData(arrayToFlexData(value as? Array<Any?>))
        } else if(value is Dictionary<String, Any?>) {
            let e = value as? Dictionary<String, Any?>
            if(e?.count == 1 && e?[FlexString.CHECKBOOL] is Int) {
                let b = e?[FlexString.CHECKBOOL] as? Int
                if(b == 0) {
                    return FlexData(false)
                } else if(b == 1) {
                    return FlexData(true)
                } else {
                    return FlexData([:])
                }
            } else if(e?.count == 1 && e?[FlexString.CHECKBOOL] is Bool) {
                let b = e?[FlexString.CHECKBOOL] as? Bool
                if(b ?? false) {
                    return FlexData(true)
                } else {
                    return FlexData(false)
                }
            }  else {
                return FlexData(dictionaryToFlexData(e))
            }
        } else if(value is BrowserException) {
            return FlexData(value as! BrowserException)
        } else {
            FlexMsg.err(FlexString.ERROR8)
            return FlexData()
        }
    }
}

struct DeviceInfo {
    
    //-- https://www.theiphonewiki.com/wiki/Models
    
    static func getInfo() -> [String:String] {
        var info: [String:String] = [:]
        info["os"] = UIDevice.current.systemName
        info["model"] = deviceModelName()
        info["version"] = UIDevice.current.systemVersion
                
        return info
    }
    
    
    static private func deviceModelName() -> String {
        
        let model = UIDevice.current.model
        
        switch model {
        case "iPhone":
            return self.iPhoneModel()
        case "iPad", "iPad mini":
            return self.iPadModel()
            
        default:
            return "Unknown_Model_\(model)"
        }
    }
    
    static private func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
                        
        return identifier
    }
    
    
    static private func iPhoneModel() -> String {
        
        let identifier = self.getDeviceIdentifier()
        
        switch identifier {
        case "iPhone1,1" :
            return "iPhone"
        case "iPhone1,2" :
            return "iPhone3G"
        case "iPhone2,1" :
            return "iPhone3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3" :
            return "iPhone4"
        case "iPhone4,1" :
            return "iPhone4s"
        case "iPhone5,1", "iPhone5,2" :
            return "iPhone5"
        case "iPhone5,3", "iPhone5,4" :
            return "iPhone5c"
        case "iPhone6,1", "iPhone6,2" :
            return "iPhone5s"
        case "iPhone7,2" :
            return "iPhone6"
        case "iPhone7,1" :
            return "iPhone6_Plus"
        case "iPhone8,1" :
            return "iPhone6s"
        case "iPhone8,2" :
            return "iPhone6s_Plus"
        case "iPhone8,4" :
            return "iPhone_SE"
        case "iPhone9,1", "iPhone9,3" :
            return "iPhone7"
        case "iPhone9,2", "iPhone9,4" :
            return "iPhone7_Plus"
        case "iPhone10,1", "iPhone10,4" :
            return "iPhone8"
        case "iPhone10,2", "iPhone10,5" :
            return "iPhone8_Plus"
        case "iPhone10,3", "iPhone10,6" :
            return "iPhoneX"
        case "iPhone11,2" :
            return "iPhoneXs"
        case "iPhone11,6" :
            return "iPhoneXs_Max"
        case "iPhone12,1" :
            return "iPhone11"
        case "iPhone12,3" :
            return "iPhone11_Pro"
        case "iPhone12,5" :
            return "iPhone11_Pro_Max"
        case "iPhone12,8" :
            return "iPhone_SE_2nd_Generation"
        case "iPhone13,1":
            return "iPhone_12_Mini"
        case "iPhone13,2":
            return "iPhone_12"
        case "iPhone13,3":
            return "iPhone_12_Pro"
        case "iPhone13,4":
            return "iPhone_12_Pro_Max"
        default:
            return "Unknown_iPhone_\(identifier)"
        }
    }
    

    static private func iPadModel() -> String {
        
        let identifier = self.getDeviceIdentifier()
        
        switch identifier {
        case "iPad1,1":
            return "iPad"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4" :
            return "iPad2"
        case "iPad3,1", "iPad3,2", "iPad3,3" :
            return "iPad_3rd_Generation"
        case "iPad3,4", "iPad3,5", "iPad3,6" :
            return "iPad_4rd_Generation"
        case "iPad6,11", "iPad6,12" :
            return "iPad_5th_Generation"
        case "iPad7,5", "iPad7,6" :
            return "iPad_6th_Generation"
        case "iPad7,11", "iPad7,12" :
            return "iPad_7th_Generation"
        case "iPad11,6", "iPad11,7" :
            return "iPad_8th_Generation"
        
        case "iPad2,5", "iPad2,6", "iPad2,7" :
            return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6" :
            return "iPad mini2"
        case "iPad4,7", "iPad4,8", "iPad4,9" :
            return "iPad mini3"
        case "iPad5,1", "iPad5,2" :
            return "iPad mini4"
        case "iPad11,1", "iPad11,2" :
            return "iPad mini5"
            
        case "iPad4,1", "iPad4,2", "iPad4,3" :
            return "iPad_Air"
        case "iPad5,3", "iPad5,4" :
            return "iPad_Air2"
        case "iPad11,3", "iPad11,4" :
            return "iPad_Air3"
        case "iPad13,1", "iPad13,2" :
            return "iPad_Air4"
            
        case "iPad6,7", "iPad6,8" :
            return "iPad_Pro_12.9"
        case "iPad6,3", "iPad6,4" :
            return "iPad_Pro_9.7"
        case "iPad7,1", "iPad7,2" :
            return "iPad_Pro_12.9_2nd_Generation"
        case "iPad7,3", "iPad7,4" :
            return "iPad_Pro_10.5"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4" :
            return "iPad_Pro_11"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8" :
            return "iPad_Pro_12.9_3rd_Generation"
        case "iPad8,9", "iPad8,10" :
            return "iPad_Pro_11_2nd_Generation"
        case "iPad8,11", "iPad8,12" :
            return "iPad_Pro_12.9_4th_Generation"
        default:
            return "Unknown_iPad_\(identifier)"
        }
    }

}

