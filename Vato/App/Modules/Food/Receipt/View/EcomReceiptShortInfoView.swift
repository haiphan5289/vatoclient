//  File name   : EcomReceiptShortInfoView.swift
//
//  Author      : Dung Vu
//  Created date: 3/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class EcomReceiptShortInfoView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblTime : UILabel?
    @IBOutlet var lblCode : UILabel?
    @IBOutlet var lblStatusTitle : UILabel?
    @IBOutlet var lblStatus : UILabel?
    /// Class's private properties.
    override func awakeFromNib() {
        super.awakeFromNib()
        lblStatusTitle?.text = "Trạng thái"
    }
    
    func setupDisplay(item: SalesOrder?) {
        lblTime?.text = String.makeStringWithoutEmpty(from: "Thời gian:", item?.dateCreate?.string(from: "HH:mm dd/MM/yyyy") , seperator:" ")
        lblCode?.text = "Mã đơn: \(item?.code?.uppercased() ?? "")"
        lblStatus?.text = item?.state?.stringValue.uppercased()
        lblStatus?.textColor = item?.state?.color
    }
}


