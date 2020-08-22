//  File name   : PromotionDetailView.swift
//
//  Author      : Dung Vu
//  Created date: 10/24/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

typealias PromotionDetailAdjustDisplay = (_ type: PromotionDetailBody, _ view: PromotionDetailView) -> ()
final class PromotionDetailView: UIView {
    /// Class's public properties.
    private let blockDisplay: PromotionDetailAdjustDisplay
    private let body: [PromotionDetailBody]
    init(body: [PromotionDetailBody], _ block: @escaping PromotionDetailAdjustDisplay) {
        self.body = body
        self.blockDisplay = block
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDisplay() {
        body.forEach { self.blockDisplay($0, self) }
    }
}

// MARK: Class's public methods

