//  File name   : RootRouter.swift
//
//  Author      : Phuc Tran
//  Created date: 8/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol RootInteractable: Interactable, LoggedOutListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

protocol RootViewControllable: ViewControllable {
    /// Dismiss a view controller.
    ///
    /// - Parameter viewController: a view controller
    func dismiss(viewController: ViewControllable)

    /// Present logged out view controller.
    ///
    /// - Parameter viewController: a view controller
    func presentLoggedOut(viewController: ViewControllable)
}

final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    init(interactor: RootInteractable,
         viewController: RootViewControllable,
         loggedOutBuilder: LoggedOutBuildable) {
        self.loggedOutBuilder = loggedOutBuilder
//        self.loggedInBuilder = loggedInBuilder

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        routeToLoggedOut()
    }

    /// Class's private properties
    private let loggedOutBuilder: LoggedOutBuildable
//    private let loggedInBuilder: LoggedInBuildable
    private var currentRoute: ViewableRouting?
}

// MARK: RootRouting's members
extension RootRouter {
    func routeToLoggedIn() {
        //        // Detach logged out.
        //        if let loggedOut = self.loggedOut {
        //            detachChild(loggedOut)
        //            viewController.dismiss(viewController: loggedOut.viewControllable)
        //            self.loggedOut = nil
        //        }
        //
        //        let loggedIn = loggedInBuilder.build(withListener: interactor, player1Name: player1Name, player2Name: player2Name)
        //        attachChild(loggedIn)
    }

    func routeToLoggedOut() {
        let loggedOut = loggedOutBuilder.build(withListener: interactor)
        currentRoute = loggedOut

        attachChild(loggedOut)
        viewController.presentLoggedOut(viewController: loggedOut.viewControllable)
    }
}
