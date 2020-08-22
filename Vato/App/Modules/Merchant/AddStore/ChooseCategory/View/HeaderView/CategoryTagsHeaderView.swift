//
//  ChooseCategoryHeaderView.swift
//  Vato
//
//  Created by khoi tran on 11/5/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import FwiCore
import FwiCoreRX
import RxSwift
import SnapKit


class CategoryTagsHeaderView: UIView {
    struct Configs {
        static var PlaceholderText = "Tìm kiếm danh mục"
    }
    
    private (set) lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    
    private (set) lazy var searchImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()
    
    private (set) lazy var searchTextField: UITextField = {
        let textfield = UITextField(frame: .zero)
        return textfield
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.visualize()
        self.setupRX()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func visualize() {
        bgView >>> self >>> {
            $0.borderWidth = 1.0
            $0.borderColor = UIColor(red: 192/255, green: 198/255, blue: 204/255, alpha: 0.3)
            $0.cornerRadius = 6
            $0.backgroundColor = UIColor(red: 192/255, green: 198/255, blue: 204/255, alpha: 0.2)
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        searchImageView >>> self >>> {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_food_search_text")
            $0.snp.makeConstraints({ (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(8)
                make.width.equalTo(16)
                make.height.equalTo(16)
            })
        }
        
        searchTextField >>> self >>> {
            let att = Configs.PlaceholderText.attribute >>> AttributeStyle.color(c: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)) >>> .font(f: UIFont.systemFont(ofSize: 15, weight: .regular))
            $0.attributedPlaceholder = att
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.textColor = .black
            $0.borderStyle = .none
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
                make.left.equalTo(searchImageView.snp.right).offset(8)
            })
        }
    }
    
    func setupRX() {
        
    }
 
}
