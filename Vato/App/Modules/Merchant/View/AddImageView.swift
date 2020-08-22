//
//  AddImageView.swift
//  Vato
//
//  Created by khoi tran on 10/23/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import SnapKit

class AddImageView: IconTitleView {
    var backgroundImageView: UIImageView = UIImageView(frame: .zero)
    override func visualize() {
        backgroundImageView >>> self >>> {
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        imageView >>> self >>> {
            $0.contentMode = .top
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
        lblTitle >>> self >>> {
            $0.text = ""
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.textAlignment = .center
            $0.numberOfLines = 1
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.snp.makeConstraints({ (make) in
                make.width.greaterThanOrEqualTo(54)
            })
        }
    }
    
    override func addStackView() {
        let stackView = UIStackView(arrangedSubviews: [imageView, lblTitle])
        stackView >>> self >>> {
            $0.distribution = .fillProportionally
            $0.alignment = .center
            $0.axis = .vertical
            $0.spacing = 5
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(16)
                make.left.equalTo(3)
                make.right.equalTo(-3).priority(.high)
                make.bottom.equalToSuperview().offset(-16).priority(.high)
            })
        }
        
        self.stackView = stackView
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = self.subviews.compactMap ({ $0 as? UIButton}).first {
            if view.frame.contains(point) {
                return view
            }
            return nil
            
        }
        return nil
    }

}

