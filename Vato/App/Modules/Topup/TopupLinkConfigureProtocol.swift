//  File name   : TopupLinkConfigureProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 11/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

@objc protocol TopupLinkConfigureProtocol: NSObjectProtocol {
    var type: Int { get }
    var name: String? { get set }
    var url: String? { get set }
    var auth: Bool { get }
    var active: Bool { get }
    var iconURL: String? { get set }
    var min: Int { get }
    var max: Int { get }
    var options: [Double]? { get }
    
    func clone() -> TopupLinkConfigureProtocol
}

enum TopupType: Int {
    case napas = 1
    case zaloPay = 2
    case momoPay = 4
    
    var name: String {
        switch self {
        case .napas:
            return "Napas"
        case .zaloPay:
            return "Zalopay"
        case .momoPay:
            return "Momopay"
        }
    }
}

extension TopupLinkConfigureProtocol  {
    var topUpType: TopupType? {
        return TopupType.init(rawValue: self.type)
    }
}


