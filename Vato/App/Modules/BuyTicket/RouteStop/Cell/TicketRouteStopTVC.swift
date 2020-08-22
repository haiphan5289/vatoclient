//
//  TicketRouteStopTVC.swift
//  Vato
//
//  Created by khoi tran on 4/28/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class TicketRouteStopTVC: UITableViewCell, UpdateDisplayProtocol {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var imvSelected: UIImageView!

    
    func setupDisplay(item: RouteStop?) {
        guard let item = item else { return }
        
        lblTitle.text = item.name
        lblDescription.text = item.address
    }
    
    
}
