//  File name   : HeaderHomeView.swift
//
//  Author      : Dung Vu
//  Created date: 8/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import GSKStretchyHeaderView
import SnapKit
import FwiCore

final class HeaderHomeView: GSKStretchyHeaderView {
    /// Class's public properties.

    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        minimumContentHeight = 0
        contentExpands = false
        let view = UIView(frame: .zero)
        view.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
        view >>> contentView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
}


