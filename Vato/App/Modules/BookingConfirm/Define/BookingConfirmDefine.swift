//
//  BookingConfirmDefine.swift
//  FaceCar
//
//  Created by Dung Vu on 9/17/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation
import UIKit

enum BookingConfirmUpdateType {
    case note(string: String?)
    case service(type: ServiceCanUseProtocol)
    case updateBooking(booking: Booking?)
    case update(string: String?, exist: Bool)
    case updatePrice(infor: BookingConfirmPrice)
    case updateMethod(method: PaymentCardDetail)
    case updateTip(tip: Double)
    case updatePromotion(model: PromotionModel?)
    case updateListService(listService: [ServiceCanUseProtocol])
    case book
}

enum BookingConfirmType: Int {
    case coupon
    case addTip
    case wallet
    case note
    case amount
    case total
    case chooseInformation
    case booking
    case moveToCurrent
    case detailPrice
    case none

    var icon: UIImage? {
        switch self {
        case .addTip:
            return UIImage(named: "ic_plus_service_off")
        case .note:
            return #imageLiteral(resourceName: "ic_note")
        case .amount:
            return nil
        case .wallet:
            return #imageLiteral(resourceName: "wallet")
        case .coupon:
            return #imageLiteral(resourceName: "ic_coupon")
        case .moveToCurrent:
            return nil
        case .detailPrice:
            return nil
        default:
            fatalError("Check")
        }
    }

    var iconH: UIImage? {
        switch self {
        case .addTip:
            return UIImage(named: "ic_plus_service_on")
        case .note:
            return #imageLiteral(resourceName: "ic_note_h")
        case .amount:
            return nil
        case .wallet:
            return #imageLiteral(resourceName: "wallet")
        case .coupon:
            return #imageLiteral(resourceName: "ic_coupon_h")
        case .moveToCurrent:
            return nil
        case .detailPrice:
            return nil
        default:
            fatalError("Check")
        }
    }

    var defaultValue: String {
        switch self {
        case .addTip:
            return Text.serviceMore.localizedText
        case .note:
            return Text.note.localizedText
        case .amount:
            return Text.total.localizedText
        case .wallet:
            return "Add wallet"
        case .coupon:
            return Text.promotion.localizedText
        default:
            fatalError("Check")
        }
    }

    static var allCases: [BookingConfirmType] {
//        return [.note, .addTip]
        return [.coupon, .note, .addTip]
    }

    static var quickBook: [BookingConfirmType] {
//        return [.note]
        return [.coupon, .note]
    }
}
