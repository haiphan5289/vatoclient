//  File name   : NoteView.swift
//
//  Author      : Dung Vu
//  Created date: 9/18/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RxSwift
import SnapKit
import UIKit

final class NoteView: UIView {
    /// Class's public properties.
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteForDriverLabel: UILabel!

    /// Class's private properties.
    @IBOutlet weak var lblPlaceHolder: UILabel?
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var btnConfirm: UIButton?
    @IBOutlet weak var btnClear: UIButton?

    private var eResult: PublishSubject<String?> = PublishSubject()
}

// MARK: Class's public methods
extension NoteView {
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
private extension NoteView {
    private func initialize() {
        noteLabel.text = Text.note.localizedText
        noteForDriverLabel.text = Text.noteForDriver.localizedText
        lblPlaceHolder?.text = Text.noteForDriver.localizedText
        btnConfirm?.setTitle(Text.confirm.localizedText, for: .normal)
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.textView?.tintColor = Color.orange
        self.btnConfirm?.apply(style: .default)
        self.btnClear?.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
    }
}
