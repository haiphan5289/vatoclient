//  File name   : SwitchPaymentRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol SwitchPaymentInteractable: Interactable, PaymentMethodManageListener, PaymentAddCardListener {
    var router: SwitchPaymentRouting? { get set }
    var listener: SwitchPaymentListener? { get set }
}

protocol SwitchPaymentViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SwitchPaymentRouter: ViewableRouter<SwitchPaymentInteractable, SwitchPaymentViewControllable>, SwitchPaymentRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    init(interactor: SwitchPaymentInteractable,
         viewController: SwitchPaymentViewControllable,
         paymentMethodManageBuildabler: PaymentMethodManageBuildable,
         paymentAddCardBuilder: PaymentAddCardBuildable) {
        self.paymentMethodManageBuildabler = paymentMethodManageBuildabler
        self.paymentAddCardBuilder = paymentAddCardBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    private let paymentMethodManageBuildabler: PaymentMethodManageBuildable
    private let paymentAddCardBuilder: PaymentAddCardBuildable

    
    func switchPaymentMoveBack() {
       self.interactor.listener?.switchPaymentMoveBack()
    }
    
    func routeToManageCard() {
        let router = paymentMethodManageBuildabler.build(withListener: self.interactor)
        let transition = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: true)
        self.perform(with: transition, completion: nil)
    }
    
    func paymentAddCard(from url: URL) {
        let router = paymentAddCardBuilder.build(withListener: interactor, url: url)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: true)
        self.perform(with: segue, completion: nil)
    }
    
}
