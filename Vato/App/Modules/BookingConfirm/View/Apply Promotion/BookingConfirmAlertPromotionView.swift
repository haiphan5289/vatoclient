//
//  BookingConfirmAlertPromotionView.swift
//  FaceCar
//
//  Created by Dung Vu on 10/26/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum BookingConfirmAlertPromotionType {
    case success
    case fail(e: PromotionError)
    case usePrivateDriver
    
    var colorText: UIColor {
        switch self {
        case .success, .usePrivateDriver:
            return PromotionConfig.promotionSuccessColor
        case .fail:
            return PromotionConfig.promotionErrorColor
        }
    }
    
    var colorBG: UIColor {
        switch self {
        case .success, .usePrivateDriver:
            return PromotionConfig.promotionSuccessBGColor
        case .fail:
            return PromotionConfig.promotionErrorBGColor
        }
    }
    
    var icon: UIImage? {
        return UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate)
    }
}

final class BookingConfirmAlertPromotionView: UIControl {

    private var btnClose: UIButton?
    private var lblMessage: UILabel?
    private lazy var disposeBag = DisposeBag()
    
    private var disposeAbleAutoDismiss: Disposable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func common() {
        self.cornerRadius = 6
        setupLayout()
        setupRX()
    }
    
    
    private func setupLayout() {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        let w: CGFloat = 39
        label >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.right.equalTo(-w)
                make.top.equalTo(14)
                make.bottom.equalTo(-14).priority(.high)
                
            })
        }
        
        self.lblMessage = label
        
        let button = UIButton(type: .custom)
        button >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.right.equalToSuperview()
                make.top.equalToSuperview()
                make.width.equalTo(w)
                make.bottom.equalToSuperview().priority(.low)
            })
        }
        
        self.btnClose = button
    }
    
    private func setupRX() {
        self.btnClose?.rx.tap.bind { [weak self] in
            self?.disposeAbleAutoDismiss?.dispose()
            self?.dismiss()
        }.disposed(by: disposeBag)
    }
    
    func showAlert(with type: BookingConfirmAlertPromotionType) {
        self.alpha = 0
        let colorText = type.colorText
        btnClose?.tintColor = colorText
        btnClose?.setImage(type.icon, for: .normal)
        self.backgroundColor = type.colorBG
        lblMessage?.textColor = colorText
        self.isHidden = false
        
        let message: String
        switch type {
        case .success:
            message = PromotionConfig.promotionApplySuccess
        case .fail(let e):
            switch e {
            case .notFoundPromotionForAutoApply:
                message = PromotionConfig.promotionNotFound
            default:
                message = PromotionConfig.promotionApplyForAllError
            }
        case .usePrivateDriver:
            message = Text.enablePrivateDriverMode.localizedText
        }
        self.lblMessage?.text = message
        show()
    }
    
    private func show() {
        disposeAbleAutoDismiss?.dispose()
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        // Auto dismiss
        disposeAbleAutoDismiss = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.asyncInstance).take(1).bind { [weak self] (_) in
            self?.dismiss()
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.isHidden = true
        }
    }

}
