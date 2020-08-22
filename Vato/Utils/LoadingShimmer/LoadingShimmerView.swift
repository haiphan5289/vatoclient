//  File name   : LoadingShimmerView.swift
//
//  Author      : Dung Vu
//  Created date: 6/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class LoadingShimmerView: UIView {
    /// Class's public properties.
    private lazy var gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor(white: 0.82, alpha: 1).cgColor,
                                UIColor(white: 0.86, alpha: 1).cgColor,
                                UIColor(white: 0.82, alpha: 1).cgColor]
        g.locations = [0, 0.4, 0.8, 1]
        g.name = "loaderLayer"
        g.startPoint = CGPoint(x: 0.0, y: 0.5)
        g.endPoint = CGPoint(x: 1.0, y: 0.5)
        g.frame = CGRect(origin: .zero, size: self.bounds.size)
        return g
    }()
    /// Class's private properties.
    private var started: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)
        guard started else { return }
        startAnimate()
    }
        
    private func startAnimate() {
        started = true
        gradientLayer.removeAllAnimations()
        let start = CABasicAnimation(keyPath: "startPoint")
        start.duration = 1.2
        start.fromValue = NSValue(cgPoint: CGPoint(x: 0.0, y: 0.5))
        start.toValue = NSValue(cgPoint: CGPoint(x: 0.7, y: 0.5))
        
        let group = CAAnimationGroup()
        group.animations  = [start]//, end]
        group.repeatCount = Float.infinity
        group.duration = 1.2
        group.autoreverses = true
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
        gradientLayer.add(group, forKey: "smartLoader")
    }
    
    func stopAnimate() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
        }) { [weak self](_) in
            self?.removeFromSuperview()
        }
    }
    
    override func removeFromSuperview() {
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
        super.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Class's private methods
private extension LoadingShimmerView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.backgroundColor = #colorLiteral(red: 0.7972653508, green: 0.8179522753, blue: 0.8375228047, alpha: 0.1176904966)
        self.layer.addSublayer(gradientLayer)
    }
}

extension LoadingShimmerView {
    @discardableResult
    static func startAnimate(in view: UIView) -> LoadingShimmerView {
        let shimmerView = LoadingShimmerView(frame: .zero)
        shimmerView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        defer {
            shimmerView.startAnimate()
        }
        return shimmerView
    }
    @discardableResult
    static func addLoadingChildrenShimmerView(in view: UIView) -> [LoadingShimmerView] {
        var loadingViews = [LoadingShimmerView]()
        view.subviews.forEach { (v) in
            let shimmerView = LoadingShimmerView.startAnimate(in: v)
            loadingViews.append(shimmerView)
        }
        return loadingViews
    }
}
