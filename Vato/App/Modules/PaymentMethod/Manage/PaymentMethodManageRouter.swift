//  File name   : PaymentMethodManageRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol PaymentMethodManageInteractable: Interactable, PaymentAddCardListener, PaymentMethodDetailListener {
    var router: PaymentMethodManageRouting? { get set }
    var listener: PaymentMethodManageListener? { get set }
}

protocol PaymentMethodManageViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PaymentMethodManageRouter: ViewableRouter<PaymentMethodManageInteractable, PaymentMethodManageViewControllable>, PaymentMethodManageRouting {
    private let paymentAddCardBuilder: PaymentAddCardBuildable
    private let paymentMethodDetailBuilder: PaymentMethodDetailBuildable
    
    // todo: Constructor inject child builder protocols to allow building children.
    init(interactor: PaymentMethodManageInteractable,
         viewController: PaymentMethodManageViewControllable,
         paymentAddCardBuilder: PaymentAddCardBuildable,
         paymentMethodDetailBuilder: PaymentMethodDetailBuildable)
    {
        self.paymentAddCardBuilder = paymentAddCardBuilder
        self.paymentMethodDetailBuilder = paymentMethodDetailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func paymentAddCard(from url: URL) {
        let router = paymentAddCardBuilder.build(withListener: interactor, url: url)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: true)
        self.perform(with: segue, completion: nil)
    }
    
    func paymentDetail(for card: PaymentCardDetail) {
        let router = paymentMethodDetailBuilder.build(withListener: interactor, detail: card)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: true)
        self.perform(with: segue, completion: nil)
    }
}

