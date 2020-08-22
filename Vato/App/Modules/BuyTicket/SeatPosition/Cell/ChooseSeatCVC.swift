//
//  ChooseSeatCVC.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

enum SeatType {
    case active
    case none
    case choose
    
    var imageName: String {
        switch self {
        case .active:
            return "ic_chair_active"
        case .none:
            return "ic_chair_none"
        case .choose:
            return "ic_chair_choose"
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .active:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .none:
            return #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        case .choose:
            return #colorLiteral(red: 0.937254902, green: 0.3254901961, blue: 0.1333333333, alpha: 1)
        }
    }
    
    
}

class ChooseSeatCVC: UICollectionViewCell {
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    var vDiscountTicket: ViewDiscountTicket = ViewDiscountTicket.loadXib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vDiscountTicket >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.bottom.equalTo(contentImageView.snp.top).inset(10)
                make.right.equalTo(contentImageView)
                make.height.equalTo(15)
                make.left.equalTo(contentImageView)
            }
        }
//        self.vDiscountTicket.isHidden = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentImageView.image = nil
        lblTitle.text = nil
    }

    func visulizeCell(with item: SeatModel?, isSelected: Bool = false) {
        guard let item = item else {
            contentImageView.image = nil
            lblTitle.text = nil
            self.vDiscountTicket.isHidden = true
            return
        }
        let bookStatus = item.bookStatus ?? 0
        let lockChair = item.lockChair ?? 0
        let inSelect = item.inSelect ?? 0
        let isSelectable = bookStatus == 0 && lockChair == 0 && inSelect == 0
        
        lblTitle.text = item.chair
        
        if isSelected {
            if isSelectable {
                contentImageView.image = UIImage(named: SeatType.choose.imageName)
                lblTitle.textColor = SeatType.choose.titleColor
            } else {
                contentImageView.image = UIImage(named: SeatType.active.imageName)
                lblTitle.textColor = SeatType.active.titleColor
            }
        } else {
            if isSelectable {
                contentImageView.image = UIImage(named: SeatType.none.imageName)
                lblTitle.textColor = SeatType.none.titleColor
            } else {
                contentImageView.image = UIImage(named: SeatType.active.imageName)
                lblTitle.textColor = SeatType.active.titleColor
            }
        }
        if let valueDiscount = item.promotion?.value, let type = item.promotion?.type, (isSelectable == true){
            self.vDiscountTicket.isHidden = false
            self.vDiscountTicket.lbDiscount.text = (type == .PERCENT) ? "-\(String(valueDiscount))%" : "-\(String(item.promotion?.valueResize ?? 0))K"
        } else {
            self.vDiscountTicket.isHidden = true
        }
    }
}
