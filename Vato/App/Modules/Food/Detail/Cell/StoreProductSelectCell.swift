//  File name   : StoreProductSelectCell.swift
//
//  Author      : Dung Vu
//  Created date: 11/22/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class StoreProductSelectCell: StoreProductCell<DisplayProduct>, LoadDummyProtocol {
    private (set) var editView: StoreEditControl!
    private (set) var btnEdit: UIButton!
    private lazy var disposeBag = DisposeBag()
    private (set) lazy var lblQuantity: UILabel = UILabel(frame: .zero)
    private lazy var lblSpecialPrice: UILabel = UILabel(frame: .zero)
    
    override func visualize() {
        super.visualize()
        contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 128, bottom: 0, right: 0), position: .bottom)
        let editView = StoreEditControl(frame: .zero)
        editView.setContentHuggingPriority(.required, for: .horizontal)
        editView.setContentCompressionResistancePriority(.required, for: .horizontal)
        editView.isSelected = false
        
        editView >>> {
            $0.isHidden = true
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.snp.makeConstraints({ (make) in
                make.height.equalTo(24)
            })
        }
        self.editView = editView
        lblPrice >>> {
            $0?.lineBreakMode = .byTruncatingMiddle
            $0?.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        lblQuantity >>>  {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.textColor = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        }
        
        let s1 = UIStackView(arrangedSubviews: [lblPrice, lblQuantity, editView])
        s1 >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.alignment = .bottom
            $0.spacing = 5
        }
        
        let s2 = UIStackView(arrangedSubviews: [lblSpecialPrice, s1])
        s2 >>> contentView >>> {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 0
            
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(stackView.snp.left)
                make.bottom.right.equalTo(-8)
            }
        }
        
        setupRX()
    }
    
    private func setupRX() {}
    
    func loadDummyView() {
        if let imageView = self.productImageView {
            LoadingShimmerView.startAnimate(in: imageView)
        }
        if let lblTitle = self.lblTitle, let lblDescription = lblDescription {
            lblTitle.text = "hello"
            lblDescription.text = "welcome"
            LoadingShimmerView.startAnimate(in: lblTitle)
            LoadingShimmerView.startAnimate(in: lblDescription)
        }
        self.editView.isHidden = true
    }
    
    func stopLoadDummyView() {}
    
    func display(item: DisplayProduct, number: BasketStoreValueProtocol?) {
        self.editView.isSelected = number != nil
        let number = number?.quantity ?? 0
        self.lblQuantity.text = number > 0 ? "x\(number)" : ""
    }
    
    override func setupDisplay(item: DisplayProduct?) {
        super.setupDisplay(item: item)
        let isSpecial = item?.isAppliedSpecialPrice ?? false
        lblSpecialPrice.isHidden = !isSpecial
        let text = item?.productPrice?.currency ?? ""
        let att = text.attribute >>>
            .font(f: UIFont.systemFont(ofSize: 12, weight: .regular)) >>> .color(c: Color.battleshipGrey) >>> .strike(v: 1)
        lblSpecialPrice.attributedText = att
    }
}

