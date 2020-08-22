//
//  TimeSelectionCell.swift
//  Vato
//
//  Created by khoi tran on 12/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import Eureka
import FwiCore
import FwiCoreRX
import SnapKit

final class TimeSelectionCell: Eureka.Cell<DateTime>, CellType, UpdateDisplayProtocol {
    
    private lazy var titleLabel = UILabel(frame: .zero)
    private lazy var dateTimeLabel = UILabel(frame: .zero)
    private (set)lazy var schedulerButton = UIButton(frame: .zero)
    
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
    
        titleLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.text = Text.deliveryTime.localizedText
            $0.snp.makeConstraints({ (make) in
                make.top.left.equalTo(16)
            })
        }
        
        schedulerButton >>> contentView >>> {
            $0.setTitleColor(#colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1), for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .bold)
            $0.setTitle(Text.scheduler.localizedText.uppercased(), for: .normal)
            $0.setImage(UIImage(named: "ic_food_clock"), for: .normal)
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-16)
            })
        }
        
        dateTimeLabel >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.text = "--"
            $0.numberOfLines = 2
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.bottom.equalTo(-16)
                make.right.equalTo(schedulerButton.snp.left).offset(-8)
            })
        }
    }
    
    func setupDisplay(item: DateTime?) {
        guard let dateTime = item else {
            dateTimeLabel.text = Text.asSoonAsPossible.localizedText
            return
        }
        
        dateTimeLabel.text = dateTime.string()
    }
}


extension TimeSelectionCell {
    func setupRX() {
        
    }
}
