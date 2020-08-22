//  File name   : WalletDisplayItemView.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit

fileprivate final class WalletDisplayItemView: UIView {
    /// Class's public properties.
    private (set)var lblContent: UILabel?
    private (set)var lblSubTitle: UILabel?
    
    init(with title: String?, subTitle: String?) {
        super.init(frame: .zero)
        commonSetup()
        self.lblContent?.text = title
        self.lblSubTitle?.text = subTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Class's private properties.
    private func commonSetup() {
        let lblContent = UILabel.create {
            $0.font = UIFont.boldSystemFont(ofSize: 18)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.top.equalTo(16)
                })
        }
        
        self.lblContent = lblContent
        
        let lblSubTitle = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textColor = #colorLiteral(red: 0.3843137255, green: 0.4431372549, blue: 0.4980392157, alpha: 1)
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.bottom.equalTo(-12)
                })
        }
        
        self.lblSubTitle = lblSubTitle
    }
}

final class WalletInformationView: UIView {
    private var views: [WalletDisplayItemView]?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonSetup() {
        self.backgroundColor = .clear
        UIImageView(image: UIImage(named: "bg_topup")) >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalTo(UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8))
            })
        }
        
        let views = [WalletDisplayItemView(with: 0.currency, subTitle: Text.balance.localizedText),
                     WalletDisplayItemView(with: 0.currency, subTitle: Text.pendingApproval.localizedText)]
        self.views = views
         UIStackView(arrangedSubviews: views) >>> {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            } >>> self >>> {
                $0.snp.makeConstraints({ (make) in
                    make.edges.equalToSuperview()
                })
        }
        
        UIView.create {
            $0.backgroundColor = #colorLiteral(red: 0.8745098039, green: 0.8823529412, blue: 0.9019607843, alpha: 1)
        } >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.width.equalTo(1)
                make.top.equalTo(24)
                make.bottom.equalTo(-26)
                make.centerX.equalToSuperview()
            })
        }
        
    }
    
    func setValue(with response: WalletResponse) {
        self.views?.lazy.first?.lblContent?.text = response.cash.currency
        self.views?.lazy.last?.lblContent?.text = response.coin.currency
    }
}

