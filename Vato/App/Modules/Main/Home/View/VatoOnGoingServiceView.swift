//  File name   : VatoOnGoingServiceView.swift
//
//  Author      : Dung Vu
//  Created date: 5/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import Atributika

final class VatoOnGoingServiceView: UIView, UpdateDisplayProtocol, VatoSegmentChildProtocol {
    var isSelected: Bool = false
    
    /// Class's public properties.
    
    /// Class's private properties.
    private lazy var iconView: UIImageView = UIImageView(frame: .zero)
    private lazy var lblDescription: UILabel = UILabel(frame: .zero)
    private lazy var containerView: UIView = UIView(frame: .zero)
    private lazy var arrowView: UIImageView = UIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = containerView.bounds.height
        containerView.layer.cornerRadius = h / 2
    }
    
    func setupDisplay(item: VatoHomeGroupEventGoing?) {
        iconView.image = UIImage(named: item?.service.icon ?? "")
        let b = Atributika.Style("b").foregroundColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)).font(UIFont.systemFont(ofSize: 14, weight: .semibold))
        let all = Atributika.Style.foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).font(UIFont.systemFont(ofSize: 14, weight: .regular))
        let att = item?.description.style(tags: b).styleAll(all).attributedString
        lblDescription.attributedText = att
    }
}

// MARK: Class's private methods
private extension VatoOnGoingServiceView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        backgroundColor = .white
        containerView >>> self >>> {
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.07)
            $0.clipsToBounds = true
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        iconView >>> containerView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(10)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 30, height: 30))
            }
        }
        
        arrowView >>> containerView >>> {
            $0.image = UIImage(named: "ic_form_more")
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(-8)
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
        }
        
        lblDescription >>> containerView >>> {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints { (make) in
                make.right.equalTo(arrowView.snp.left).offset(-8)
                make.centerY.equalToSuperview()
                make.left.equalTo(iconView.snp.right).offset(8)
            }
        }
    }
}
