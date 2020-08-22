//
//  FoodItemCVC.swift
//  Vato
//
//  Created by Dung Vu on 10/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

final class FoodItemCVC: UICollectionViewCell, UpdateDisplayProtocol, DisplayDistanceProtocol, DisplayPromotionProtocol, LazyDisplayImageProtocol {
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblDistance: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var lblDiscount: UILabel?
    @IBOutlet var stackView: UIStackView?
    @IBOutlet var iconAuthView: UIImageView?
    @IBOutlet var viewDiscount: UIStackView?
    @IBOutlet var imagePromotionView: UIImageView?
    private var item: DisplayShortDescriptionProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupDisplay(item: DisplayShortDescriptionProtocol?) {
        self.item = item
        lblTitle?.text = item?.name
        displayDistance(item: item)
        displayPromotion(item: item?.storeProductDiscountInformation)
        stackView?.isHidden = true
        iconAuthView?.superview?.isHidden = item?.infoStoreVerify == nil
    }
    
    func displayImage() {
        imageView?.setImage(from: item, placeholder: nil, size: CGSize(width: 152, height: 76))
        iconAuthView?.setImage(from: item?.infoStoreVerify, placeholder: nil, size: CGSize(width: 24, height: 24))
    }

}
