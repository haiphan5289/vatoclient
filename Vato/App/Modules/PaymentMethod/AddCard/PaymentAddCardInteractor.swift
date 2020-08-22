//  File name   : PaymentAddCardInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol PaymentAddCardRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol PaymentAddCardPresentable: Presentable {
    var listener: PaymentAddCardPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol PaymentAddCardListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func paymentAddCardMoveBack()
    func paymentAddCardSuccess()
}

final class PaymentAddCardInteractor: PresentableInteractor<PaymentAddCardPresentable>, PaymentAddCardInteractable, PaymentAddCardPresentableListener {
    var mURL: URL {
        return url
    }
    
    weak var router: PaymentAddCardRouting?
    weak var listener: PaymentAddCardListener?

    private let url: URL
    private let authenticated: AuthenticatedStream
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: PaymentAddCardPresentable, url: URL, authenticated: AuthenticatedStream) {
        self.url = url
        self.authenticated = authenticated
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
    
    func paymentAddCardMoveBack() {
        self.listener?.paymentAddCardMoveBack()
    }
    
    func paymentAddCardSuccess() {
        self.listener?.paymentAddCardSuccess()
    }
}
