//
//  ResultTicketPaymentCellInfor.swift
//  Vato
//
//  Created by HaiPhan on 10/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

class ResultTicketPaymentCellInfor: UITableViewCell {

    @IBOutlet weak var hLbDataInfor: NSLayoutConstraint!
    @IBOutlet weak var lbLocationPickUp: UILabel!
    @IBOutlet weak var lbData: UILabel!
    @IBOutlet weak var lbInfor: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lbLocationPickUp.text = "131 Tô Hiến Thành, P.3, TP.Đà Lạt 131 Tô Hiến Thành, P.3, TP.Đà Lạt 131 Tô Hiến Thành, P.3, TP.Đà Lạt "
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
