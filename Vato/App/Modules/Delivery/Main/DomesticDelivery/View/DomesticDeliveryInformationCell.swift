//
//  DomesticDeliveryInformationCell.swift
//  Vato
//
//  Created by khoi tran on 1/2/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

class DomesticDeliveryInformationCell: DeliveryInformationCell {
    
    lazy var priceInfoLabel = UILabel(frame: .zero)
    
    override func updateData(item: DestinationDisplayProtocol?) {
        super.updateData(item: item)
        if let item = item , item.description.count > 0 {
            height = { 100 }
        }
    }
    
    override func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        imageView?.isHidden = true
        
        containerView >>> contentView >>> {
            $0.backgroundColor = .clear
            $0.cornerRadius = 8
            $0.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.2)
            
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(8)
                make.bottom.equalTo(-16)
                make.right.equalTo(-8)
            })
        }
        
        backgroundImageView >>> containerView >>> {
            $0.contentMode = .scaleToFill
            $0.image = UIImage(named: "bg_add_photo")
            $0.alpha = 0.5
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        addressLabel >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.text = Text.addShippingAddress.localizedText //Text.deliveryTitleAdressReceiver.localizedText
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(2)
                make.left.equalTo(40)
                make.right.equalTo(-40)
            })
        }
        
        userInformationLabel >>> containerView >>> {
            $0.isHidden = true
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(40)
                make.top.equalTo(addressLabel.snp.bottom).offset(8)
            })
        }
        
        priceInfoLabel >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.text = "Giao siêu tốc • 50,000đ"
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(40)
                make.top.equalTo(userInformationLabel.snp.bottom).offset(8)
            })
        }
        
        leftIconButton >>> containerView >>> {
            $0.setImage(UIImage(named: "ic_booking_delivery_add"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalTo(addressLabel.snp.centerY)
                make.left.equalTo(0)
                make.width.equalTo(32)
                make.height.equalTo(32)
            })
        }
        rightIconButton >>> containerView >>> {
            $0.tintColor = .white
            $0.backgroundColor = UIColor(red: 0, green: 97/255, blue: 61/255, alpha: 1.0)
            $0.setImage(UIImage(named: "ic_delivery_add"), for: .normal)
            $0.cornerRadius = 12
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-8)
                make.width.equalTo(24)
                make.height.equalTo(24)
            })
        }
        
    }
}
