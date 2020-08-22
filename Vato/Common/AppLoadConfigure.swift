//  File name   : AppLoadConfigure.swift
//
//  Author      : Dung Vu
//  Created date: 3/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

@objcMembers
final class AppLoadConfigure: NSObject {
    /// Class's public properties.

    /// Class's constructors.
    static func applyConfig() {
        LocalizeObjC.reset()
    }

    /// Class's private properties.
}


