//  File name   : FoodSearchHeaderView.swift
//
//  Author      : Dung Vu
//  Created date: 11/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class FoodSearchHeaderView: UIView {
    struct Configs {
        static let placeholder = "Bạn muốn tìm gì?"
    }
    /// Class's public properties.
    @IBOutlet var btnBack: UIButton?
    @IBOutlet var textField: UITextField?
    @IBOutlet var stackView: UIStackView?
    /// Class's private properties.
    
    func removeBtnBack() {
        guard let btnBack = self.btnBack else { return }
        stackView?.removeArrangedSubview(btnBack)
        btnBack.removeFromSuperview()
    }
}

// MARK: Class's public methods
extension FoodSearchHeaderView {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func update(placeHolder p: String?) {
        let att = p?.attribute >>> AttributeStyle.color(c: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 15, weight: .regular))
        textField?.attributedPlaceholder = att
    }
}

// MARK: Class's private methods
private extension FoodSearchHeaderView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        btnBack?.setImage(UIImage(named: "ic_food_search_back"), for: .normal)
        btnBack?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        update(placeHolder: Configs.placeholder)
    }
}
