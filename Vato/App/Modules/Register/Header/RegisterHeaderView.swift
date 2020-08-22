//  File name   : RegisterHeaderView.swift
//
//  Author      : Futa Corp
//  Created date: 12/21/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class RegisterHeaderView: UIView {
    @IBOutlet weak var avatarImageView: UIImageView!

    /// Class's public properties.

    /// Class's private properties.
}

// MARK: Class's public methods
extension RegisterHeaderView {
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension RegisterHeaderView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        avatarImageView.cornerRadius = avatarImageView.bounds.height / 2.0
//        avatarImageView.borderColor = Color.orange
//        avatarImageView.borderWidth = 1.0
    }
}
