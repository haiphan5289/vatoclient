//
//  ViewDiscountTicker.swift
//  Vato
//
//  Created by MacbookPro on 6/5/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class ViewDiscountTicket: UIView {

    let imgDiscount: UIImageView = UIImageView(frame: .zero)
    let lbDiscount: UILabel = UILabel(frame: .zero)
    override func awakeFromNib() {
        super.awakeFromNib()

        imgDiscount >>> self >>> {
            $0.image = UIImage(named: "ic_ticket_promotion-new")
            $0.snp.makeConstraints { (make) in
                make.top.bottom.left.right.equalToSuperview()
            }
        }
        
        lbDiscount >>> self >>> {
            $0.textColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            $0.textAlignment = .center
            $0.sizeToFit()
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5
            $0.snp.makeConstraints { (make) in
                make.centerX.centerY.equalToSuperview()
                make.left.equalTo(3)
            }
        }
    }
}
