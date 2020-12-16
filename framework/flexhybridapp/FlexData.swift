//
//  FlexData.swift
//  FlexHybridApp
//
//  Created by dvkyun on 2020/09/01.
//  Copyright © 2020 dvkyun. All rights reserved.
//

import Foundation

public class FlexData {
    private let data: Any?
    public let type: Type
    
    public enum Type {
        case NIL
        case STRING
        case INT
        case DOUBLE
        case FLOAT
        case BOOL
        case ARRAY
        case DICTIONARY
        case ERR
    }
    
    internal init() {
        data = nil
        type = Type.NIL
    }
    
    internal init(_ data: String) {
        self.data = data
        type = Type.STRING
    }
    
    internal init(_ data: Int) {
        self.data = data
        type = Type.INT
    }
    
    internal init(_ data: Double) {
        self.data = data
        type = Type.DOUBLE
    }
    
    internal init(_ data: Float) {
        self.data = data
        type = Type.FLOAT
    }
    
    internal init(_ data: Bool) {
        self.data = data
        type = Type.BOOL
    }
    
    internal init(_ data: Array<FlexData>) {
        self.data = data
        type = Type.ARRAY
    }
    
    internal init(_ data: Dictionary<String,FlexData>) {
        self.data = data
        type = Type.DICTIONARY
    }
    
    internal init(_ data: BrowserException) {
        self.data = data
        type = Type.ERR
    }
    
    public func isNil() -> Bool {
        return data == nil
    }
    
    public func asString() -> String? {
        if isNil() { return nil }
        if(type != Type.STRING) {
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
        return (data as! String)
    }
    
    public func asInt() -> Int? {
        if isNil() { return nil }
        switch type {
        case Type.INT:
            return (data as! Int)
        case Type.DOUBLE:
            return Int((data as! Double))
        case Type.FLOAT:
            return Int((data as! Float))
        default:
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
    }
    
    public func asFloat() -> Float? {
        if isNil() { return nil }
        switch type {
        case Type.INT:
            return Float((data as! Int))
        case Type.DOUBLE:
            return Float((data as! Double))
        case Type.FLOAT:
            return (data as! Float)
        default:
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
    }
    
    public func asDouble() -> Double? {
        if isNil() { return nil }
        switch type {
        case Type.INT:
            return Double((data as! Int))
        case Type.DOUBLE:
            return (data as! Double)
        case Type.FLOAT:
            return Double((data as! Float))
        default:
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
    }
    
    public func asBool() -> Bool? {
        if isNil() { return nil }
        if(type != Type.BOOL) {
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
        return (data as! Bool)
    }
    
    public func asArray() -> Array<FlexData>? {
        if isNil() { return nil }
        if(type != Type.ARRAY) {
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
        return (data as! Array<FlexData>)
    }
    
    public func asDictionary() -> Dictionary<String,FlexData>? {
        if isNil() { return nil }
        if(type != Type.DICTIONARY) {
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
        return (data as! Dictionary<String,FlexData>)
    }
    
    public func asErr() -> BrowserException? {
        if isNil() { return nil }
        if(type != Type.ERR) {
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
        return (data as! BrowserException)
    }
    
    public func toString() -> String? {
        switch type {
        case Type.NIL: return nil
        case Type.STRING: return asString()!
        case Type.INT: return String(asInt()!)
        case Type.DOUBLE: return String(asDouble()!)
        case Type.FLOAT: return String(asFloat()!)
        case Type.ERR: return asErr()!.reason
        default:
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
    }
    
    public func reified<T>() -> T? {
        if isNil() { return nil }
        if (T.self == Int.self) {
            return (asInt() as! T)
        } else if(T.self == Float.self) {
            return (asFloat() as! T)
        } else if(T.self == Double.self) {
            return (asDouble() as! T)
        } else if(T.self == String.self) {
            return (toString() as! T)
        } else if(T.self == Bool.self) {
            return (asBool() as! T)
        } else if(T.self == Array<FlexData>.self) {
            return (asArray() as! T)
        } else if(T.self == Dictionary<String,FlexData>.self) {
            return (asDictionary() as! T)
        } else if(T.self == BrowserException.self) {
            return (asErr() as! T)
        } else {
            FlexMsg.err(FlexString.ERROR8)
            return nil
        }
    }
}
