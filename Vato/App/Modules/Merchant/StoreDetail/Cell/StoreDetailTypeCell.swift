//
//  StoreDetailTypeCell.swift
//  Vato
//
//  Created by khoi tran on 11/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class StoreDetailTypeCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameLabel.text = ""
        self.statusLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(data: StoreDetailCellData) {
        self.iconImageView.image = UIImage(named: data.image ?? "")
        self.nameLabel.text = data.name
        
        if let status = StoreStatus.init(rawValue: data.status ??  1) {
            self.statusLabel.textColor = status.getTextColor()
            self.statusLabel.text = status.stringValue()
        }
    }
}
