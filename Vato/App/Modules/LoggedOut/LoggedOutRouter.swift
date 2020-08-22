//  File name   : LoggedOutRouter.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import SnapKit

protocol LoggedOutInteractable: Interactable, PhoneAuthenticationListener, SocialNetworkListener {
    var router: LoggedOutRouting? { get set }
    var listener: LoggedOutListener? { get set }
}

protocol LoggedOutViewControllable: ViewControllable {}

final class LoggedOutRouter: ViewableRouter<LoggedOutInteractable, LoggedOutViewControllable>, LoggedOutRouting {
    /// Class's constructors.
    init(interactor: LoggedOutInteractable,
         viewController: LoggedOutViewControllable,
         phoneAuthenticationBuilder: PhoneAuthenticationBuildable,
         socialNetworkBuilder: SocialNetworkBuildable) {
        self.phoneAuthenticationBuilder = phoneAuthenticationBuilder
        self.socialNetworkBuilder = socialNetworkBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    /// Class's private properties
    private let phoneAuthenticationBuilder: PhoneAuthenticationBuildable
    private let socialNetworkBuilder: SocialNetworkBuildable
    private var currentRouting: ViewableRouting?
}

// MARK: LoggedOutRouting's members
extension LoggedOutRouter {
    func routeToPhoneAuthentication() {
        let router = phoneAuthenticationBuilder.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }

    func routeToSocialNetwork() {
        let transitionType = TransitonType.addChild { (view, controller) in
            guard let socialView = view, let loggedOutController = controller as? LoggedOutVC else {
                return
            }
            socialView >>> loggedOutController.containerView >>> { $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }}
        }

        let router = socialNetworkBuilder.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: transitionType, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func detachCurrentChild() {
        guard let routing = self.currentRouting else {
            return
        }
        
        let vc = routing.viewControllable.uiviewController
        detachChild(routing)
        vc.dismiss(animated: false, completion: nil)
    }
}
