//  File name   : HistoryExpressView.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class HistoryExpressView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblEnd : UILabel?
    @IBOutlet var stackView : UIStackView?
    
    /// Class's private properties.
    func setupDisplay(item: HistoryExpressItemProtocol?) {
        let childs = stackView?.subviews ?? []
        if !childs.isEmpty {
            childs.forEach { (v) in
                stackView?.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
        }
        
        let number = item?.numberItems ?? 0
        let views = (0..<number).map { _ in HistoryExpressLocationView.loadXib() }
        views.forEach { (v) in
            stackView?.addArrangedSubview(v)
        }
    }
    
}

// MARK: Class's public methods
extension HistoryExpressView {
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
private extension HistoryExpressView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
    }
}
