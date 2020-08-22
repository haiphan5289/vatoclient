//
//  CheckOutPaymentTVC.swift
//  Vato
//
//  Created by khoi tran on 4/21/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class CheckOutPaymentTVC: UITableViewCell, UpdateDisplayProtocol {

    @IBOutlet var lblName: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupDisplay(item: PaymentCardDetail?) {
        guard let item = item else { return }
        
        lblName?.text = item.brand
    }
    
}
