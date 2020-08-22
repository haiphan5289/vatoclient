//
//  ConfirmBookingServiceMoreCell.swift
//  Vato
//
//  Created by MacbookPro on 11/15/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

enum ImageCheck: String {
    case check = "ic_form_checkbox_checked"
    case uncheck = "ic_form_checkbox_uncheck"
    case checkFalse = "ic_form_checkbox_checked_false"
    
    func getImg() -> UIImage? {
        switch self {
        case .check:
            return UIImage(named: rawValue)
        case .uncheck:
            return UIImage(named: rawValue)
        case .checkFalse:
            return UIImage(named: rawValue)
        }
    }
    
    var text: String {
        return rawValue
    }
}

class ConfirmBookingServiceMoreCell: UITableViewCell {

    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblPriceService: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    private var isChangeable = true
    @IBOutlet weak var heightBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if isChangeable {
            imgCheck.image = (selected == true) ? ImageCheck.check.getImg() : ImageCheck.uncheck.getImg()
        }
    }
    
    func visualizeCell(model: AdditionalServices) {
        self.isChangeable = model.changeable ?? true
        self.lblContent.text = model.name
        
        
        if let type = model.type {
            switch type {
            case .FLAT:
                self.lblPriceService.text = String(Int(model.amount ?? 0).currency)
            case .PERCENT:
                self.lblPriceService.text = String(Int(model.amount ?? 0)) + "%"
            }
        } else {
            fatalError("Parse error")
        }
        
        if isChangeable {
            lblContent.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        } else {
            imgCheck.image = ImageCheck.checkFalse.getImg()
            lblContent.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            
        }
        
//        if let count = model.name?.count {
//            self.heightBottom.isActive = (count < 1) ? true : false
//        }
        
    }
    
    
    
}
