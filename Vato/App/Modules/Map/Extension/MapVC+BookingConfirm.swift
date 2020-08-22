//  File name   : MapVCComponent+BookingConfirm.swift
//
//  Author      : Vato
//  Created date: 9/29/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import SnapKit

extension MapVC: BookingConfirmViewControllable {
    func bind(bookingConfirmView: BookingConfirmView) {
        view.addSubview(bookingConfirmView)

        bookingConfirmView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
}
