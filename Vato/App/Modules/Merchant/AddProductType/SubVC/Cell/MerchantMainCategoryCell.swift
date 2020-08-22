//
//  MerchantMainCategoryCell.swift
//  Vato
//
//  Created by khoi tran on 11/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import Kingfisher

class MerchantMainCategoryCell: UITableViewCell {
    
    var iconImageView: UIImageView
    var titleLabel: UILabel

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        iconImageView = UIImageView(frame: .zero)
        titleLabel = UILabel(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.contentView.backgroundColor = UIColor(red: 253/255, green: 237/255, blue: 232/255, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        } else {
            self.contentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 99/255, green: 118/255, blue: 128/255, alpha: 1.0)
            titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        }
        
    }
    
    private func visualize() {
        self.contentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        iconImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.width.equalTo(14)
                make.height.equalTo(14)
                make.left.equalTo(16)
                
            })
        }
        
        titleLabel >>> contentView >>> {
            $0.textColor = UIColor(red: 99/255, green: 118/255, blue: 128/255, alpha: 1.0)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.text = ""
            $0.numberOfLines = 3
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.top.equalTo(16)
                make.right.equalTo(-8)
                make.left.equalTo(iconImageView.snp.right).offset(8)
                make.bottom.equalTo(-16)
            })
        }
    }
    
    func setupData(category: MerchantCategory) {
        if let url = URL(string: category.iconUrl ?? "") {
            iconImageView.kf.setImage(with: url)
        }
        
        titleLabel.text = category.name
    }
    
}

extension MerchantMainCategoryCell {
    
    
}
