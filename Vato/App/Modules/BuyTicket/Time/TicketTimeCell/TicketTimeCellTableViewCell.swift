//
//  TicketTimeCellTableViewCell.swift
//  Vato
//
//  Created by vato. on 10/3/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit
import Eureka

class TicketTimeCellTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var availableLable: UILabel!
    @IBOutlet private weak var kindLabel: UILabel!
    @IBOutlet private weak var iconView: UIImageView?
    var vDiscountTicket: ViewDiscountTicket = ViewDiscountTicket.loadXib()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        vDiscountTicket >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(timeLabel)
//                make.width.equalTo(55)
                make.height.equalTo(15)
                make.left.equalTo(kindLabel.snp.right).inset(-30)
            }
        }
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        iconView?.isHidden = !selected
        // Configure the view for the selected state
    }
    
    func setupDisplay(model: TicketSchedules?, timeType: TimeDataGroup.TimeType) {
        self.timeLabel.text = model?.time
        self.kindLabel.text = "(\(model?.kind ?? "" ))"
        self.backgroundColor = timeType.colorBgType
        self.vDiscountTicket.backgroundColor = .clear
        if let valueDiscount = model?.promotion?.value, let type = model?.promotion?.type {
            self.vDiscountTicket.lbDiscount.text = (type == .PERCENT) ? "-\(String(valueDiscount))%" : "-\(valueDiscount.currency)"
            self.vDiscountTicket.isHidden = false
        } else {
            self.vDiscountTicket.isHidden = true
        }
    }
    
}
