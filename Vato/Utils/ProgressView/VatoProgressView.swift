//  File name   : VatoProgressView.swift
//
//  Author      : Dung Vu
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore

final class VatoProgressView: UIControl {
    /// Class's public properties.
    private var progress: CGFloat = 0
    private let steps: Int
    private let sizeStep: CGSize
    private var stackView: UIStackView?
    private let image: (imageH: UIImage?, imageN: UIImage?)
    private let spacing: CGFloat
    
    init(steps: Int, sizeStep: CGSize, spacing: CGFloat, imageH: UIImage?, imageN: UIImage?) {
        self.steps = steps
        self.sizeStep = sizeStep
        self.spacing = spacing
        self.image = (imageH, imageN)
        super.init(frame: .zero)
        visualize()
        update(progress: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(progress: CGFloat) {
        let idx = max(Int((CGFloat(steps) * progress).rounded(.awayFromZero) - 1), 0)
        (0..<steps).forEach { (i) in
            guard let v = stackView?.arrangedSubviews[safe: i] as? UIImageView else {
                return
            }
            v.isHighlighted = i <= idx
            v.alpha = i < idx ? 0.4 : 1
        }
    }
}


// MARK: Class's private methods
private extension VatoProgressView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.backgroundColor = .clear
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        let images = (0..<steps).map { (idx) -> UIImageView in
            let imageView = UIImageView(frame: .zero)
            imageView >>> {
                $0.contentMode = .scaleToFill
                $0.highlightedImage = image.imageH
                $0.image = image.imageN
                $0.snp.makeConstraints { (make) in
                    make.size.equalTo(sizeStep)
                }
            }
            return imageView
        }
        
        let stackView = UIStackView(arrangedSubviews: images)
        stackView >>> self >>> {
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.spacing = spacing
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        var bImageView: UIView?
        stackView.arrangedSubviews.forEach { (v) in
            if let before = bImageView {
                let lineView = UIView(frame: .zero)
                lineView >>> self >>> {
                    $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
                    $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)
                    $0.snp.makeConstraints { (make) in
                        make.height.equalTo(2)
                        make.left.equalTo(before.snp.right).priority(.high)
                        make.right.equalTo(v.snp.left).priority(.high)
                        make.centerY.equalToSuperview()
                    }
                }
            }
            
            bImageView = v
        }
        
        self.stackView = stackView
    }
}
