//
//  PromotionDetailCell.swift
//  FaceCar
//
//  Created by Dung Vu on 10/25/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import UIKit

final class PromotionDetailCell: UITableViewCell {
    @IBOutlet weak var lblDescription: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func set(_ text: String?) {
        let p = NSMutableParagraphStyle()
        p.lineSpacing = 3
        p.alignment = .left
        lblDescription?.attributedText = text?.attribute
            >>> .font(f: .systemFont(ofSize: 14, weight: .regular))
            >>> .paragraph(p: p)
            >>> .color(c: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1))
    }
   
}
