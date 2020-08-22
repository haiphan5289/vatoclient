//  File name   : NotificationPushService.swift
//
//  Author      : Dung Vu
//  Created date: 2/12/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

@objcMembers
final class NotificationPushService: NSObject {
    static let instance = NotificationPushService()
    /// Class's constructors.
    @VariableReplay(wrappedValue: nil) private var infor: [String: Any]?
    var new: Observable<[String: Any]> {
        return $infor.filterNil()
    }
    
    /// Class's private properties.
    func update(push: [String: Any]?) {
        infor = push
    }
    
    func reset() {
        infor = nil
    }
    
}

