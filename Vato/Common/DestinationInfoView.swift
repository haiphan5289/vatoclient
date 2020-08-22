//  File name   : DestinationInfoView.swift
//
//  Author      : Futa Corp
//  Created date: 1/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

fileprivate class InTripAddressView: UIView {
    private let image: UIImage?
    private let name: String
    private let sizeIcon: CGSize
    private let spacing: CGFloat
    
    private (set) var lblTile: UILabel?
    private (set) var imageView: UIImageView?
    
    init(image: UIImage?, name: String, sizeIcon: CGSize, spacing: CGFloat) {
        self.spacing = spacing
        self.image = image
        self.name = name
        self.sizeIcon = sizeIcon
        super.init(frame: .zero)
        prepareLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareLayout() {
        let lblTile = UILabel.create {
            $0.font = UIFont.systemFont(ofSize: 15.0)
            $0.text = name
        }
        lblTile.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lblTile.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.lblTile = lblTile
        let imageView = UIImageView(image: image) >>> { $0.contentMode = .scaleAspectFit; $0.snp.makeConstraints { $0.size.equalTo(sizeIcon) } }
        self.imageView = imageView
        
        UIStackView(arrangedSubviews: [imageView, lblTile]) >>> {
            $0.spacing = spacing
            $0.axis = .horizontal
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        } >>> self >>> { $0.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview().priority(.high)
        }) }
    }
    
}

final class DestinationInfoView: UIView {
    /// Class's public properties.
    struct Dummy {
        static let placesDummy: [String] = ["131 Tô Hiến Thành", "198 Cách Mạng Tháng 8"]
    }
    var placeNames: [String] {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            visualize()
        }
    }

    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(with edges: UIEdgeInsets, placeNames: [String] = Dummy.placesDummy) {
        self.placeNames = placeNames
        self.edges = UIEdgeInsets(top: 15.0, left: edges.left, bottom: 15.0, right: edges.right)
        super.init(frame: .zero)
        initialize()
        visualize()
    }

    /// Class's private properties.
    private let edges: UIEdgeInsets
}


// MARK: Class's private methods
private extension DestinationInfoView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    
    private func dashView() -> UIView {
        let v = UIView() >>> {
            let path = CGMutablePath()
            path.addLines(between: [CGPoint(x: 8.0, y: 4.0), CGPoint(x: 8.0, y: 18.0)])
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path
            lineLayer.lineWidth = 1.0
            lineLayer.lineDashPattern = [4,4]
            lineLayer.strokeColor = Color.battleshipGrey.cgColor
            
            $0.layer.addSublayer(lineLayer)
            $0.backgroundColor = UIColor.clear
            $0.snp.makeConstraints { $0.height.equalTo(20.0) }
        }
        return v
    }
    
    private func visualize() {
        let views = placeNames.enumerated().reduce([UIView]()) { (current, i) -> [UIView] in
            var temp = current
            let image: UIImage = i.offset == 0 ? #imageLiteral(resourceName: "ic_origin") : #imageLiteral(resourceName: "ic_destination_new")
            let height = i.offset == 0 ? 16.0 : 19.0
            let s = CGSize(width: 16.0, height: height)
            let addressView = InTripAddressView(image: image, name: i.element, sizeIcon: s, spacing: 12)
            addressView.snp.makeConstraints({ (make) in
                make.height.equalTo(s.height)
            })
            if i.offset > 0 { temp.append(dashView()) }
            temp.append(addressView)
            return temp
        }
        
        let stackView = UIStackView(arrangedSubviews: views)
        stackView >>> self >>> {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.snp.makeConstraints {
                $0.top.equalTo(edges.top)
                $0.left.equalTo(edges.left)
                $0.right.equalTo(-edges.right).priority(.high)
                $0.bottom.equalTo(-edges.bottom)
            }
        }
    }
}
