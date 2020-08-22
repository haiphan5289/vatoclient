//  File name   : HistoryExpressLocationView.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class HistoryExpressLocationView: UIView {
    /// Class's public properties.
    @IBOutlet var lblAddress : UILabel?
    @IBOutlet var lblStatus : UILabel?
    /// Class's private properties.
}

// MARK: Class's public methods
extension HistoryExpressLocationView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        lblAddress?.text = "102 Trần Hưng Đạo, Phường Phạm Ngũ Lão, Quận 1, Hồ Chí Minh"
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension HistoryExpressLocationView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
