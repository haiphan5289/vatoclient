
//
//  ProductMenuHeaderView.swift
//  Vato
//
//  Created by khoi tran on 12/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Kingfisher


class ProductMenuHeaderView: UIView, UpdateDisplayProtocol {    
    
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialize()
        self.setupRX()
    }
    
    func setupDisplay(item: DisplayProduct?) {
        guard let product = item else {
            return
        }
        
        productImageView.setImage(from: product)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.visualize()
    }
}

extension ProductMenuHeaderView {
    private func initialize() {
        topContentView.clipsToBounds = true

    }
    
    private func visualize() {
        let rect = topContentView.bounds
        let ratio = min(rect.height / 200, 1)
        if ratio < 0.5 {
            topContentView.layer.mask = nil
        } else {
            let v = 16 * ratio
            let benzier = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: v, height: v))
            let shape = CAShapeLayer()
            shape.frame = rect
            shape.fillColor = UIColor.blue.cgColor
            shape.path = benzier.cgPath
            topContentView.layer.mask = shape
        }
    }
    
    func setupRX() {
    }
}

