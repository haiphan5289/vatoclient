//
//  DetailMerchantCell.swift
//  Vato
//
//  Created by HaiPhan on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class DetailMerchantCell: UITableViewCell {

    @IBOutlet weak var addressText: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var imvStatus: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addressText.text = ""
        lblName.text = ""
        lblStatus.text = ""
        imvStatus.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(from store: Store) {
        lblName.text = store.name
        addressText.text = store.address
                
        if let status = StoreStatus.init(rawValue: store.status ?? 0) {
            self.lblStatus.text = status.stringValue()
            self.lblStatus.textColor = status.getTextColor()
            self.imvStatus.image = status.getIcon()
        }
    }
    
}
