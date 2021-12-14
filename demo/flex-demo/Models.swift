//
//  Models.swift
//  flex-demo
//
//  Created by 황견주 on 2021/12/13.
//

import Foundation


struct TestModel1: Codable {
    var string: String
    var integer: Int
}

struct TestModel2: Codable {
    var array: [String]
    var dic: [String: String]
    var model: TestModel3
}

struct TestModel3: Codable {
    var bool: Bool
}
