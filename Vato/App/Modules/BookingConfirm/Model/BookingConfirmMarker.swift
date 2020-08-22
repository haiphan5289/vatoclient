//  File name   : BookingConfirmMarker.swift
//
//  Author      : Dung Vu
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

final class BookingConfirmMarker: GMSMarker {
    /// Class's public properties.
    var type: MarkerViewType = .start
    /// Class's constructors.
    convenience init(from address: AddressProtocol, type: MarkerViewType) {
        self.init(position: address.coordinate)
        self.tracksViewChanges = false
        let v = BookingConfirmMarkerView.load(from: address, type: type)
        self.type = type
        self.iconView = v
    }

    func reCheckPosition() {
        let point = map?.projection.point(for: self.position)
        (self.iconView as? BookingConfirmMarkerView)?.updatePosition(at: point)
    }
}

// MARK: Class's public methods
extension BookingConfirmMarker {}

// MARK: Class's private methods
private extension BookingConfirmMarker {}
