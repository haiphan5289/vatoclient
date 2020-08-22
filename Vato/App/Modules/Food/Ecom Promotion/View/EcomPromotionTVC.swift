//  File name   : EcomPromotionTVC.swift
//
//  Author      : Dung Vu
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class EcomPromotionTVC: UITableViewCell, UpdateDisplayProtocol {
    typealias Value = EcomPromotion
    
    /// Class's public properties.
    @IBOutlet weak var lblNamePromotion: UILabel?
    @IBOutlet weak var lblDescription: UILabel?
    @IBOutlet weak var lblExpire: UILabel?
    @IBOutlet weak var btnApply: UIButton?
    
    func setupDisplay(item: EcomPromotion?) {
        lblNamePromotion?.text = item?.name
        lblDescription?.text = item?.description
        guard let time = item?.toDate else {
            lblExpire?.text = ""
            return
        }
        let date = Date(timeIntervalSince1970: time / 1000)
        lblExpire?.text = date.string(from: "dd/MM/yyyy")
    }
    

    /// Class's private properties.
}

// MARK: Class's public methods
extension EcomPromotionTVC {
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
private extension EcomPromotionTVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
