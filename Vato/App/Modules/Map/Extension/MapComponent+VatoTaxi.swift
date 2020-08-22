//  File name   : MapComponent+BookingConfirm.swift
//
//  Author      : Dung Vu
//  Created date: 9/18/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------
import SnapKit

extension MapComponent: VatoTaxiDependency {
    var VatoTaxiVC: BookingConfirmViewControllable {
        return mapVC
    }
}
