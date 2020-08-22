//  File name   : StoreProductHeaderView.swift
//
//  Author      : Dung Vu
//  Created date: 11/27/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import GSKStretchyHeaderView
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class StoreProductHeaderView: GSKStretchyHeaderView {
    /// Class's public properties.
    private (set) lazy var view = FoodMenuHeaderView.loadXib()
    private (set) lazy var selectCategoryView = StoreSelectCategoryView(frame: .zero)
    private lazy var titleView: UIView = UIView(frame: .zero)
    private (set) lazy var lblTitle = UILabel(frame: .zero)
    private (set) lazy var vBg = UIView(frame: .zero)
    
    /// Class's private properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        contentView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let edge = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        let statusH: CGFloat
        if #available(iOS 12.0, *) {
            statusH = 0
        } else {
            statusH = UIApplication.shared.statusBarFrame.height
        }
        minimumContentHeight = edge.top + 92 + statusH
        view >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
            })
        }
        view.addSeperator(with: .zero, position: .bottom)
        let spaceView = UIView(frame: .zero)
        spaceView >>> contentView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(view.snp.bottom)
                make.height.equalTo(10)
            })
        }
        
        vBg >>> contentView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(48)
                make.bottom.equalToSuperview().priority(.high)
            })
        }
        contentView.insertSubview(selectCategoryView, aboveSubview: vBg)
        contentView.bringSubviewToFront(selectCategoryView)
        selectCategoryView >>> {
            $0.alpha = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
//                make.top.equalTo(spaceView.snp.bottom)
                make.height.equalTo(48)
                make.bottom.equalToSuperview()
            })
        }
        selectCategoryView.addSeperator(with: .zero, position: .top)
        titleView >>> contentView >>> {
            $0.backgroundColor = .white
            $0.alpha = 0
            $0.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(minimumContentHeight - 48)
            })
        }
        
        lblTitle >>> titleView >>> {
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-10)
                make.width.lessThanOrEqualTo(250)
            })
        }
    }
    
    override func didChangeStretchFactor(_ stretchFactor: CGFloat) {
        super.didChangeStretchFactor(stretchFactor)
        // 0.3 -> 1
        let nexAlpha: CGFloat
        switch stretchFactor {
        case ...0.3:
            nexAlpha = 1 - stretchFactor / 0.3
            UIApplication.setStatusBar(using: .default)
        default:
            nexAlpha = 0
            UIApplication.setStatusBar(using: .lightContent)
        }
        titleView.alpha = nexAlpha
    }
    
    
}

