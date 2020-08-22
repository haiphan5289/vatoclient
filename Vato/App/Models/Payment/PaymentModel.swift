//  File name   : PaymentModel.swift
//
//  Author      : Dung Vu
//  Created date: 7/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore

struct PaymentCardDetail: Codable, PaymentCardDisplay, PaymentMethodIdentifierProtocol, ImageDisplayProtocol, Hashable {
    static func ==(lhs: PaymentCardDetail, rhs: PaymentCardDetail) -> Bool {
        return lhs.id == rhs.id && !lhs.addCard && !rhs.addCard
    }
    
    var placeHolder: String {
        switch type {
        case .cash:
            return "ic_payment_0"
        case .vatoPay:
            return "ic_payment_1"
        case .atm:
            return "ic_method_3"
        default:
            return ""
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    var name: String {
        return self.number ?? ""
    }
    var cacheLocal: Bool { return true }
    var type: PaymentCardType {
        if id == "0x" {
            return .cash
        }
        
        if id == "1x" {
            return .vatoPay
        }
        
        if id == "6xx" {
            return .momo
        }
        
        if id == "7xx" {
            return .zaloPay
        }
        
        if id == "8xx" {
            return .addCardVisaMaster
        }
        
        if id == "9xx" {
            return .addCardATM
        }
        
        let p = number?.prefix(1) ?? ""
        
        switch p {
        case "0":
            return .cash
        case "1":
            return .vatoPay
        case "4", "3":
            return .visa
        case "5":
            return .master
        case "":
            return .none
        default:
            return .atm
        }
    }
    
    var napas: Bool {
        return !(id == "0x" || id == "1x")
    }
    
    var topUpName: String {
        return (brand ?? "") + " " + (number ?? "")
    }
    
    var shortDescription: String {
        return "\(FwiLocale.localized("Thẻ")) **\(number.orNil("").suffix(4))"
    }
    
    var localPayment: Bool {
        if methodUseAPI {
            return true
        }
        switch type {
        case .visa, .master:
            return false
        case .atm:
            return mIdentifier == nil
        default:
            return true
        }
    }
    
    var id: String
    var brand: String?
    var issueDate: String?
    var iconUrl: String?
    var number: String?
    var scheme: String?
    var nameOnCard: String?
    var params: JSON?
    var enable3d: Bool = false
    var canUse: Bool = true
    var iconSmall: UIImage?
    var addCard: Bool = false
    var methodUseAPI: Bool = false
    var methodEwallet: String?
    private var mIdentifier: String?
    var identifier: String? {
        return mIdentifier ?? type.identifier
    }
    var imageURL: String? {
        return iconUrl
    }

    enum CodingKeys: String, CodingKey {
       case id = "id"
       case brand = "brand"
       case issueDate = "issueDate"
       case iconUrl = "iconUrl"
       case number = "number"
       case scheme = "scheme"
       case nameOnCard = "nameOnCard"
    }
    
    static func cash() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "0x", brand: Text.cash.localizedText, issueDate: nil, iconUrl: nil, number: nil, scheme: nil, iconSmall: UIImage(named: "ic_payment_0_s"))
        return m
    }
    
    static func vatoPay() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "1x", brand: "VATOPay", issueDate: nil, iconUrl: nil, number: nil, scheme: nil, iconSmall: UIImage(named: "ic_payment_1_s"))
        return m
    }
    
    static func zaloPay() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "7xx", brand: "ZALO", issueDate: nil, iconUrl: nil, number: nil, scheme: nil, iconSmall: UIImage(named:"ic_payment_6_s"), methodEwallet: "Zalopay")
        return m
    }
    
    static func momo() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "6xx", brand: "MOMO", issueDate: nil, iconUrl: nil, number: nil, scheme: nil, iconSmall: UIImage(named: "ic_payment_5_s"), methodEwallet: "Momopay")
        return m
    }
    
    static func credit() -> PaymentCardDetail {
        var m = PaymentCardDetail(id: "4x", brand: Text.visaMasterJCBCard.localizedText, issueDate: nil, iconUrl: nil, number: "5", scheme: nil, iconSmall: UIImage(named: "ic_payment_4_s"), methodUseAPI: true, mIdentifier: "credit")
        m.enable3d = true
        m.params = ["cardScheme" : "CreditCard", "deviceId": "phone", "environment": "MobileApp", "description": "ticket"]
        return m
    }
    
    static func atm() -> PaymentCardDetail {
        var m = PaymentCardDetail(id: "6x", brand: Text.atmCard.localizedText, issueDate: nil, iconUrl: nil, number: "6", scheme: nil, iconSmall: UIImage(named: "ic_payment_3_s"), methodUseAPI: true, mIdentifier: "atm")
        m.params = ["cardScheme" : "AtmCard", "deviceId": "phone", "environment": "MobileApp", "description": "ticket"]
        return m
    }
    
    static func addCardVisaMaster() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "8x", brand: FwiLocale.localized("Thêm Visa/Master"), issueDate: nil, iconUrl: nil, number: "8", scheme: nil, iconSmall: UIImage(named: "ic_payment_2_s"), addCard: true, methodUseAPI: true)
        return m
    }
    
    static func addCardATM() -> PaymentCardDetail {
        let m = PaymentCardDetail(id: "9x", brand: FwiLocale.localized("Thêm ATM"), issueDate: nil, iconUrl: nil, number: "9", scheme: nil, iconSmall: UIImage(named: "ic_payment_3_s"), addCard: true, methodUseAPI: true)
        return m
    }
    
    static func clone(old: PaymentCardDetail) -> PaymentCardDetail {
        let p = old.params
        let new = PaymentCardDetail(id: old.id, brand: old.brand, issueDate: old.issueDate, iconUrl: old.iconUrl, number: old.number, scheme: old.scheme, nameOnCard: old.nameOnCard, params: p, enable3d: old.enable3d, iconSmall: old.iconSmall, methodEwallet: old.methodEwallet)
        return new
    }
}

extension PaymentCardDetail {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        brand = try values.decodeIfPresent(String.self, forKey: .brand)
        issueDate = try values.decodeIfPresent(String.self, forKey: .issueDate)
        iconUrl = try values.decodeIfPresent(String.self, forKey: .iconUrl)
        number = try values.decodeIfPresent(String.self, forKey: .number)
        scheme = try values.decodeIfPresent(String.self, forKey: .scheme)
        nameOnCard = try values.decodeIfPresent(String.self, forKey: .nameOnCard)
        
        switch type {
        case .visa:
            mIdentifier = "tokenvisa"
            iconSmall = UIImage(named: "ic_payment_4_s")
        case .master:
            mIdentifier = "tokenmaster"
            iconSmall = UIImage(named: "ic_payment_2_s")
        case .atm:
            mIdentifier = "tokenatm"
            iconSmall = UIImage(named: "ic_payment_3_s")
        default:
            break
        }
    }
}

extension PaymentCardDetail: Equatable {}
