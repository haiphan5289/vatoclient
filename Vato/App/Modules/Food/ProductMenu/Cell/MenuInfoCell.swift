//
//  MenuInfoCell.swift
//  Vato
//
//  Created by khoi tran on 12/10/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import FwiCore


class MenuInfoCell: Eureka.Cell<DisplayProduct>, CellType, UpdateDisplayProtocol {
   
    var titleLabel: UILabel = UILabel(frame: .zero)
    var descriptionLabel: UILabel = UILabel(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    func visualize() {
        selectionStyle = .none
        textLabel?.isHidden = true
        
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), position: .bottom)
        
        titleLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.snp.makeConstraints({ (make) in
                make.top.left.equalTo(16)
                make.right.equalTo(-16)
            })
        }
        
        descriptionLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 2
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.bottom.equalTo(-16).priority(.high)
            })
        }
    }
}

extension MenuInfoCell {
    func setupDisplay(item: DisplayProduct?) {
        self.titleLabel.text = item?.productName
        self.descriptionLabel.text = item?.productDescription
    }
}


