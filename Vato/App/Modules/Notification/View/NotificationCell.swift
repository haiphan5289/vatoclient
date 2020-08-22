//
//  NotificationCell.swift
//  Vato
//
//  Created by khoi tran on 1/10/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell, UpdateDisplayProtocol {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDisplay(item: NotificationModel?) {
        guard let notify = item else {
            return
        }
        if (notify.type == .manifest || notify.type == .web) {
            logoImageView.image = UIImage(named: "ic_promotion")
        } else {
            logoImageView.image = UIImage(named: "ic_news")
        }
        
        self.titleLabel.text = notify.title
        self.bodyLabel.text = notify.body
        self.createdLabel.text = notify.dateCreate?.string(from: "HH:mm dd/MM/yyyy") ?? ""
    }
    
}
