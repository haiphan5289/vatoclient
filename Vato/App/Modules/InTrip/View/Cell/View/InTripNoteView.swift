//  File name   : InTripNoteView.swift
//
//  Author      : Dung Vu
//  Created date: 3/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class InTripNoteView: UIView, UpdateDisplayProtocol {
    /// Class's public properties.
    @IBOutlet var lblNoteTitle : UILabel?
    @IBOutlet var lblNoteMessage : UILabel?
    /// Class's private properties.
    
    func setupDisplay(item: String?) {
        lblNoteMessage?.text = item
    }
}

// MARK: Class's public methods
extension InTripNoteView {
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
private extension InTripNoteView {
    private func initialize() {
        // todo: Initialize view's here.
        lblNoteTitle?.text = Text.noteTitle.localizedText
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
