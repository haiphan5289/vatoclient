//  File name   : BookingModel.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

final class BookingDefaultSelection {
    var paymentMethod: PaymentMethod?
    var service: VatoServiceType?
    var arrayServiceMore: [AdditionalServices]?
    var note: String?
    
    func copy(from other: BookingDefaultSelection) {
        self.paymentMethod = other.paymentMethod
        self.service = other.service
        self.arrayServiceMore = other.arrayServiceMore
        self.note = other.note
    }
}

struct Booking: Equatable {
    let tripType: Int
    var originAddress: AddressProtocol
    var destinationAddress1: AddressProtocol?
    
    // Use For select default
    let defaultSelect = BookingDefaultSelection()
    
    static func ==(lhs: Booking, rhs: Booking) -> Bool {
        return lhs.tripType == rhs.tripType &&
            lhs.originAddress.coordinate == rhs.originAddress.coordinate &&
            lhs.destinationAddress1?.coordinate == rhs.destinationAddress1?.coordinate
    }
}


