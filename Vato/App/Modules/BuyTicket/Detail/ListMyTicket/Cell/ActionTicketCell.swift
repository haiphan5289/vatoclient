//
//  ActionTicketCell.swift
//  Vato
//
//  Created by HaiPhan on 10/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ActionTicketCell: UITableViewCell {

    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var imgICon: UIImageView!
    @IBOutlet weak var lbHotLine: UILabel!
    @IBOutlet weak var wLbTitle: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lbHotLine.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
