//
//  TrackingOrderItemCell.swift
//  Vato
//
//  Created by khoi tran on 12/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import FwiCore

final class TrackingOrderItemCell: Eureka.Cell<OrderItem>, CellType, UpdateDisplayProtocol {
    
    private var qtyLabel = UILabel(frame: .zero)
    private var nameLabel = UILabel(frame: .zero)
    private var priceLabel = UILabel(frame: .zero)
    private var noteLabel = UILabel(frame: .zero)
    
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
        imageView?.isHidden = true
        
        qtyLabel >>> contentView >>> {
            $0.text = ""
            $0.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.top.left.equalTo(13)
            }
        }
        
        priceLabel >>> contentView >>> {
            $0.text = ""
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .right
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(13)
                make.right.equalTo(-16)
            }
        }
        
        nameLabel >>> contentView >>> {
            $0.text = ""
            $0.numberOfLines = 0
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(13)
                make.left.equalTo(52)
                make.right.equalTo(priceLabel.snp.left).offset(-24)
            }
        }
                
        noteLabel >>> contentView >>> {
            $0.text = ""
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.numberOfLines = 2
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel.snp.bottom).offset(4)
                make.left.equalTo(52)
                make.right.equalTo(priceLabel.snp.left).offset(-16)
                make.bottom.equalTo(-12).priority(.high)
            }
        }
    }
 
    
    func setupDisplay(item: OrderItem?) {
        guard let it = item else { return }
        
        
        noteLabel.text = it.description
        nameLabel.text = it.name
        let price = it.baseRowTotalInclTax ?? 0
        priceLabel.text = price.currency
        
        let qty = it.qty ?? 0
        
        qtyLabel.text = "x\(qty)"
    }
}


final class TrackingInfoHeaderCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    
    private var titleLabel = UILabel(frame: .zero)

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
        imageView?.isHidden = true
        
        titleLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.top.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-6)
            }
        }
    }
    
    func setupDisplay(item: String?) {
        titleLabel.text = item
    }
}


final class TrackingTotalCell: Eureka.Cell<SalesOrder>, CellType, UpdateDisplayProtocol {
    
    private var paymentMethodTitleLabel = UILabel(frame: .zero)
    private var paymentMethodDetailLabel = UILabel(frame: .zero)
    private var paymentMethodDetailConentView = UIView(frame: .zero)
    private var totalPriceLabel = UILabel(frame: .zero)

    
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
        imageView?.isHidden = true
        
        paymentMethodTitleLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.text = Text.pay.localizedText
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.top.left.equalTo(16)
            }
        }
                
        paymentMethodDetailConentView >>> contentView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.cornerRadius = 10
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.top.equalTo(paymentMethodTitleLabel.snp.bottom).offset(4)
                make.height.equalTo(20)
                make.bottom.equalTo(-16)
            }
        }
        
        paymentMethodDetailLabel >>> paymentMethodDetailConentView >>> {
            $0.text = "Cash"
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textAlignment = .center
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.left.equalTo(8)
                make.right.equalTo(-8)
                
            }
        }
        
        totalPriceLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 26, weight: .medium)
            $0.textAlignment = .right
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.centerY.equalToSuperview()
            }
        }
        
    }
    
    func setupDisplay(item: SalesOrder?) {
        
        let price = item?.grandTotal ?? 0
        totalPriceLabel.text = price.currency
        var type: PaymentCardType = .cash
        if let p = item?.salesOrderPayments?.first?.paymentMethod, let t = PaymentCardType(rawValue: p) {
            type = t
        }
        paymentMethodDetailLabel.text = type.generalName.uppercased()
        paymentMethodDetailConentView.backgroundColor = type.color
    }
    
    
}
