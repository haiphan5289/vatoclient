//
//  DeliveryInformationCell.swift
//  Vato
//
//  Created by khoi tran on 11/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import SnapKit
import RxSwift
import FwiCore

class DeliveryInformationCell: Eureka.Cell<DeliveryInputInformation>, CellType, UpdateDisplayProtocol {
    lazy var containerView = UIView(frame: .zero)
    lazy var backgroundImageView: UIImageView = UIImageView(frame: .zero)
    lazy var titleLabel = UILabel(frame: .zero)
    lazy var addressLabel = UILabel(frame: .zero)
    lazy var leftIconButton = UIButton(frame: .zero)
    lazy var rightIconButton = UIButton(frame: .zero)
    lazy var userInformationLabel = UILabel(frame: .zero)
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
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
        
        titleLabel >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.text = Text.deliveryTitleAdressReceiver.localizedText
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(12)
                make.left.equalTo(40)
            })
        }
        
        addressLabel >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.text = Text.addShippingAddress.localizedText
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.left.equalTo(40)
                make.right.equalTo(-40)
            })
        }
        
        userInformationLabel >>> containerView >>> {
            $0.isHidden = true
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.snp.makeConstraints({ (make) in
                //                make.top.equalTo(addressLabel.snp.bottom).offset(4)
                make.left.equalTo(40)
                make.bottom.equalTo(-12)
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
    
    func setupRX() {
        
    }
    
    override func setup() {
        super.setup()
        //        height = { 100 }
    }
    
    func setupDisplay(item: DeliveryInputInformation?) {
        
    }
    
    func updateData(item: DestinationDisplayProtocol?) {
        if let item = item , item.description.count > 0 {
            userInformationLabel.text = item.description
            addressLabel.text = item.originalDestination?.subLocality
            
            self.backgroundImageView.isHidden = true
            rightIconButton.setImage(UIImage(named: "ic_delivery_minus"), for: .normal)
            rightIconButton.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.2)
            rightIconButton.tintColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)  
            containerView.backgroundColor = .white
            userInformationLabel.isHidden = false
            
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(4)
                make.bottom.equalTo(-4)
            }
            height = { 93 }
        } else {
            
            userInformationLabel.text = ""
            userInformationLabel.isHidden = true
            
            addressLabel.text = Text.addShippingAddress.localizedText
            
            self.backgroundImageView.isHidden = false
            
            rightIconButton.setImage(UIImage(named: "ic_delivery_add"), for: .normal)
            rightIconButton.backgroundColor =  UIColor(red: 0, green: 97/255, blue: 61/255, alpha: 1.0)
            rightIconButton.tintColor = .white
            
            containerView.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.2)
            
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(16)
                make.bottom.equalTo(-16)
            }
            
            height = { 100 }
        }
    }
    
}


class ShoppingDeliveryInformationCell: DeliveryInformationCell {
    
    override func visualize() {
        super.visualize()
        
        titleLabel.text = Text.addShoppingAddressTitle.localizedText
        leftIconButton.setImage(UIImage(named: "ic_origin"), for: .normal)
        leftIconButton.snp.updateConstraints { (make) in
            make.left.equalTo(8)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        containerView.backgroundColor = UIColor(red: 0, green: 97/255, blue: 61/255, alpha: 0.2)

    }
    
    override func updateData(item: DestinationDisplayProtocol?) {
        if let item = item , item.description.count > 0 {
            userInformationLabel.text = item.description
            addressLabel.text = item.title
            
            self.backgroundImageView.isHidden = true
            rightIconButton.setImage(UIImage(named: "ic_delivery_minus"), for: .normal)
            rightIconButton.backgroundColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 0.2)
            rightIconButton.tintColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            containerView.backgroundColor = .white
            userInformationLabel.isHidden = false
            
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(4)
                make.bottom.equalTo(-4)
            }
            height = { 93 }
        } else {
            
            userInformationLabel.text = ""
            userInformationLabel.isHidden = true
            
            addressLabel.text = Text.addShoppingAddress.localizedText
            
            self.backgroundImageView.isHidden = false
            
            rightIconButton.setImage(UIImage(named: "ic_delivery_add"), for: .normal)
            rightIconButton.backgroundColor =  UIColor(red: 0, green: 97/255, blue: 61/255, alpha: 1.0)
            rightIconButton.tintColor = .white
            
            containerView.backgroundColor = UIColor(red: 0, green: 97/255, blue: 61/255, alpha: 0.2)

            
            containerView.snp.updateConstraints { (make) in
                make.top.equalTo(16)
                make.bottom.equalTo(-16)
            }
            
            height = { 100 }
        }
    }
}
