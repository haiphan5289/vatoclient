//
//  TicketDetailRouteCell.swift
//  Vato
//
//  Created by MacbookPro on 5/15/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

class TicketDetailRouteCell: UITableViewCell {

    @IBOutlet weak var imgAddress: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var imgDot: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUIFirstRow(model: DetailRoute) {
        self.lbName.text = model.name
        self.lbAddress.text = model.address
        self.lbTime.text = Text.start.localizedText
    }
    
    func updateUI(model: DetailRoute, departureDate: String, departureTime: String) {
        
        self.lbName.text = model.name
        self.lbAddress.text = model.address
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="dd-MM-yyyy HH:mm"
        dfmatter.timeZone = TimeZone.current
        dfmatter.locale = Locale(identifier: "vi_VN")
        if let date = dfmatter.date(from: departureDate + " " + departureTime) {
            let dateStamp: Double = Double(date.timeIntervalSince1970)
            let timeRoute = (Double(model.duration)  * 60) + dateStamp
            let dateConvert = Date(timeIntervalSince1970: timeRoute)
            let hour = Calendar.current.component(.hour, from: dateConvert)
            let minutes = Calendar.current.component(.minute, from: dateConvert)
            
            if hour == 0 && minutes == 0 {
                self.lbTime.text = ""
            } else {
                self.lbTime.text = String(format: "%dh%dp", hour, minutes)
            }
        }
    }
}
