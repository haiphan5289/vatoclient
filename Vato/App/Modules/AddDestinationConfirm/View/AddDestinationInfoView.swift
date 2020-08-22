//  File name   : DestinationInfoView.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

enum AddDestinationType {
    case original
    case destination
    case index(idx: Int, last: Bool)
    
    var title: String? {
        switch self {
        case .original:
            return "Điểm đến cũ"
        case .destination:
            return "Điểm đến mới"
        case .index(_ , let last):
            return last ? "\(Text.inTripAddDestination.localizedText):" : "\(Text.releaseAt.localizedText):"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .original:
            return UIImage(named: "ic_destination_o")
        case .destination:
            return UIImage(named: "ic_destination_d")
        default:
            return UIImage(named: "ic_destination_edit")
        }
    }
    
    var index: String? {
        switch self {
        case .index(let idx, _):
            return "\(idx)"
        default:
            return nil
        }
    }
    
    func atrributeTitle(from text: String) -> NSAttributedString {
        switch self {
        case .original:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 13, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            return att
        case .destination:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 13, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
            return att
        case .index:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 13, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
            return att
        }
    }
    
    func atrributeSubtitle(from text: String) -> NSAttributedString {
        assert(!text.isEmpty, "Check")
        switch self {
        case .original:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 16, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            return att
        case .destination:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 16, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
            return att
        case .index:
            let att = text.attribute >>> .font(f: UIFont.systemFont(ofSize: 16, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
            return att
        }
    }
}

final class AddDestinationInfoView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblAddress : UILabel?
    @IBOutlet var lblIndex: UILabel?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var imageDotView: UIImageView?
    /// Class's private properties.
    
    func setupDisplay(item: DestinationPoint?) {
        let title = item?.type.title ?? item?.address.name
        let att = item?.type.atrributeTitle(from: title ?? "")
        lblTitle?.attributedText = att
        let address = item?.address
        let sub = item?.type.atrributeSubtitle(from: address?.subLocality.orEmpty(address?.name ?? "") ?? "")
        lblAddress?.attributedText = sub
        imageView?.image = item?.type.icon
        lblIndex?.text = item?.type.index
        imageDotView?.isHidden = item?.showDots == false
    }
}

// MARK: Class's public methods
extension AddDestinationInfoView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
    
    func update(hiddenLine: Bool) {
        imageView?.isHidden = hiddenLine
    }
}

// MARK: Class's private methods
private extension AddDestinationInfoView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
