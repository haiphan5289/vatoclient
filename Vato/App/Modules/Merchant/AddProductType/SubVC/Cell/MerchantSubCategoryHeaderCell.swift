//
//  MerchantSubCategoryHeader.swift
//  Vato
//
//  Created by khoi tran on 11/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FwiCore
import FwiCoreRX


public class MerchantSubCategoryHeaderCell: UITableViewCell
{
    lazy var titleLabel: UILabel  = UILabel(frame: .zero)
    lazy var iconImageView: UIImageView = UIImageView(frame: .zero)
    

    private lazy var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
        self.setupRX()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
   
    
 
    private func visualize() {
        
        iconImageView >>> contentView >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_dropdown")
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(-16)
                make.width.equalTo(20)
                make.height.equalTo(20)
            })
        }
        
        titleLabel >>> contentView >>> {
            $0.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.numberOfLines = 2
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(16)
                make.top.equalTo(16)
                make.bottom.equalTo(-16)
                make.right.equalTo(iconImageView.snp.left).offset(-8)
                
            })
        }
        
    }
    
    func setupData(title: String) {
        self.titleLabel.text = title
    }
    
    func setupRX() {
    }
    
    
}
