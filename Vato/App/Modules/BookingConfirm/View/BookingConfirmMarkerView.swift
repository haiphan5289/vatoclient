//  File name   : BookingConfirmMarkerView.swift
//
//  Author      : Dung Vu
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

enum MarkerViewType {
    case start
    case end

    var icon: UIImage {
        switch self {
        case .start:
            return #imageLiteral(resourceName: "ic_origin_booking_marker")
        case .end:
            return #imageLiteral(resourceName: "ic_destination_booking_marker")
        }
    }

    var title: String {
        switch self {
        case .start:
            return Text.pickupAt.localizedText.uppercased()
        case .end:
            return Text.releaseAt.localizedText.uppercased()
        }
    }

    var defaultText: String {
        switch self {
        case .start:
            return Text.locationStart.localizedText
        case .end:
            return Text.locationEnd.localizedText
        }
    }
}

@IBDesignable
final class BookingConfirmMarkerView: UIView {
    /// Class's public properties.
    @IBOutlet weak var iconView: UIImageView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblMessage: UILabel?
    @IBOutlet weak var containerView: UIView?
    /// Class's private properties.

    struct MarkerViewConfigTranform {
        static let delta: CGFloat = 65
    }

    static func load(from address: AddressProtocol?, type: MarkerViewType) -> BookingConfirmMarkerView {
        let v = self.loadXib()
        v.iconView?.image = type.icon
        v.lblTitle?.text = type.title
        let message = address?.subLocality//address?.primaryText.contains(Text.unnamedRoad.localizedText) == false ? address?.primaryText : type.defaultText
        v.lblMessage?.text = message
        v.layoutSubviews()
        return v
    }

    func canTap(at pointMarker: CGPoint?, tap at: CGPoint?) -> Bool {
        // pointMarker --> center
        // point --> point tap
        guard let at = at, let pointMarker = pointMarker else {
            return false
        }

        let h = self.bounds.height
        let delta = self.containerView?.transform.ty ?? 0
        let sContainer = self.containerView?.frame.size ?? .zero
        let nextPoint = CGPoint(x: pointMarker.x - sContainer.width / 2 + delta, y: pointMarker.y - h)
        let nextRect = CGRect(origin: nextPoint, size: sContainer)

        let result = nextRect.contains(at)

        return result
    }

    func updatePosition(at pointMarker: CGPoint?) {
        guard let pointMarker = pointMarker else {
            return
        }

        let delta = self.containerView?.transform.ty ?? 0
        let sContainer = self.containerView?.frame.size ?? .zero

        let x1 = pointMarker.x - sContainer.width / 2 + delta
        let x2 = pointMarker.x + sContainer.width / 2 + delta

        let nextTransform: CGAffineTransform
        switch (x1 < 0, x2 > UIScreen.main.bounds.width) {
        case (true, _):
            printDebug("Left : \(x1)")
            let next = max(x1, -MarkerViewConfigTranform.delta)
            nextTransform = CGAffineTransform(translationX: -next, y: 0)
        case (_, true):
            printDebug("Right : \(x2)")
            let next = min(x2 - UIScreen.main.bounds.width, MarkerViewConfigTranform.delta)
            nextTransform = CGAffineTransform(translationX: -next, y: 0)
        default:
            nextTransform = CGAffineTransform.identity
        }

        UIView.animate(withDuration: 0.2) {
            self.containerView?.transform = nextTransform
        }
    }
}

// MARK: Class's public methods
extension BookingConfirmMarkerView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension BookingConfirmMarkerView {
    private func initialize() {
        // todo: Initialize view's here.
    }

    private func visualize() {
        // todo: Visualize view's here.
    }
}
