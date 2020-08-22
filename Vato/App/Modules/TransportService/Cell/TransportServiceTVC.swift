//  File name   : TransportServiceTVC.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import UIKit

final class TransportServiceTVC: UITableViewCell {
    /// Class's public properties.
    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblPrice: UILabel?
    @IBOutlet weak var lblDescription: UILabel?
    @IBOutlet weak var iconHighRate: UIImageView?
    @IBOutlet weak var viewSelect: UIView?
    /// Class's private properties.
}

// MARK: Class's public methods
extension TransportServiceTVC {
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        localize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        viewSelect?.isHidden = !selected
    }

    func visualize(with model: ServiceCanUseProtocol, isFixedBook: Bool, modelPromotion: PromotionModel?, currentBook: Booking?) {
        let hRate = !model.isHighRate
        self.icon?.image = model.service.serviceType.image()
        self.lblName?.text = model.name
        self.lblDescription?.text = model.service.description
        // Calculate
        let calculateDiscount: (BookingConfirmPrice) -> UInt32 = { confirm in
            guard let modelPromotion = modelPromotion else {
                return 0
            }
            let d = try? modelPromotion.usePromotion(from: currentBook, price: confirm, serviceType: model.service.serviceType)
            let discount = d?.discount ?? 0
            return discount
        }
        
        let price = BookingConfirmPrice()
        price.calculateLastPrice(from: model, tip: 0)
        let discount = calculateDiscount(price)
        
        let range = model.rangePrice
        let original = range?.min ?? 0
        let total = range?.max ?? 0
        
        let lastOriginal = original > discount ? original - discount : 0
        let lastTotal = total > discount ? total - discount : 0
        
        if model.isGroupService,
            lastOriginal != lastTotal {
            self.lblPrice?.text = "\(lastOriginal.currency)-\(lastTotal.currency)"
        } else {
            self.lblPrice?.text = total.currency
        }
        
        
        self.iconHighRate?.isHidden = hRate//!isFixedBook || hRate
        self.lblPrice?.isHidden = !isFixedBook
    }
}

// MARK: Class's private methods
private extension TransportServiceTVC {
    private func localize() {
        // todo: Localize view's here.
    }

    private func visualize() {
        // todo: Visualize view's here.
    }
}
