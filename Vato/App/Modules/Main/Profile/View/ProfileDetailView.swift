//  File name   : ProfileDetailView.swift
//
//  Author      : Dung Vu
//  Created date: 9/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

final class ProfileDetailView: UIView {
    /// Class's public properties.
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var avatarView: UIImageView?
    @IBOutlet weak var lblName: UILabel?
    @IBOutlet weak var lblPhone: UILabel?
    
    func display(client: UserInfo) {
//        lblTitle?.text = Text.tabbarProfile.localizedText
        lblName?.text = client.displayName
        lblPhone?.text = client.phone
        updateAvatar(url: client.avatarUrl)
        self.layoutIfNeeded()
    }
    
    func updateAvatar(url: String?) {
        avatarView?.setImage(from: url, placeholder: UIImage(named: "ic_default_avatar"), size: CGSize(width: 64, height: 64))
    }
}

// MARK: Class's public methods
extension ProfileDetailView {
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
private extension ProfileDetailView {
    private func initialize() {
        avatarView?.layer.cornerRadius = 32
        avatarView?.clipsToBounds = true
        // todo: Initialize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
