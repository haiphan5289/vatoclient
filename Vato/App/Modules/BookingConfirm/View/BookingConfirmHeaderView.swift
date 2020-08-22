//  File name   : BookingConfirmHeaderView.swift
//
//  Author      : Dung Vu
//  Created date: 9/27/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

@IBDesignable
final class BookingConfirmHeaderView: UIView, BookingConfirmUpdateUIProtocol {
    /// Class's public properties.
    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblPrice: UILabel?
    @IBOutlet weak var lblPromotion: UILabel?
    @IBOutlet weak var btnAction: UIButton?
    @IBOutlet weak var iconHighRate: UIImageView?
    /// Class's private properties.
}

// MARK: Class's public methods
extension BookingConfirmHeaderView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }

    func update(from type: BookingConfirmUpdateType) {
        switch type {
        case .service(let s):
            let name = s.name
            self.icon?.image = s.img
            self.lblName?.text = name
            self.iconHighRate?.isHidden = !s.isHighRate//!s.isFixedPrice || !s.isHighRate
        default:
            break
        }
    }
}

// MARK: Class's private methods
private extension BookingConfirmHeaderView {
    private func initialize() {
        // todo: Initialize view's here.
    }

    private func visualize() {
        // todo: Visualize view's here.
    }
}
