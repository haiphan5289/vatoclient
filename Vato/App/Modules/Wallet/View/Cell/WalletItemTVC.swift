//  File name   : WalletItemTVC.swift
//
//  Author      : Dung Vu
//  Created date: 12/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit

protocol WalletItemDisplayProtocol {
    var increase: Bool { get }
    var title: String? { get }
    var description: String? { get }
    var amount: Double { get }
    var id: Int { get }
    var transactionDate: Double { get }
}

extension WalletItemDisplayProtocol {
    var prefix: String {
        guard amount > 0 else {
            return ""
        }
        return increase ? "+" : "-"
    }
    
    var color: UIColor {
        return increase ? #colorLiteral(red: 0, green: 0.4235294118, blue: 0.2392156863, alpha: 1) : #colorLiteral(red: 0.8823529412, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
    }
}

final class WalletItemTVC: UITableViewCell {

    private var lblTitle: UILabel?
    private var lblDescription: UILabel?
    private var lblPrice: UILabel?
    
    /// Class's public properties.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup() {
        let arrow = UIImageView(image: UIImage(named: "ic_chevron_right")) >>> self.contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.right.equalTo(-24)
                make.size.equalTo(CGSize(width: 4.5, height: 9))
                make.centerY.equalToSuperview()
            })
        }
        
        let lblTitle = UILabel.create {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16)
            } >>> self.contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(12)
                    make.right.equalTo(arrow).offset(-5).priority(.high)
                })
        }
        
        self.lblTitle = lblTitle
        
        let lblDescription = UILabel.create {
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 12)
            } >>> self.contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(lblTitle.snp.left)
                    make.top.equalTo(lblTitle.snp.bottom).offset(5)
                    make.right.equalToSuperview()
                })
        }
        self.lblDescription = lblDescription
        
        let lblPrice = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textAlignment = .right
            } >>> self.contentView >>> {
                $0.snp.makeConstraints({ (make) in
                    make.right.equalTo(arrow.snp.left).offset(-9)
                    make.centerY.equalToSuperview()
                })
        }
        self.lblPrice = lblPrice
        
    }

    
    func setupDisplay(by item: WalletItemDisplayProtocol) {
        self.lblPrice?.textColor = item.color
        self.lblPrice?.text = "\(item.prefix)\(item.amount.currency)"
        self.lblTitle?.text = item.title
        self.lblDescription?.text = item.description
        self.contentView.layoutSubviews()
        let delta = (self.lblPrice?.bounds.width ?? 0) + 42
        self.lblDescription?.snp.updateConstraints({ (make) in
            make.right.equalTo(-delta)
        })
        
        
    }
}
