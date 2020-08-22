//  File name   : BookingRequestStream.swift
//
//  Author      : Dung Vu
//  Created date: 1/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

protocol BookingRequestStream {
    var currentModelBook: BookingConfirmInformation { get }
}
