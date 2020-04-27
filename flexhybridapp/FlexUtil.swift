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
}
