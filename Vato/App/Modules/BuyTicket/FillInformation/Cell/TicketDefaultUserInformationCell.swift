//
//  TicketDefaultUserInformationCell.swift
//  Vato
//
//  Created by khoi tran on 5/7/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import Eureka
import RxSwift
import UIKit


final class TicketDefaultUserInformationCell: Eureka.Cell<String>, CellType, UpdateDisplayProtocol {
    
    private var lblName = UILabel(frame: .zero)
    private var lblPhone = UILabel(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        visualize()
        setupRX()
    }
    
    override func setup() {
        super.setup()
        height = { 80 }
    }
    
    func visualize() {
        
        lblName >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(8)
                make.left.equalTo(16)
                make.right.equalTo(-16)
            }
        }
        
        lblPhone >>> contentView >>> {
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(lblName.snp.bottom).offset(4)
                make.left.equalTo(16)
                make.right.equalTo(-16)
            }
        }
    }
    
    func setupDisplay(item: String?) {
        
    }
    
    func display(name: String?, phone: String?) {
        lblName.text = name
        lblPhone.text = phone
    }
    
    func setupRX() {
        
    }
    
    
}
