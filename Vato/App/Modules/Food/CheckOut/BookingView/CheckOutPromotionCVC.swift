//  File name   : CheckOutPromotionCVC.swift
//
//  Author      : Dung Vu
//  Created date: 7/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore

final class EcomPromotionDisplay {
    let promotion: EcomPromotion
    var applied = false
    init(with promotion: EcomPromotion) {
        var new = promotion
        new.canApply = true
        self.promotion = new
    }
}

final class CheckOutPromotionCVC: UICollectionViewCell, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var bgImageView: UIImageView?
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblDescription: UILabel?
    @IBOutlet var btnSelect: UIButton?

    /// Class's private properties.
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSelect?.setTitle(FwiLocale.localized("Huỷ"), for: .selected)
        btnSelect?.setTitle(FwiLocale.localized("Chọn"), for: .normal)
    }
    
    func setupDisplay(item: EcomPromotionDisplay?) {
        lblTitle?.text = item?.promotion.name
        lblDescription?.text = item?.promotion.description
        let applied = item?.applied == true
        let imgName = applied ? "bg_promotion_selected" : "bg_promotion_normal"
        bgImageView?.image = UIImage(named: imgName)
        btnSelect?.isSelected = applied
    }
}

