//  File name   : ConfirmBookingChangeMethodInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Firebase
import RIBs
import RxSwift

protocol ConfirmBookingChangeMethodRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ConfirmBookingChangeMethodPresentable: Presentable {
    var listener: ConfirmBookingChangeMethodPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ConfirmBookingChangeMethodListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func change(method: ChangeMethod)
    func closeChangeMethod()
}

final class ConfirmBookingChangeMethodInteractor: PresentableInteractor<ConfirmBookingChangeMethodPresentable>, ConfirmBookingChangeMethodInteractable, ConfirmBookingChangeMethodPresentableListener {
    var topupToWalletConfigure: Observable<AppLink?> {
        return subject.asObserver()
    }

    weak var router: ConfirmBookingChangeMethodRouting?
    weak var listener: ConfirmBookingChangeMethodListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: ConfirmBookingChangeMethodPresentable, firebaseDatabase: DatabaseReference) {
        self.firebaseDatabase = firebaseDatabase
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.

        checkAppConfigure()
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    func change(method: ChangeMethod) {
        self.listener?.change(method: method)
    }

    func closeChangeMethod() {
        self.listener?.closeChangeMethod()
    }

    private(set) var firebaseDatabase: DatabaseReference
    private let subject: ReplaySubject<AppLink?> = ReplaySubject.create(bufferSize: 1)
}

// MARK: - Private's methods
private extension ConfirmBookingChangeMethodInteractor {
    func checkAppConfigure() {
        self.firebaseDatabase.findAppConfigure().subscribe(onNext: { [weak self] configure in
            let applink = self?.findTopupConfigure(configures: configure.app_link_configure)
            self?.subject.onNext(applink)
        }, onError: { e in
            let error = e as NSError
            printDebug(error)
        }).disposeOnDeactivate(interactor: self)
    }

    func findTopupConfigure(configures: [AppLink]) -> AppLink? {
        return configures.filter { (link) -> Bool in
            link.active && link.type == LinkConfigureTypeTopup
        }.first
    }
}
