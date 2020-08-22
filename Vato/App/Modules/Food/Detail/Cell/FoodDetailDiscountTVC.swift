//  File name   : FoodDetailDiscountTVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class FoodDetailDiscountTVC: UITableViewCell {
    /// Class's public properties.

    /// Class's private properties.
    @IBOutlet var lblDetail: UILabel?
}

// MARK: Class's public methods
extension FoodDetailDiscountTVC {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }
}

// MARK: Class's private methods
private extension FoodDetailDiscountTVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        contentView.addSeperator(with: .zero, position: .bottom)
    }
}
