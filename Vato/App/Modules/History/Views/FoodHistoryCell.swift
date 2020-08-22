//
//  FoodHistoryCell.swift
//  Vato
//
//  Created by khoi tran on 1/8/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class FoodHistoryCell: UITableViewCell, UpdateDisplayProtocol {

    @IBOutlet private var timeLabel: UILabel?
    @IBOutlet private var statusLabel: UILabel?
    @IBOutlet private var originLabel: UILabel?
    @IBOutlet private var destLabel: UILabel?
    @IBOutlet private var serviceLabel: UILabel?
    @IBOutlet private var lblPreOrder: UILabel?
    @IBOutlet var btnPreOrder: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblPreOrder?.text = Text.preorder.localizedText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDisplay(item: SalesOrder?) {
        display(model: item)
    }
    
    func display(model: BookingHistoryProtocol?) {
        guard let model = model else { return }
        self.timeLabel?.text = (model.dateCreate?.string(from: "HH:mm dd/MM/yyyy") ?? "") + " • " + (model.code ?? "")
        self.statusLabel?.text = model.statusStr
        self.statusLabel?.textColor = model.statusColor
        self.serviceLabel?.text = (model.serviceName ?? "") + " • " + (model.priceStr ?? "")
        
        if model.originLocation?.isEmpty == true{
            self.originLabel?.text = Text.unknown.localizedText
            self.originLabel?.textColor = .gray
        } else {
            self.originLabel?.text = model.originLocation
            self.originLabel?.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        if model.destLocation?.isEmpty == true{
            self.destLabel?.text = Text.unknown.localizedText
            self.destLabel?.textColor = .gray
        } else {
            self.destLabel?.text = model.destLocation
            self.destLabel?.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        }
        
        
        
    }
    
}
