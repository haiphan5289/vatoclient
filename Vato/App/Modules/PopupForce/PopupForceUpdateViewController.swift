//
//  PopupForceUpdateViewController.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

@objc enum PopupForeType: Int {
    
    case forceUpdate
    case remindpdate
    case blockUser
}

class PopupForceUpdateViewController: UIViewController {
    
    struct Config {
        static let appStoreUrl = "https://itunes.apple.com/vn/app/facecar/id1126633800?mt=8"
        static let phone = "19006667"
    }
    
    @objc var completionHandler: (() -> Void)?

    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var laterBtn: UIButton!
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    
    @objc var popupType: PopupForeType = .forceUpdate
    private var subTitleVal = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            if let topPadding = window?.safeAreaInsets.top, topPadding > 20 {
                topLayout.constant = 50
            }
        }
        
        switch popupType {
        case .forceUpdate:
            laterBtn.isHidden = true
            contentImageView.image = UIImage(named: "ic_force_update")
            lblTitle.text = Text.updateApplication.localizedText
            lblSubTitle.text = subTitleVal
            btnConfirm.setTitle(Text.updateNow.localizedText, for: .normal)
        case .remindpdate:
            laterBtn.isHidden = false
            contentImageView.image = UIImage(named: "ic_force_update")
            lblTitle.text = Text.updateApplication.localizedText
            lblSubTitle.text = subTitleVal
            btnConfirm.setTitle(Text.updateNow.localizedText, for: .normal)
        case .blockUser:
            laterBtn.isHidden = true
            contentImageView.image = UIImage(named: "ic_block_user")
            lblTitle.text = Text.accountIsBlocked.localizedText
            lblSubTitle.text = subTitleVal
            btnConfirm.setTitle(Text.contactManagement.localizedText, for: .normal)
        }
    }
    
    @objc static func generateVC(with type: PopupForeType, message: String?) -> PopupForceUpdateViewController {
        let vc = PopupForceUpdateViewController()
        
        var value = ""
        if type == .forceUpdate {
            value = message != nil ? message! : Text.updateApplicationDescription.localizedText
        } else {
            value = message != nil ? message! : Text.forInfoContactManagerment.localizedText
        }
        
        vc.updateDisplay(with: type, message: value)
    
        return vc
    }
    
    private func updateDisplay(with type: PopupForeType, message: String) {
        self.popupType = type
        self.subTitleVal = message
    }

    @IBAction func btnConfirm_clicked(_ sender: Any) {
        
        if self.popupType == .blockUser {
            guard let url = URL(string: "tel://\(Config.phone)") else {
                return
            }
            guard UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in })
        } else {
            guard let url = URL(string: Config.appStoreUrl) else {
                return
            }
            guard UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:]) { [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.completionHandler?()
            }
        }
    }

    @IBAction func didTouchLater(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
