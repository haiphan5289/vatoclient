//  File name   : TopupRow.swift
//
//  Author      : Dung Vu
//  Created date: 11/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Eureka


struct TopupCellModel: Equatable {
    let item: TopupLinkConfigureProtocol
    
    var card: Card?
    
    static func ==(lhs: TopupCellModel, rhs: TopupCellModel) -> Bool {
        return lhs.item.type == rhs.item.type
    }
}

final class TopupCell: Cell<TopupCellModel>, CellType {
    
    // MARK: Class's public methods
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
        
    }
    
    override func setup() {
        super.setup()
        
        // General setup
        height = { return 64.0 }
        backgroundColor = .white
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil
        
        borderImageView >>> contentView >>> {
            $0.backgroundColor = EurekaConfig.separatorColor
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(15.0)
                $0.trailing.equalToSuperview()
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview()
            }
        }
        
        bankSelectView >>> contentView >>> {
            $0.isExclusiveTouch = true
            $0.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalTo(borderImageView.snp.leading)
                $0.trailing.equalTo(borderImageView.snp.trailing)
                $0.bottom.equalTo(borderImageView.snp.top)
            }
        }
    }
    
    override func update() {
        super.update()
        selectionStyle = .none
        accessoryType = .none
        accessoryView = nil
        if row.value?.item is DummyMethodProtocol {
            bankSelectView.iconImg?.image = UIImage(named: row.value?.item.iconURL ?? "")
        } else {
            if let url = URL.init(withOptional: row.value?.item.iconURL) {
                bankSelectView.urlImage = url
            } else {
                bankSelectView.iconImg?.image = UIImage(named: row.value?.card?.placeHolder ?? "")
            }
            
            
        }
        	
        bankSelectView.title = row.value?.item.name
    }
    
    
    
    /// Class's private properties.
    private lazy var borderImageView = UIImageView(image: nil)
    private (set)lazy var bankSelectView = BankSelectControl(with: nil, title: nil, isSelected: false, arrow: true)
}


final class TopupRow: Row<TopupCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
    }
    
    func hide(arrow hidding: Bool) {
        cell.bankSelectView.arrowImg?.isHidden = hidding
    }
}

extension URL {
     init?(withOptional path: String?) {
        guard let v = path else {
            return nil
        }
        self.init(string: v)
    }
}
