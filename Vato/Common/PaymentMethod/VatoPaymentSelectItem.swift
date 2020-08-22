//  File name   : VatoPaymentSelectItem.swift
//
//  Author      : Dung Vu
//  Created date: 7/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore

final class VatoPaymentSelectItem: UIView, UpdateDisplayProtocol, VatoSegmentChildProtocol {
    /// Class's public properties.
    @IBOutlet var bgView: UIView?
    @IBOutlet var iconMethodView: UIImageView?
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var iconMore: UIImageView?
    @IBOutlet var iconPlus: UIImageView?
    @IBOutlet var btnMoreView: UIButton?
    private lazy var shapeLayer = CAShapeLayer()
    var isSelected: Bool = false {
        didSet {
            let textColor = self.isSelected ? .white : #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            let bgViewColor = self.isSelected ? #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1) : #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.1)
            lblTitle?.textColor = textColor
            shapeLayer.fillColor = bgViewColor.cgColor
            iconMore?.isHighlighted = self.isSelected
        }
    }
    
    var isDisabled: Bool = false {
        didSet {
            self.alpha = self.isDisabled ? 0.5 : 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
    }
    
    private func visualize() {
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [4]
        shapeLayer.fillColor = UIColor.clear.cgColor
        bgView?.layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = bgView?.bounds ?? .zero
        let benzierPath = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        shapeLayer.path = benzierPath.cgPath
    }
    
    func setupDisplay(item: PaymentCardDetail?) {
        guard let i = item else {
            return
        }
        let text: String
        if i.addCard {
            text = i.brand.orNil("")
        } else {
            text = i.localPayment ? i.type.generalName : i.shortDescription
        }
        #if DEBUG
           assert(text.isEmpty == false, "Check")
        #endif
        let color = i.addCard ? #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 0.2) : UIColor.clear
        shapeLayer.strokeColor = color.cgColor
        iconPlus?.isHidden = !i.addCard
        lblTitle?.text = text
        iconMethodView?.image = i.iconSmall
        isSelected = false
        isDisabled = !i.canUse
    }
}


