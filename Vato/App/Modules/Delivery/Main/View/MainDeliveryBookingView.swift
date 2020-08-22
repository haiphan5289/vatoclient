//  File name   : MainDeliveryBookingView.swift
//
//  Author      : Dung Vu
//  Created date: 8/20/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa

final class MainDeliveryBookingView: BookingConfirmView {
    
    var type: DeliveryServiceType = .URBAN_DELIVERY
    @IBOutlet weak var paymentPriceLabel: UILabel?
    
    private (set) var showing: Bool = true
    
    static func loadXib(type: DeliveryServiceType) -> MainDeliveryBookingView {
        let view = MainDeliveryBookingView.loadXib()
        view.type = type
//        view.updateUI()
        return view
    }
    
    
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 14)
        v.containerColor = .white
        return v
    }()
    
    func show() {
        guard !showing else {
            return
        }
        showing = true
        self.backgroundView?.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.backgroundView?.alpha = 1
            self.containerView?.transform = .identity
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        if v == nil {
            self.dimiss(true)
        }
        
        return v
    }
    
    func dimiss(_ animated: Bool) {
        guard showing else {
            return
        }
        showing = false
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.alpha = 0
                self.containerView?.transform = CGAffineTransform(translationX: 0, y: 1000)
            }) { (_) in
                self.backgroundView?.isHidden = true
            }
        } else {
            self.backgroundView?.alpha = 0
            self.backgroundView?.isHidden = true
            self.containerView?.transform = CGAffineTransform(translationX: 0, y: 1000)
        }
    }
    
    override func setupRX() {
        self.containerView?.backgroundColor = .clear
        self.containerView?.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        self.header?.lblName?.text = Text.delivery.localizedText
        self.btnConfirm?.setTitle(Text.confirmDelivery.localizedText, for: .normal)
        self.header?.addSeperator()
        eUpdate.bind { [weak self] type in
            guard let wSelf = self else {
                return
            }
            
            defer {
                wSelf.recheckDetail()
            }
            
            switch type {
            case .service(let s):
                wSelf.serviceSelected = s
            case .updatePrice(let infor):
                  wSelf.price = infor
                wSelf.btnConfirm?.isEnabled = (!wSelf.isFixedBook || infor.originalPrice > 0 ) //&& wSelf.myInfor != nil
                wSelf.updatePromotionInfor()
            case .note(let string):
                let f = wSelf.itemsView?.first(where: { $0.type == .note })
                f?.update(from: BookingConfirmUpdateType.update(string: nil, exist: string?.isEmpty == false))
            case .updateTip(let tip):
                wSelf.tip = tip
                let f = wSelf.itemsView?.first(where: { $0.type == .addTip })
                let message = tip > 0 ? UInt32(tip).currency : nil
                f?.update(from: BookingConfirmUpdateType.update(string: message, exist: tip > 0))
                wSelf.updatePromotionInfor()
            case .updateMethod(let method):
                wSelf.lblMoneyWallet?.text = ""
                let name: String?
                defer {
                    wSelf.lblChoosePaymentMethod?.text = name
                }
                guard method.napas else {
                    name = method.type.method?.name
                    return
                }
                let last = method.name.suffix(4)
                name = Config.napas + "\(last)"
            case .updatePromotion(let model):
                self?.promotion = model
                let f = wSelf.itemsView?.first(where: { $0.type == .coupon })
                f?.update(from: BookingConfirmUpdateType.update(string: model?.code, exist: model != nil))
            case .book:
                wSelf.btnConfirm?.sendActions(for: .touchUpInside)
            case .updateListService(let listSevice):
                wSelf.listServiceSubject.accept(listSevice)
            case .updateBooking(let booking):
                wSelf.booking = booking
            default:
                break
            }
            }.disposed(by: disposeBag)
        let detailPrice = self.btnDetailPrice?.rx.tap.map { BookingConfirmType.detailPrice }
        let choose = self.header?.btnAction?.rx.tap.map { BookingConfirmType.chooseInformation }
        let confirm = self.btnConfirm?.rx.tap.map { BookingConfirmType.booking }
        let wallet = self.btnChoosePaymentMethod?.rx.tap.map { BookingConfirmType.wallet }
        let moveBack = self.btnMoveBackToCurrent?.rx.tap.map { BookingConfirmType.moveToCurrent }
        
        Observable.merge([choose, confirm, wallet, moveBack, detailPrice].compactMap { $0 }).subscribe(eAction).disposed(by: disposeBag)
        
        setupRXListService()
        
        
    }
    
    func updateUI() {
        switch type {
        case .URBAN_DELIVERY:
            paymentPriceLabel?.isHidden = true
            paymentMethodsLabel?.isHidden = false
            btnChoosePaymentMethod?.isHidden = false
            lblChoosePaymentMethod?.isHidden = false
            iconRightImageView?.isHidden = false
            break
        case .DOMESTIC_DELIVERY:
            paymentPriceLabel?.isHidden = false
            paymentMethodsLabel?.isHidden = true
            btnChoosePaymentMethod?.isHidden = true
            lblChoosePaymentMethod?.isHidden = true
            iconRightImageView?.isHidden = true

        }
    }
    
}
