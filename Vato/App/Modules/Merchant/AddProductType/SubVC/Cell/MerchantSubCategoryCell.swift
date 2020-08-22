//
//  File.swift
//  Vato
//
//  Created by khoi tran on 11/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation


import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import Kingfisher


enum MerchantSubCategoryCellType: Equatable {
    case node
    case leafNode
}

class MerchantSubCategoryCell: UITableViewCell {
    
    var iconImageView: UIImageView
    var titleLabel: UILabel
    var isParentCategorySelected: Bool = false
    var type: MerchantSubCategoryCellType = .leafNode
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iconImageView = UIImageView(frame: .zero)
        titleLabel = UILabel(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        
        if selected {
            self.contentView.backgroundColor = UIColor(red: 253/255, green: 237/255, blue: 232/255, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            switch type {
            case .node:
                
                break
            case .leafNode:
                self.iconImageView.image = UIImage(named: "ic_check")
                break
            }
        } else {
            titleLabel.textColor = UIColor(red: 99/255, green: 118/255, blue: 128/255, alpha: 1.0)
            
            if !isParentCategorySelected {
                self.contentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
            } else {
                self.contentView.backgroundColor = UIColor(red: 255/255, green: 246/255, blue: 244/255, alpha: 1.0)

            }
            
            switch type {
            case .node:
                
                break
            case .leafNode:
                self.iconImageView.image = UIImage(named: "ic_uncheck")
                break
            }
        }
        
    }
    
    
    private func visualize() {
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        self.contentView.clipsToBounds = true
        self.clipsToBounds = true
        
        titleLabel >>> contentView >>> {
            $0.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.text = ""
            $0.numberOfLines = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.bottom.equalTo(-16).priority(.high)
            })
        }
        
        iconImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
//            $0.image = UIImage(named: "ic_uncheck")
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(18)
                make.height.equalTo(18)
                make.left.equalTo(titleLabel.snp.right).offset(8).priority(.high)
                make.right.equalTo(-16).priority(.high)
            })
        }
        
        
    }
    
    func setupData(category: MerchantCategory, isParentCategorySelected: Bool, level: Int = 1, type: MerchantSubCategoryCellType) {
        self.isParentCategorySelected  = isParentCategorySelected
        self.type = type
        
        titleLabel.text = category.name
        
        titleLabel.snp.updateConstraints { (make) in
            make.left.equalTo(16*level)
        }
        
        switch type {
        case .node:
            iconImageView.image = UIImage(named: "ic_dropdown")
        case .leafNode:
            iconImageView.image = UIImage(named: "ic_uncheck")
            
        }
    }
    
}

extension MerchantMainCategoryCell {
    
    
}
