//  File name   : PaymentAddCardRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol PaymentAddCardInteractable: Interactable {
    var router: PaymentAddCardRouting? { get set }
    var listener: PaymentAddCardListener? { get set }
}

protocol PaymentAddCardViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PaymentAddCardRouter: ViewableRouter<PaymentAddCardInteractable, PaymentAddCardViewControllable>, PaymentAddCardRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: PaymentAddCardInteractable, viewController: PaymentAddCardViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
