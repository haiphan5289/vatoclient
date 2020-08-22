//
//  NotePakageSizeTableViewCell.swift
//  Vato
//
//  Created by THAI LE QUANG on 8/15/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

@IBDesignable
final class NotePakageSizeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentImage: UIImageView?
    @IBOutlet weak var lbTitle: UILabel?
    @IBOutlet weak var lbPrice: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentImage?.image = self.isSelected ? UIImage(named: "ic_check") : UIImage(named: "ic_uncheck")
    }
    
    func visulizeCell(with item: OptionDeliveryModel) {
        lbTitle?.text = item.option
        lbPrice?.text = "\(item.price.cleanValue)đ"
    }
}
