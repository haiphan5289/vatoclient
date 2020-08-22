//
//  CancellationTicketCell.swift
//  Vato
//
//  Created by HaiPhan on 10/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class CancellationTicketCell: UITableViewCell {

    @IBOutlet weak var lbDateFee: UILabel!
    @IBOutlet weak var lbNameRoute: UILabel!
    @IBOutlet weak var lbRoute: UILabel!
    @IBOutlet weak var hLbRoute: NSLayoutConstraint!
    @IBOutlet weak var wLbRout: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lbDateFee.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
