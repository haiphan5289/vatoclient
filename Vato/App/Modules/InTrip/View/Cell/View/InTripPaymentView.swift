//  File name   : InTripPaymentView.swift
//
//  Author      : Dung Vu
//  Created date: 3/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class InTripPaymentView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblPayment : UILabel?
    @IBOutlet var lblPrice : UILabel?
    @IBOutlet var lblOriginalPrice : UILabel?
    /// Class's private properties.
    
    func setupDisplay(item: InTripPayment?) {
        guard let item = item else { return }
        lblPayment?.text = item.method?.name
        lblPayment?.backgroundColor = item.method?.bgColor
        lblPrice?.text = item.finalPrice.currency
        let p1 = item.finalPrice
        let p2 = max(item.price, item.farePrice)
        lblOriginalPrice?.isHidden = p1 >= p2
        let att = p2.currency.attribute >>> .strike(v: 1)
        lblOriginalPrice?.attributedText = att
        
    }
}

// MARK: Class's public methods
extension InTripPaymentView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension InTripPaymentView {
    private func initialize() {
        // todo: Initialize view's here.
        lblTitle?.text = Text.pay.localizedText
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
