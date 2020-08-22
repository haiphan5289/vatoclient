//  File name   : HistoryExpressSectionView.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import SnapKit

final class HistoryExpressSectionView: UIControl {
    /// Class's public properties.
    let item: HistoryExpressSection
    private lazy var lblTitle: UILabel = UILabel(frame: .zero)
    /// Class's private properties.
    init(item: HistoryExpressSection) {
        self.item = item
        super.init(frame: .zero)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Class's public methods
extension HistoryExpressSectionView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension HistoryExpressSectionView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        let style = item.type.style
        if style.seperator {
            self.addSeperator()
            addSeperator(with: .zero, position: .top)
        }
        backgroundColor = style.background
        lblTitle >>> self >>> {
            $0.font = style.font
            $0.textColor = style.textColor
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-8).priority(.high)
            }
        }
        
        lblTitle.text = item.type == .title ? item.title : "\(item.title ?? "") (\(item.items.count))"
        isUserInteractionEnabled = item.type != .title
        guard item.type == .expand else {
            return
        }
        let imageView = UIImageView(image: UIImage(named: "ic_history_expand"))
        imageView >>> self >>> {
            $0.contentMode = .center
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-16)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    
}
