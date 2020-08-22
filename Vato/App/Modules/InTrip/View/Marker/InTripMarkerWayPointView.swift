//  File name   : InTripMarkerWayPointView.swift
//
//  Author      : Dung Vu
//  Created date: 4/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class InTripMarkerWayPointView: UIView {
    /// Class's public properties.
    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblName : UILabel?
    @IBOutlet var iconMarker : UIImageView?
    /// Class's private properties.
}

// MARK: Class's public methods
extension InTripMarkerWayPointView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
}

// MARK: Class's private methods
private extension InTripMarkerWayPointView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
