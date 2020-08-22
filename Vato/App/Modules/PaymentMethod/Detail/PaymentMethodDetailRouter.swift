//  File name   : PaymentMethodDetailRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import SnapKit
import RxSwift
protocol PaymentMethodDetailInteractable: Interactable {
    var router: PaymentMethodDetailRouting? { get set }
    var listener: PaymentMethodDetailListener? { get set }
}

protocol PaymentMethodDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PaymentMethodDetailRouter: ViewableRouter<PaymentMethodDetailInteractable, PaymentMethodDetailViewControllable>, PaymentMethodDetailRouting {
    struct Config {
        static let message = "Xoá thẻ thành công!"
    }
    
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: PaymentMethodDetailInteractable, viewController: PaymentMethodDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func showToastDeleteSuccess() -> Observable<Void> {
        return Toast.show(using: Config.message, on: self.viewControllable.uiviewController.view, duration: 2) {
            $0.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
        }
    }
}
