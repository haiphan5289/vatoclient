//  File name   : PhoneInputHeaderView.swift
//
//  Author      : Futa Corp
//  Created date: 3/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class PhoneInputHeaderView: UIView {
    /// Class's public properties.
    @IBOutlet weak var descriptionLabel: UILabel!

    /// Class's private properties.
}

// MARK: Class's public methods
extension PhoneInputHeaderView {
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
private extension PhoneInputHeaderView {
    private func initialize() {
        descriptionLabel.text = Text.enterPhoneNumber.localizedText
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
