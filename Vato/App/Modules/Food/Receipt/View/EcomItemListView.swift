//  File name   : EcomItemListView.swift
//
//  Author      : Dung Vu
//  Created date: 3/31/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class EcomItemListView: UIView,UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var imageView : UIImageView?
    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblNote : UILabel?
    @IBOutlet var lblPrice : UILabel?
    @IBOutlet var lblNumber : UILabel?
    /// Class's private properties.
    func setupDisplay(item: OrderItem?) {
        imageView?.setImage(from: item, placeholder: nil, size: CGSize(width: 48, height: 48))
        lblNote?.text = item?.description
        lblPrice?.text = item?.basePriceInclTax?.currency
        lblTitle?.text = item?.name
        lblNumber?.text = "x\(item?.qty ?? 0)"
    }
}


