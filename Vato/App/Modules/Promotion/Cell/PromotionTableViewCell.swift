//
//  PromotionTableViewCell.swift
//  FaceCar
//
//  Created by Dung Vu on 10/23/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import UIKit
import Kingfisher

final class PromotionTableViewCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView?
    @IBOutlet weak var lblTile: UILabel?
    @IBOutlet weak var lblDescription: UILabel?
    @IBOutlet weak var btnAction: UIButton?
    @IBOutlet weak var leftConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // recalculate left
        let ratio: CGFloat = (UIScreen.main.bounds.width / 320) - 1
        var current: CGFloat = leftConstraint?.constant ?? 0
        current = current + current * ratio + 5//(ratio != 0 ? 5 : 0)
        
        leftConstraint?.constant = current
        self.contentView.layoutSubviews()
        
        // Initialization code
        btnAction?.setTitleColor(Color.orange, for: .normal)
        btnAction?.setTitle(PromotionConfig.bookTitle, for: .normal)
        iconView?.kf.indicatorType = .activity
        iconView?.image = UIImage(named: PromotionConfig.promotionIcon)
    }
    
    func setup(from model: PromotionDisplayProtocol) {
        let manifest = model.manifest
        lblTile?.text = manifest?.title
        lblDescription?.text = "\(PromotionConfig.validTo)\(model.state.endDate.string())"
        iconView?.setImage(from: manifest, placeholder: UIImage(named: PromotionConfig.promotionIcon), size: CGSize(width: 88, height: 88))
    }
}
