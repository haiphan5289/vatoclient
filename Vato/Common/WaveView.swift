//  File name   : WaveView.swift
//
//  Author      : Dung Vu
//  Created date: 1/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class WaveView: UIView {
    private let instanceLayer = CAShapeLayer()
    private let replicatorLayer = CAReplicatorLayer()
    
    private struct Config {
        static let duration: TimeInterval = 3
        static let count: Int = 2
    }
    
    var waveColor: UIColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.5) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderWaveColor: UIColor = Color.orange {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var currentRect: CGRect = .zero {
        didSet {
            setupInstanceLayer(from: currentRect)
            setUpReplicatorLayer()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .clear
        currentRect = rect
    }
    
    private func setupInstanceLayer(from rect: CGRect) {
        instanceLayer.fillColor = waveColor.cgColor
        instanceLayer.frame = rect
        let bezier = UIBezierPath(ovalIn: rect)
        instanceLayer.path = bezier.cgPath
        
        instanceLayer.strokeColor = borderWaveColor.cgColor
        instanceLayer.lineWidth = 1.0
        instanceLayer.strokeEnd  = 1.0
    }
    
    private func setupWaveAnimation() -> CAAnimation {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.1
        scale.toValue = 1
        
        let fade = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        fade.fromValue = 0.0
        fade.toValue = 1
        
        let group = CAAnimationGroup()
        group.animations  = [scale, fade]
        group.repeatCount = Float.infinity
        group.duration = Config.duration
        group.autoreverses = true
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        return group
    }
    
    private func setUpReplicatorLayer() {
        replicatorLayer.removeFromSuperlayer()
        replicatorLayer.frame = self.bounds
        replicatorLayer.instanceCount = Config.count
        
        replicatorLayer.instanceDelay = CFTimeInterval(Config.duration / Double(Config.count))
        replicatorLayer.addSublayer(instanceLayer)
        
        self.layer.addSublayer(replicatorLayer)
        instanceLayer.opacity = 0
        instanceLayer.add(setupWaveAnimation(), forKey: "Animate Group")
    }
}
