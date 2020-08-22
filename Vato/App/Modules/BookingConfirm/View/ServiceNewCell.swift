//
//  ServiceNewCell.swift
//  Vato
//
//  Created by khoi tran on 11/13/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ServiceNewCell: UITableViewCell {
    
    @IBOutlet weak var iconService: UIImageView?
    @IBOutlet weak var serviceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var hightRateIcon: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // define
        
        let colorBgSelected = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.1)
        let colorLineSelected = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.14)
        let colorMoneySelected = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        
        let colorBgDeselected = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 0.1)
        let colorLineDeselected = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 0.24)
        let colorMoneyDeselected = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 0.24)
        
        // Configure the view for the selected state
        
        if selected {
            bgView?.borderView(with: colorLineSelected, width: 1, andRadius: 8)
            bgView.backgroundColor = colorBgSelected
            priceLabel?.textColor = colorMoneySelected
        } else {
            bgView?.borderView(with: colorLineDeselected, width: 1, andRadius: 8)
            bgView.backgroundColor = colorBgDeselected
            priceLabel?.textColor = colorMoneyDeselected
        }
    }
    
    
    func updateData(model: ServiceCanUseProtocol, modelPromotion: PromotionModel?, currentBook: Booking?) {
        self.hightRateIcon?.isHidden = !model.isHighRate
        self.serviceNameLabel?.text = model.name
        if model.idService == VatoServiceDelivery.rawValue {
            self.serviceNameLabel?.text = Text.fastDelivery.localizedText
        }
        
        self.iconService?.image = model.service.serviceType.image()
        // Calculate
//        let calculateDiscount: (BookingConfirmPrice) -> UInt32 = { confirm in
//            guard let modelPromotion = modelPromotion else {
//                return 0
//            }
//            let d = try? modelPromotion.usePromotion(from: currentBook, price: confirm, serviceType: model.service.serviceType)
//            let discount = d?.discount ?? 0
//            return discount
//        }
        
        // price and promotion
//        let price = BookingConfirmPrice()
//        price.calculateLastPrice(from: model, tip: 0)
//        let discount = calculateDiscount(price)
        
        let range = model.rangePrice
        let original = range?.min ?? 0
        let total = range?.max ?? 0
        
//        let lastOriginal = original > discount ? original - discount : 0
//        let lastTotal = total > discount ? total - discount : 0
        if model.isGroupService,
            original != total {
            self.priceLabel?.text = "\(original.currency)-\(total.currency)"
        } else {
            self.priceLabel?.text = total.currency
        }
    }
    
}
