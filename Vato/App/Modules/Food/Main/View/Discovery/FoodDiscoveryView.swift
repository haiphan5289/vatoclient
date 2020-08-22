//  File name   : FoodDiscoveryView.swift
//
//  Author      : Dung Vu
//  Created date: 10/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore

final class FoodDiscoveryView: UIView, UpdateDisplayProtocol, DisplayStaticHeightProtocol, DisplayDistanceProtocol, DisplayPromotionProtocol, LazyDisplayImageProtocol {
    static var height: CGFloat { return 128 }
    static var bottom: CGFloat { return 0 }
    static var automaticHeight: Bool { return true }
    
    /// Class's public properties.
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblSub: UILabel?
    @IBOutlet var lblDistance: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var lblOpen: UILabel?
    @IBOutlet var lblDiscount: UILabel?
    @IBOutlet var viewDiscount: UIStackView?
    @IBOutlet var iconAuthView: UIImageView?
    @IBOutlet var imagePromotionView: UIImageView?
    @IBOutlet var containerBrand: UIView?
    @IBOutlet var lblNumberBrand: UILabel?
    @IBOutlet var btnShowBrand: UIButton?
    
    private var task: TaskExcuteProtocol?
    private var item: FoodExploreItem?
    
    func setupDisplay(item: FoodExploreItem?) {
        self.item = item
        lblTitle?.text = item?.name
        lblSub?.text = item?.descriptionCat
        displayDistance(item: item)
        displayPromotion(item: item?.storeProductDiscountInformation)
        guard let today = FoodWeekDayType.today() else { return }
        if let time = item?.workingHours?.daily?[today] {
            lblOpen?.text = time.openText
            lblOpen?.textColor = time.color
        } else {
            lblOpen?.text = "--"
            lblOpen?.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
        
        iconAuthView?.isHidden = item?.infoStoreVerify == nil
        guard let brand = item?.brand, brand.valid else {
            containerBrand?.isHidden = true
            return
        }
        btnShowBrand?.tag = brand.id
        containerBrand?.isHidden = false
        let text = String(format: FwiLocale.localized("Chuỗi %d cửa hàng"), brand.numStore.orNil(0))
        lblNumberBrand?.text = text
    }
    
    override func removeFromSuperview() {
        task?.cancel()
        super.removeFromSuperview()
    }
    
    func displayImage() {
        iconAuthView?.setImage(from: item?.infoStoreVerify, placeholder: nil, size: CGSize(width: 24, height: 24))
        task = imageView?.setImage(from: item, placeholder: nil, size: CGSize(width: 96, height: 96))
    }

    /// Class's private properties.
}

// MARK: Class's public methods
extension FoodDiscoveryView {
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
private extension FoodDiscoveryView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
