//
//  CheckOutInformationCell.swift
//  Vato
//
//  Created by khoi tran on 12/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import SnapKit
import FwiCore

final class CheckOutInformationCell: DeliveryInformationCell {
    override func updateData(item: DestinationDisplayProtocol?) {
        addressLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        leftIconButton.setImage(UIImage(named: "ic_history_location"), for: .normal)
        rightIconButton.setImage(UIImage(named: "ic_arr_gray"), for: .normal)
        rightIconButton.backgroundColor = .white
        if let item = item, let address = item.originalDestination {
            addressLabel.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            addressLabel.text = address.subLocality
            userInformationLabel.text = ""
            userInformationLabel.isHidden = true

            self.backgroundImageView.isHidden = true
            containerView.backgroundColor = .white
            userInformationLabel.isHidden = false
            
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(4)
                make.bottom.equalTo(-4)
            }
            height = { 73 }
        } else {
            addressLabel.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            userInformationLabel.text = ""
            userInformationLabel.isHidden = true
            
            addressLabel.text = Text.addShippingAddress.localizedText
            
            self.backgroundImageView.isHidden = false
            containerView.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.2)
            
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(16)
                make.bottom.equalTo(-16)
            }
            height = { 100 }
        }
    }
}

final class CheckOutDetailPriceCell: Eureka.Cell<QuoteCart>, CellType, UpdateDisplayProtocol {
    private var detailPriceView: DetailPriceView = DetailPriceView(frame: .zero)
    private var lblTitle: UILabel = UILabel(frame: .zero)
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        lblTitle >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.text = FwiLocale.localized("Chi tiết giá")
            $0.snp.makeConstraints { (make) in
                make.left.top.equalTo(16)
                make.right.equalTo(-16)
            }
        }
        
        detailPriceView >>> contentView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(lblTitle.snp.bottom)
            }
        }
    }
    
    func setupDisplay(item: QuoteCart?) {
        guard let quoteCart = item else {
            return
        }
        var styles = [PriceInfoDisplayStyle]()
        let att1 = Text.itemPrice.localizedText.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
        let price1 = quoteCart.baseGrandTotal.orNil(0).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
        let d1 = PriceInfoDisplayStyle(attributeTitle: att1, attributePrice: price1, showLine: false, edge: .zero)
        styles.append(d1)
        
        let att3 = Text.shippingFee.localizedText.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
        let price3 = (quoteCart.quoteShipments?.first?.price ?? 0).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
        let d3 = PriceInfoDisplayStyle(attributeTitle: att3, attributePrice: price3, showLine: false, edge: .zero)
        styles.append(d3)
        
        if let shippingFree = item?.discountShippingFee, shippingFree > 0 {
            let att4 = FwiLocale.localized("Hỗ trợ giao hàng").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            let price4 = (0 - shippingFree).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
            let d4 = PriceInfoDisplayStyle(attributeTitle: att4, attributePrice: price4, showLine: false, edge: .zero)
            styles.append(d4)
        }
        
        item?.vatoCampaignDiscountInfo?.forEach({ (i) in
            guard i.value > 0 else { return }
            let att0 = i.key.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            let price0 = (0 - i.value).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
            let d0 = PriceInfoDisplayStyle(attributeTitle: att0, attributePrice: price0, showLine: false, edge: .zero)
            styles.append(d0)
        })
        
        if (quoteCart.discountAmount ?? 0) > 0 {
            let att5 = Text.promotion.localizedText.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            let price5 = (0 - (quoteCart.discountAmount ?? 0)).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
            let d5 = PriceInfoDisplayStyle(attributeTitle: att5, attributePrice: price5, showLine: false, edge: .zero)
            styles.append(d5)
        }
        
        let desPayment = quoteCart.quotePayments?.first?.paymentMethodDes ?? ""
        let d5 = PriceInfoDisplayStyle(attributeTitle: desPayment.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (quoteCart.grandTotal?.currency ?? "").attribute >>> .font(f: .systemFont(ofSize: 20, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: true, edge: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        styles.append(d5)
        
        detailPriceView.setupDisplay(item: styles)
    }
}
