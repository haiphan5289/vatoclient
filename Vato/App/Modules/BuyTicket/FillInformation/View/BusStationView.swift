//
//  BusStationView.swift
//  Vato
//
//  Created by khoi tran on 5/5/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import SnapKit


class BusStationView: UIView, UpdateDisplayProtocol, VatoSegmentChildProtocol {
    
    let containerView: UIView = UIView(frame: .zero)
    let lblDescription: UILabel = UILabel(frame: .zero)
    let lblAddress: UILabel = UILabel(frame: .zero)
    let lblPrice = UILabel(frame: .zero)
    let lbPriceDiscount = UILabel(frame: .zero)
    let imvSelected = UIImageView(frame: .zero)
    let vDiscount: ViewDiscountTicket = ViewDiscountTicket.loadXib()
    let vLine: UIView = UIView(frame: .zero)
    let vLineDiscount: UIView = UIView(frame: .zero)
    let bgColor: UIColor
    
    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                self.imvSelected.image = UIImage(named: "ic_check")
                self.containerView.backgroundColor = .white
                self.lblDescription.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            } else {
                self.imvSelected.image = UIImage(named: "ic_uncheckedbox")
                self.containerView.backgroundColor = bgColor
                self.lblDescription.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            }
        }
    }
    
    init(frame: CGRect, bgColor: UIColor) {
        self.bgColor = bgColor
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
//        textLabel?.isHidden = true
//        selectionStyle = .none
        
        self.backgroundColor = .clear
        containerView.backgroundColor = self.bgColor

        self.snp.makeConstraints { (make) in
            make.height.equalTo(81)
        }
        
        containerView >>> self >>> {
            $0.cornerRadius = 5
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
            }
        }
        
        imvSelected >>> containerView >>> {
            $0.image = UIImage(named: "ic_uncheckedbox")
            $0.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
                make.width.equalTo(22)
                make.height.equalTo(22)
            }
        }
        
        lblDescription >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.numberOfLines = 2
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(self.imvSelected.snp.right).inset(-16)
                make.top.equalTo(12)
                make.width.equalTo(200)
            }
        }
        
        lblPrice >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.textAlignment = .right
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.top.equalTo(12)
                make.left.equalTo(lblDescription.snp.right).offset(4)
                
            }
        }
        
        lblAddress >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.numberOfLines = 2
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(lblDescription)
                make.top.equalTo(lblDescription.snp.bottom).offset(6)
                make.right.equalTo(-100)
            }
        }
        
        lbPriceDiscount >>> containerView >>> {
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(lblPrice)
                make.top.equalTo(lblAddress)
            }
        }
        
        vLineDiscount >>> containerView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.right.centerY.equalTo(lbPriceDiscount)
                make.height.equalTo(1)
            }
        }
        
        vDiscount >>> containerView >>> {
            $0.backgroundColor = .clear
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(15)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(8)
            }
        }
        vLine >>> containerView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(lblDescription)
                make.bottom.right.equalToSuperview()
                make.height.equalTo(1)
            }
        }

    }
    
    func setupDisplay(item: TicketRoutes?) {
        self.lblDescription.text = item?.name
        self.lblAddress.text = item?.name
        if let promotion = item?.promotion, let value = promotion.value, let type = promotion.type {
            self.vDiscount.lbDiscount.text = "-" + ((type == .PERCENT) ? String(value) + "%" : value.currency)
            self.lblPrice.text = (item?.finalPrice ?? 0).currency
            self.lbPriceDiscount.text = item?.price?.currency
            self.vDiscount.isHidden = false
        } else {
            self.vDiscount.isHidden = true
            self.lbPriceDiscount.text = ""
            self.lblPrice.text = item?.price?.currency
        }
    }
    
    func updateView(index: Int) {
        
    }
}

