//
//  DeliveryVehicleCollectionViewCell.swift
//  Vato
//
//  Created by khoi tran on 11/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation


class DeliveryVehicleCollectionViewCell: UICollectionViewCell {
    
    lazy var iconImageView = UIImageView(frame: .zero)
    lazy var nameLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                nameLabel.textColor = UIColor(red: 239/255, green: 82/255, blue: 34/255, alpha: 1.0)
            } else {
                nameLabel.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            }
        }
    }
}

extension DeliveryVehicleCollectionViewCell {
    func initialize() {
        iconImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.centerX.equalToSuperview()
                make.width.equalTo(40)
                make.height.equalTo(40)
            })
        }
        
        nameLabel >>> contentView >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.textAlignment = .center
            $0.snp.makeConstraints({ (make) in
                make.bottom.equalTo(-16)
                make.centerX.equalToSuperview()
            })
        }
    }
}
