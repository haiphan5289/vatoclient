//  File name   : LatePaymentRouter.swift
//
//  Author      : Futa Corp
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol LatePaymentInteractable: Interactable, PaymentMethodManageListener, WalletListener {
    var router: LatePaymentRouting? { get set }
    var listener: LatePaymentListener? { get set }
}

protocol LatePaymentViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class LatePaymentRouter: ViewableRouter<LatePaymentInteractable, LatePaymentViewControllable> {
    /// Class's constructor.
    init(interactor: LatePaymentInteractable,
         viewController: LatePaymentViewControllable,
         paymentMethodManageBuilder: PaymentMethodManageBuildable,
         walletBuilder: WalletBuildable)
    {
        self.paymentMethodManageBuilder = paymentMethodManageBuilder
        self.walletBuilder = walletBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let paymentMethodManageBuilder: PaymentMethodManageBuildable
    private let walletBuilder: WalletBuildable
}

// MARK: LatePaymentRouting's members
extension LatePaymentRouter: LatePaymentRouting {
    func routeToCardManagement() {
        let router = paymentMethodManageBuilder.build(withListener: interactor)

        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }

    func routeToWallet() {
        let router = walletBuilder.build(withListener: interactor, source: .home)

        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension LatePaymentRouter {
}
