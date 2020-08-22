//
//  InTripHeaderView.swift
//  Vato
//
//  Created by Dung Vu on 3/13/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit

enum InTripHeaderViewState {
    case minmal
    case max
    
    var radius: CGFloat {
        switch self {
        case .max:
            return .zero
        case .minmal:
            return 7
        }
    }
    
    var alpha: CGFloat {
        switch self {
        case .max:
            return 1
        case .minmal:
            return 0.8
        }
    }
}

final class InTripHeaderView: UIView {
    @IBOutlet var lblMessage : UILabel?
    @IBOutlet var bgView : UIView?
    private lazy var shapeLayer: CAShapeLayer = CAShapeLayer()
    private (set) var type = InTripHeaderViewState.minmal
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.mask = shapeLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.path = generatePath().cgPath
        bgView?.alpha = type.alpha
    }
    
    private func generatePath() -> UIBezierPath {
        let bezier = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: type.radius * 2, height: type.radius * 2))
        return bezier
    }
    
    func update(state: InTripHeaderViewState) {
        type = state
    }
}
