//
//  BusStationTableViewCell.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/4/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

final class BusStationTableViewCell: UITableViewCell {

    let lblTitle: UILabel
    let lblSubTitle: UILabel
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        lblTitle = UILabel(frame: .zero)
        lblSubTitle = UILabel(frame: .zero)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblTitle.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        lblSubTitle.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
    }
    
    private func visualize() {
        selectionStyle = .none
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), position: .bottom)
        
        let arrowView  = UIImageView(image: UIImage(named: "ic_chevron_right_ticket"))
        arrowView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
                make.right.equalTo(-8)
            })
        }
        
        lblTitle >>> contentView >>> {
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
            })
        }
        
        lblSubTitle >>> contentView >>> {
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(lblTitle.snp.bottom).offset(6)
                make.right.equalTo(arrowView.snp.left).offset(-10)
                make.bottom.equalTo(-16)
            })
        }
    }
    
    func update(with title: String?, subTitle: String?, distance: Double?, isSeleted: Bool = false) {
        lblTitle.text = title
        lblSubTitle.text = subTitle
        
        guard distance != nil else {
            let colorBus = isSeleted ? #colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.1333333333, alpha: 1) : #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            let colorTrip = isSeleted ? #colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.1333333333, alpha: 1) : #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            lblTitle.textColor = colorBus
            lblSubTitle.textColor = colorTrip
            return
        }
    }

}
