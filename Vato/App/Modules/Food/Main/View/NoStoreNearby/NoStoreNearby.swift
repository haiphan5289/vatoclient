//
//  NoStoreNearby.swift
//  Vato
//
//  Created by khoi tran on 4/15/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import FwiCore
import SnapKit

class NoStoreNearby: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private lazy var imvError: UIImageView = UIImageView(frame: .zero)
    private lazy var lblError: UILabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        self.backgroundColor = .white
        lblError >>> self >>> {
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.textColor = UIColor.init(red: 99/255, green: 114/255, blue: 128/255, alpha: 1.0)
            $0.text = Text.noStoreNearby.localizedText
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(194)
                make.left.equalTo(24)
                make.right.equalTo(-24)
            }
        }
        
        imvError >>> self >>> {
            $0.image = UIImage(named: "ic_food_noItem")
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(lblError.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.width.equalTo(90)
                make.height.equalTo(120)
            }
        }
        
    }
}
