//  File name   : QuoteCartProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 7/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore

final class VatoSpaceLabelView: UIView {
    let label: UILabel
    let edge: UIEdgeInsets
    init(edge: UIEdgeInsets, customLabel: (UILabel) -> ()) {
        label = UILabel(frame: .zero)
        self.edge = edge
        customLabel(label)
        super.init(frame: .zero)
    }
    
    private func visualize() {
        self.clipsToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        label >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(edge)
            }
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil else { return }
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        layer.cornerRadius = h / 2
    }
}

// MARK: -- Create quote card view
protocol QuoteCartProtocol: AnyObject {
    var containerView: UIView { get }
    var lblNumberItemQuoteCard: UILabel? { get set }
    var quoteCartView: VatoGuideControl? { get set }
}

extension QuoteCartProtocol {
    func createQuoteView() {
        let v = VatoGuideControl(type: .local, fName: "ic_basket", edges: UIEdgeInsets(top: 20, left: 17, bottom: 10, right: 17))
        v >>> containerView >>> {
            $0.imageView?.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { (make) in
                make.bottom.equalTo(-42)
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 60, height: 60))
            }
        }
        self.quoteCartView = v
        let numberItemView = VatoSpaceLabelView(edge: UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)) {
            $0.textColor = .white
            $0.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        }
        
        numberItemView >>> v >>> {
            $0.label.text = "0"
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.isUserInteractionEnabled = false
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(13)
                make.centerX.equalToSuperview().offset(2.5)
            }
        }
        
        lblNumberItemQuoteCard = numberItemView.label
    }
}
