//
//  TicketPickupAddressCell.swift
//  Vato
//
//  Created by khoi tran on 4/27/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka
import FwiCoreRX
import FwiCore
import SnapKit

final class TicketEditInfoCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    
    private let lblTitle = UILabel(frame: .zero)
    private let lblDescription = UILabel(frame: .zero)
    private (set) lazy var editView: StoreEditControl = StoreEditControl(frame: .zero)

    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    override func setup() {
        super.setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        textLabel?.isHidden = true
        selectionStyle = .none
        
        lblTitle >>> self >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.4623882771, green: 0.5225807428, blue: 0.5743968487, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.right.equalTo(-80)
            }
        }
        
        lblDescription >>> self >>> {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1)
            $0.numberOfLines = 2
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.top.equalTo(lblTitle.snp.bottom).offset(8)
                make.right.equalTo(-80)
                make.bottom.equalTo(-16)
            }
        }
        
        editView.isSelected = true
        editView >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.centerY.equalToSuperview()                
                make.height.equalTo(24)
            }
        }
    }
    
    func setupDisplay(item: String?) {
        self.lblDescription.text = item
    }
    
    func updateView(title: String?) {
        self.lblTitle.text = title
    }

}
