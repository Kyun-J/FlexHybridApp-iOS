//
//  FlexClosure.swift
//  FlexHybridApp
//
//  Created by dvkyun on 2020/10/07.
//  Copyright © 2020 dvkyun. All rights reserved.
//

import Foundation

public struct FlexClosure {
    
    static public func void(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> Void) -> (_ arguments: Array<FlexData>) throws -> Void {
        return closure
    }
    
    static public func int(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> Int?) -> (_ arguments: Array<FlexData>) throws -> Int? {
        return closure
    }
    
    static public func double(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> Double?) -> (_ arguments: Array<FlexData>) throws -> Double? {
        return closure
    }
    
    static public func float(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> Float?) -> (_ arguments: Array<FlexData>) throws -> Float? {
        return closure
    }
    
    static public func bool(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> Bool?) -> (_ arguments: Array<FlexData>) throws -> Bool? {
        return closure
    }
    
    static public func string(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> String?) -> (_ arguments: Array<FlexData>) throws -> String? {
        return closure
    }
    
    static public func array(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> Array<Any?>?) -> (_ arguments: Array<FlexData>) throws -> Array<Any?>? {
        return closure
    }
    
    static public func dictionary(_ closure: @escaping (_ arguments: Array<FlexData>) throws -> Dictionary<String, Any?>?) -> (_ arguments: Array<FlexData>) throws -> Dictionary<String, Any?>? {
        return closure
    }
    
    static public func action(_ closure: @escaping (_ action: FlexAction, _ arguments: Array<FlexData>) -> Void) -> (_ action: FlexAction, _ arguments: Array<FlexData>) -> Void {
        return closure
    }
    
}
