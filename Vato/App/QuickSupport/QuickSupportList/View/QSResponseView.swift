//
//  QuickResponseView.swift
//  FC
//
//  Created by khoi tran on 1/16/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import Kingfisher

class QSResponseView: UIView, UpdateDisplayProtocol {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupDisplay(item: QuickSupportItemResponse?) {
        
        self.titleLabel.text = item?.title
        self.messageLabel.text = item?.message
        if let createdDate = item?.createdAt {
            let date = Date(timeIntervalSince1970: createdDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm dd/MM/yyyy"
            let dateString = formatter.string(from: date)
            createdAtLabel.text = dateString
        }
        
        if let type = item?.type {
            switch type {
            case .vato:
                avatarImageView.image = UIImage(named: "splashscreen_logo_vato")
            case .user:
                if let url = UserManager.shared.getAvatarUrl() {
                    avatarImageView.kf.setImage(with: url)
                }
            }
        }
    }
}
