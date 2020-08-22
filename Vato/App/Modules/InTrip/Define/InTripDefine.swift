//  File name   : InTripDefine.swift
//
//  Author      : Dung Vu
//  Created date: 4/8/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

enum InTripUIUpdateType: Equatable {
    case status(message: String)
    case vibrateDriverNearby
    case showTakeClientTime(duration: FirebaseTrip.Duration)
    case showInTripTime(duration: FirebaseTrip.Duration)
    case alertTripRemove(message: String)
    case showAlertBeginNewTrip(message: String)
    case showAddNewDestination
    case newChat
    case showChat
    case showReceipt
    case showReview
    
    static func ==(lhs: InTripUIUpdateType, rhs: InTripUIUpdateType) -> Bool {
        switch (lhs, rhs) {
        case (.status(let m1), .status(let m2)):
            return m1 == m2
        case (.vibrateDriverNearby, .vibrateDriverNearby):
            return true
        case (.showTakeClientTime(let duration1), .showTakeClientTime(let duration2)):
            return duration1 == duration2
        case (.showInTripTime(let duration1), .showInTripTime(let duration2)):
            return duration1 == duration2
        case (.alertTripRemove(let message1), .alertTripRemove(let message2)):
            return message1 == message2
//        case (.showReceipt, .showReceipt):
//            return true
        default:
            return false
        }
    }
    
}

struct DriverInfo: Equatable {
    let personal: FirebaseUser
    let customer: Driver
    
    static func ==(lhs: DriverInfo, rhs: DriverInfo) -> Bool {
        return lhs.personal.id == rhs.personal.id
    }
}

struct InTripPayment: Equatable {
    let payment: Int
    let price: UInt32
    let farePrice: UInt32
    let finalPrice: UInt32
    
    var method: PaymentMethod? {
        let type = PaymentMethod.init(payment)
        return type
    }
    
    static func ==(lhs: InTripPayment, rhs: InTripPayment) -> Bool {
        return lhs.payment == rhs.payment && lhs.price == rhs.price
    }
}

// MARK: -- Cell
enum InTripCellType: String {
    case driverInfo
    case contactInfo
    case noteDriver
    case paymentInfo
    case addressInfo
}
