//
//  TicketDetailTableViewCell.swift
//  Vato
//
//  Created by HaiPhan on 10/5/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class TicketDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var hLbDataInfor: NSLayoutConstraint!
    @IBOutlet weak var lblLocationPickUp: UILabel!
    @IBOutlet weak var lbDataInfor: UILabel!
    @IBOutlet weak var lbInfor: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lbInfor.text = "Họ và tên"
        lbDataInfor.text = "Nguyễn Phan Tùng Dương"
        lblLocationPickUp.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
