//  File name   : PaymentTopView.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Kingfisher
import SnapKit
import FwiCore
import RxSwift
import RxCocoa

enum VatoHomePaymentAction {
    case wallet
    case topUp
    case transactions
}

typealias BlockAction<T> = (T) -> ()

final class VatoHomePaymentTopView: UIView {
    /// Class's public properties.
    @IBOutlet weak var lblPrice: UILabel?
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var gradientView: BookingConfirmGradientView?
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var btnWallet: UIButton?
    @IBOutlet weak var walletView: HomeWalletView!
    private lazy var disposeBag = DisposeBag()
    @IBOutlet weak var bgThemeImageView: UIImageView!
    @IBOutlet weak var lbPointRank: UILabel!
    @IBOutlet weak var btPointRank: UIButton!
    private var btnProfile: UIButton!
    private var task: TaskExcuteProtocol?
    var showProfile: Observable<Void> {
        return btnProfile.rx.tap.asObservable()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        visualize()
        setupRX()
    }
    
    func update(user: UserInfo) {
        task = avatarView?.setImage(from: user, placeholder: UIImage(named: "ic_default_avatar"), size: nil)
        lblPrice?.text = Int64(user.cash).currency
    }
    
    func setupRX() {
        NotificationCenter.default.rx.notification(.profileUpdatedAvatar, object: nil).map { $0.object as? String }.bind { [weak self](url) in
            self?.task = self?.avatarView.setImage(from: url, placeholder: UIImage(named: "ic_default_avatar"), size: nil)
        }.disposed(by: disposeBag)
    }
    
    override func removeFromSuperview() {
        task?.cancel()
        super.removeFromSuperview()
    }
}

extension VatoHomePaymentTopView: ThemeManagerHandlerProtocol {
    func themeUpdateUI() {
        ThemeManager.instance.setPDFImage(name: "bg_header_top_main", view: bgThemeImageView, placeholder: nil)
    }
}

// MARK: Class's private methods
private extension VatoHomePaymentTopView {
    private func initialize() {
        // todo: Initialize view's here.
    }
    private func visualize() {
        gradientView?.colors = [#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.4431372549, blue: 0.09803921569, alpha: 1)].map { $0.cgColor }
        avatarView?.kf.indicatorType = .activity
        avatarView?.layer.cornerRadius = 20
        avatarView?.layer.borderWidth = 1
        avatarView?.layer.borderColor = Color.orange.cgColor
        avatarView?.clipsToBounds = true
        
        btnProfile = UIButton(frame: .zero)
        btnProfile >>> self >>> {
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(avatarView.snp.size)
                make.center.equalTo(avatarView.snp.center)
            }
        }
        
        themeUpdateUI()
    }
}

