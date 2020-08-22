//  File name   : InTripContactView.swift
//
//  Author      : Dung Vu
//  Created date: 3/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa

final class InTripContactView: UIView {
    /// Class's public properties.
    @IBOutlet var btnCall : UIButton?
    @IBOutlet var btnMessage : UIButton?
    
    @IBOutlet var iconMessage : UIImageView?
    @IBOutlet var lblPhone : UILabel?
    @IBOutlet var lblMessage : UILabel?
    @IBOutlet var viewMessage: UIView?
    /// Class's private properties.
}

// MARK: Class's public methods
extension InTripContactView {
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
private extension InTripContactView {
    private func initialize() {
        // todo: Initialize view's here.
        lblPhone?.text = Text.call.localizedText
        lblMessage?.text = Text.inTripMessage.localizedText
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
