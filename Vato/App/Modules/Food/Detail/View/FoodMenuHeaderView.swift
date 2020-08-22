//  File name   : FoodMenuHeaderView.swift
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

final class FoodMenuHeaderView: UIView, DisplayStoreShortProtocol, UpdateDisplayProtocol, DisplayPromotionProtocol {
    @IBOutlet var lblDistance: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var lblOpen: UILabel?
    @IBOutlet var lblClose: UILabel?

    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblCategory: UILabel?
    /// Class's public properties.
    @IBOutlet var containerView: UIView!
    private var iconAuthView: UIImageView?
    /// Class's private properties.
    var topView: FoodDetailHeaderView?
    private var lblDescription: UILabel?
    
    @IBOutlet var viewDiscount: UIStackView?
    @IBOutlet var lblDiscount: UILabel?
    @IBOutlet var btnShowPromotion: UIButton?
    @IBOutlet var imagePromotionView: UIImageView?
    
    func setupDisplay(item: FoodExploreItem?) {
        lblTitle?.text = item?.name
        lblCategory?.text = item?.descriptionCat
        display(item: item)
        displayPromotion(item: item?.storeProductDiscountInformation)
        btnShowPromotion?.isHidden = item?.salesRule == nil
        if let closeString = item?.workingHours?.getCloseTime(), !closeString.isEmpty {
            lblClose?.text = "(đến \(closeString))"
        }
        
        iconAuthView?.isHidden = item?.infoStoreVerify == nil
        iconAuthView?.setImage(from: item?.infoStoreVerify, placeholder: nil, size: CGSize(width: 24, height: 24))
        
        lblDescription?.text = item?.infoStoreVerify?.label
        lblDescription?.textColor = item?.infoStoreVerify?.color
    }
}

// MARK: Class's public methods
extension FoodMenuHeaderView {
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
private extension FoodMenuHeaderView {
    private func initialize() {
        // todo: Initialize view's here.
        backgroundColor = .white
        let topView = FoodDetailHeaderView.loadXib()
        topView >>> containerView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        self.topView = topView
        
        let lblDescription = UILabel(frame: .zero)
        lblDescription >>> {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        }
        
        let iconView = UIImageView(frame: .zero)
        iconView >>> {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24, height: 24))
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: [lblDescription, iconView])
        stackView >>> self >>> {
            $0.distribution = .fill
            $0.axis = .horizontal
            $0.spacing = 5
            
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(containerView.snp.bottom).offset(-3)
            }
        }
        self.iconAuthView = iconView
        self.lblDescription = lblDescription
    }
    private func visualize() {
        // todo: Visualize view's here.
        
    }
}
