//  File name   : HomeWalletView.swift
//
//  Author      : Vato
//  Created date: 9/27/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class HomeWalletView: UIView {
    /// Class's public properties.
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var walletButton: UIButton!

    /// Class's private properties.
}

// MARK: Class's public methods
extension HomeWalletView {
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
private extension HomeWalletView {
    private func initialize() {
        // todo: Initialize view's here.
    }

    private func visualize() {
        // todo: Visualize view's here.
    }
}
