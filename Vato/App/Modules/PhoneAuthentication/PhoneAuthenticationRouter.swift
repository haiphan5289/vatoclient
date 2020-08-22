//  File name   : PhoneAuthenticationRouter.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol PhoneAuthenticationInteractable: Interactable, PhoneInputListener, PhoneVerificationListener, RegisterListener {
    var router: PhoneAuthenticationRouting? { get set }
    var listener: PhoneAuthenticationListener? { get set }
}

protocol PhoneAuthenticationViewControllable: ViewControllable {
}

final class PhoneAuthenticationRouter: ViewableRouter<PhoneAuthenticationInteractable, PhoneAuthenticationViewControllable>, PhoneAuthenticationRouting {
    var currentChild: Routing?
    var currentRoute: ViewableRouting?

    /// Class's constructors.
    init(interactor: PhoneAuthenticationInteractable,
         viewController: PhoneAuthenticationViewControllable,
         phoneInputBuilder: PhoneInputBuildable,
         phoneVerificationBuilder: PhoneVerificationBuilder,
         registerBuilder: RegisterBuildable) {
        self.phoneInputBuilder = phoneInputBuilder
        self.phoneVerificationBuilder = phoneVerificationBuilder
        self.registerBuilder = registerBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
    }

    /// Class's private properties
    private let phoneInputBuilder: PhoneInputBuildable
    private let phoneVerificationBuilder: PhoneVerificationBuildable
    private let registerBuilder: RegisterBuildable
}

// MARK: PhoneAuthenticationRouting's members
extension PhoneAuthenticationRouter {
    func routeToPhoneInput() {
        let router = phoneInputBuilder.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }

    func routeToPhoneVerification() {
        let router = phoneVerificationBuilder.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }

    func routeToRegister() {
        let router = registerBuilder.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
}
