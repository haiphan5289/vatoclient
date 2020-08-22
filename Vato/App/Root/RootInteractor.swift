//  File name   : RootInteractor.swift
//
//  Author      : Phuc Tran
//  Created date: 8/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol RootRouting: ViewableRouting {
    /// Route to logged in module.
    func routeToLoggedIn()

    /// Route to logged out module.
    func routeToLoggedOut()
}

protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol RootListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
    weak var router: RootRouting?
    weak var listener: RootListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
}

// MARK: LoggedOutListener's members
extension RootInteractor {}
