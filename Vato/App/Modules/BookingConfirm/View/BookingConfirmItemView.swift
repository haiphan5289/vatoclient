//
//  BookingConfirmItemView.swift
//  FaceCar
//
//  Created by Dung Vu on 9/27/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import UIKit

protocol BookingConfirmUpdateUIProtocol {
    func update(from type: BookingConfirmUpdateType)
}

final class BookingConfirmItemView: UIView, BookingConfirmUpdateUIProtocol {
    var type: BookingConfirmType = .none {
        didSet {
            icon?.image = type.icon
            icon?.highlightedImage = type.iconH
            lblDescription?.text = type.defaultValue
        }
    }

    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var iconStatus: UIImageView?
    @IBOutlet weak var lblDescription: UILabel?
    @IBOutlet weak var lineLeftView: UIView?
    @IBOutlet weak var btnAction: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func update(from type: BookingConfirmUpdateType) {
        switch type {
        case .update(let string, let exist):
            self.lblDescription?.text = string ?? self.type.defaultValue
            self.icon?.isHighlighted = exist
            guard self.type == .coupon else {
                return
            }
            self.iconStatus?.isHidden = !exist
        default:
            break
        }
    }

    static func createView(with type: BookingConfirmType) -> BookingConfirmItemView {
        let view = BookingConfirmItemView.loadXib()
        view.type = type
        return view
    }
}
