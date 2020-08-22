//  File name   : PaymentMethodDetailInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCoreRX
import Alamofire

protocol PaymentMethodDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showToastDeleteSuccess() -> Observable<Void>
}

protocol PaymentMethodDetailPresentable: Presentable {
    var listener: PaymentMethodDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol PaymentMethodDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func paymentDetailMoveback()
    func paymentDetailRemoveCard()
}

final class PaymentMethodDetailInteractor: PresentableInteractor<PaymentMethodDetailPresentable>, PaymentMethodDetailInteractable, PaymentMethodDetailPresentableListener, ActivityTrackingProgressProtocol, LoadingAnimateProtocol {
    var eError: Observable<Error> {
        return _error.observeOn(MainScheduler.asyncInstance)
    }
    
    private lazy var _error: PublishSubject<Error> = PublishSubject()
    weak var router: PaymentMethodDetailRouting?
    weak var listener: PaymentMethodDetailListener?
    private let authenticated: AuthenticatedStream
    private (set) var cardDetail: PaymentCardDetail
    private let profileStream: ProfileStream
    
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: PaymentMethodDetailPresentable, authenticated: AuthenticatedStream, cardDetail: PaymentCardDetail, profileStream: ProfileStream) {
        self.authenticated = authenticated
        self.cardDetail = cardDetail
        self.profileStream = profileStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        // todo: Implement business logic here.
    }
    
    private func setupRX() {
        showLoading(use: self.indicator.asObservable())
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func paymentDetailDeleteCard() {
        let card = self.cardDetail
        let router = Observable.zip(authenticated.firebaseAuthToken.take(1), profileStream.user.take(1)) { (e1, e2) -> VatoAPIRouter in
            VatoAPIRouter.removeCard(authToken: e1, userId: "\(e2.id)", tokenId: card.id)
        }
        
        router
            .flatMap
        {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<Bool>.self, using: $0, method: .post, encoding: JSONEncoding.default)
        }
        .trackProgressActivity(self.indicator)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe { [weak self](event) in
            guard let wSelf = self else { return }
            switch event {
            case .next(let r):
                if let e = r.response.error {
                   wSelf._error.onNext(e)
                } else {
                    guard r.response.data == true else {
                        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
                        return wSelf._error.onNext(error)
                    }
                    wSelf.removeSuccess()
                }
            case .error(let e):
                wSelf._error.onNext(e)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func removeSuccess() {
        self.router?.showToastDeleteSuccess().subscribe(onNext: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.listener?.paymentDetailRemoveCard()
        }).disposeOnDeactivate(interactor: self)
    }
    
    func paymentDetailMoveback() {
        self.listener?.paymentDetailMoveback()
    }
}
