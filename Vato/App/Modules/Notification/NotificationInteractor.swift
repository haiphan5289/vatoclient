//  File name   : NotificationInteractor.swift
//
//  Author      : khoi tran
//  Created date: 1/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FirebaseFirestore

protocol NotificationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NotificationPresentable: Presentable {
    var listener: NotificationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol NotificationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func selectNotification(notify: NotificationModel?)
    func notificationDismiss()
}

final class NotificationInteractor: PresentableInteractor<NotificationPresentable> {
    /// Class's public properties.
    weak var router: NotificationRouting?
    weak var listener: NotificationListener?

    /// Class's constructor.
    init(presenter: NotificationPresentable, authenticated: AuthenticatedStream) {
        self.authenticated = authenticated
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    internal let authenticated: AuthenticatedStream

}

// MARK: NotificationInteractable's members
extension NotificationInteractor: NotificationInteractable {
}

// MARK: NotificationPresentableListener's members
extension NotificationInteractor: NotificationPresentableListener {
    func selectNotification(notify: NotificationModel?) {
        self.listener?.selectNotification(notify: notify)
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
        return Requester.responseDTO(decodeTo: decodeTo, using: router, block: block).map { $0.response }
    }
    
    func notificationDismiss() {
        self.listener?.notificationDismiss()
    }
    
}

// MARK: Class's private methods
private extension NotificationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    
    
}
