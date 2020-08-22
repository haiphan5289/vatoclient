//
//  MerchantItemTableViewCell.swift
//  Vato
//
//  Created by khoi tran on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Kingfisher


class MerchantItemTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.statusLabel.text = ""
        self.merchantNameLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var merchantNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    func setupData(from merchant: MerchantBasic? ) {
        self.merchantNameLabel.text = merchant?.name ?? ""
        if let status = MerchantStatus.init(rawValue: merchant?.status ?? 0) {
            self.statusLabel.text = status.stringValue()
            self.statusLabel.textColor = status.getTextColor()
            self.statusImageView.image = status.getIcon()
        }
        if let avatarUrl = merchant?.avatarUrl {
            let url = URL.init(string: avatarUrl)
            self.iconImageView.kf.setImage(with: url)
        }
    }
}
