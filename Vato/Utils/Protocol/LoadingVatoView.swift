//  File name   : LoadingVatoView.swift
//
//  Author      : Dung Vu
//  Created date: 12/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

final class VatoLoadingView: UIView {
    private lazy var loadingView = LoadingView(frame: .zero)
    private lazy var lblLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        visualize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        backgroundColor = .clear
        layer.cornerRadius = 14
        clipsToBounds = true
        
        let blurView: UIView
        
        if #available(iOS 11, *) {
            let effect = UIBlurEffect(style: .light)
            blurView = UIVisualEffectView(effect: effect)
        } else {
            backgroundColor = .white
            blurView = UIView(frame: .zero)
            blurView.backgroundColor = .white
        }
        
        blurView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        loadingView >>> self >>> {
            $0.backgroundColor = .clear
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: 60, height: 60))
                make.center.equalToSuperview()
            })
        }
        
        lblLabel >>> self >>> {
            $0.textColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            $0.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
        }
    }
    
    func showProgress(_ progress: Float, status: String?) {
        let run = {
            self.alpha = 1
            self.loadingView.showProgress(progress)
            self.lblLabel.text = status
        }
        if self.isHidden {
            isHidden = false
            UIView.animate(withDuration: 0.2, animations: run)
        } else {
            run()
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (completed) in
            guard completed else { return }
            self.loadingView.showProgress(0)
            self.isHidden = true
        }
    }
    
    static func load(on view: UIView?) -> VatoLoadingView? {
        guard let view = view else { return nil }
        if let current = view.viewWithTag(68490) as? VatoLoadingView {
            return current
        } else {
            let new = VatoLoadingView(frame: .zero)
            new.tag = 68490
            new >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.center.equalToSuperview()
                    make.size.equalTo(CGSize(width: 80, height: 80))
                })
            }
            return new
        }
    }
}

extension VatoLoadingView: LoadingViewProtocol {
    static func showProgress(_ progress: Float, status: String?) {
        let keyWindow = UIApplication.shared.keyWindow
        guard let loadingView = VatoLoadingView.load(on: keyWindow) else {
            assert(false, "check!!!")
            return
        }
        keyWindow?.bringSubviewToFront(loadingView)
        loadingView.showProgress(progress, status: status)
    }
    
    static func dismiss() {
        let keyWindow = UIApplication.shared.keyWindow
        guard let loadingView = VatoLoadingView.load(on: keyWindow) else {
            assert(false, "check!!!")
            return
        }
        loadingView.dismiss()
    }
}


@IBDesignable
final class LoadingView: UIView {
    private var shape: CAShapeLayer?
    func showProgress(_ progress: Float) {
        shape?.strokeEnd = CGFloat(progress)
    }
}

// MARK: Class's public methods
extension LoadingView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Prevent empty context
        
        let shape = createShape(with: rect, offset: 2, colorFill: .clear, colorStroke: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.2), lineWidth: 2, startDegree: -90, endDegree: 270, progress: 1)
        layer.addSublayer(shape)
        
        let shape1 = createShape(with: rect, offset: 2, colorFill: .clear, colorStroke: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), lineWidth: 2, startDegree: -90, endDegree: 270, progress: 0)
        layer.addSublayer(shape1)
        self.shape = shape1
        
        let shape2 = createShape(with: rect, offset: 10, colorFill: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.2), colorStroke: .clear, lineWidth: 0.5, startDegree: -90, endDegree: 270, progress: 1)
        layer.addSublayer(shape2)
        // todo: Implement custom draw here.
    }
    
    func degreesToRadians(angle: CGFloat) -> CGFloat {
        return angle / 180 * CGFloat.pi
    }
    
    func createShape(with rect: CGRect,
                     offset: CGFloat,
                     colorFill: UIColor,
                     colorStroke: UIColor,
                     lineWidth: CGFloat,
                     startDegree: CGFloat,
                     endDegree: CGFloat,
                     progress: CGFloat) -> CAShapeLayer
    {
        let radius = min(rect.width - offset, rect.height - offset) / 2
        let s = degreesToRadians(angle: startDegree)
        let e = degreesToRadians(angle: endDegree)
        let inset = rect.inset(by: UIEdgeInsets(top: offset, left: offset, bottom: offset, right: offset))
        let benzier = UIBezierPath(arcCenter: CGPoint(x: inset.midX, y: inset.midY), radius: radius, startAngle: s, endAngle: e, clockwise: true)
        
        let shape = CAShapeLayer()
        shape.fillColor = colorFill.cgColor
        shape.path = benzier.cgPath
        shape.lineWidth = lineWidth
        shape.strokeColor = colorStroke.cgColor
        shape.lineJoin = .round
        shape.lineCap = .round
        shape.strokeEnd = progress
        return shape
    }
}
