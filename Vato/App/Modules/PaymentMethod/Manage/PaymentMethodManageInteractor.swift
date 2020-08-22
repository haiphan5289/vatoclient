//  File name   : PaymentMethodManageInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCoreRX

import VatoNetwork
import Firebase

protocol PaymentMethodManageRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func paymentAddCard(from url: URL)
    func paymentDetail(for card: PaymentCardDetail)
}

protocol PaymentMethodManagePresentable: Presentable {
    var listener: PaymentMethodManagePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol PaymentMethodManageListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func paymentManageMoveBack()
}

final class PaymentMethodManageInteractor: PresentableInteractor<PaymentMethodManagePresentable>, PaymentMethodManageInteractable, PaymentMethodManagePresentableListener, ActivityTrackingProgressProtocol, LoadingAnimateProtocol {
    struct Config {
        static let realURL: String = "https://web-payment.vato.vn/napas/add-card.html"
        static let dummyURL: String = "https://web-payment-dev.vato.vn/napas/add-card.html"  
    }
    
    var loading: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var source: Observable<[PaymentCardDisplay]> {
        return eventSource.map { $0 as [PaymentCardDisplay]}.observeOn(MainScheduler.asyncInstance)
    }
    
    var error: Observable<Error> {
        return mError.observeOn(MainScheduler.asyncInstance)
    }
    
    var enableAddCard: Observable<Bool> {
        let eMax = eAppConfig.map { $0.client_card_config?.max_card }.filterNil()
        return Observable.combineLatest(eventSource.asObserver(), eMax) { (e1, e2) -> Bool in
            !(e1.count < e2)
        }.observeOn(MainScheduler.asyncInstance)
    }
    
    weak var router: PaymentMethodManageRouting?
    weak var listener: PaymentMethodManageListener?
    private var eventSource: ReplaySubject<[PaymentCardDetail]> = ReplaySubject.create(bufferSize: 1)
    private lazy var eAppConfig = ReplaySubject<AppConfigure>.create(bufferSize: 1)
    private lazy var mError: PublishSubject<Error> = PublishSubject()
    private let authenticated: AuthenticatedStream
    private var mSource: [PaymentCardDetail] = []
    private let paymentStream: MutablePaymentStream
    private let firebaseDatabase: DatabaseReference
    
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: PaymentMethodManagePresentable, authenticated: AuthenticatedStream, paymentStream: MutablePaymentStream, firebaseDatabase: DatabaseReference) {
        self.authenticated = authenticated
        self.paymentStream = paymentStream
        self.firebaseDatabase = firebaseDatabase
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        loadData()
        // todo: Implement business logic here.
    }
    
    private func setupRX() {
        
        showLoading(use: self.eLoadingObser)
        
        self.eventSource.bind { [weak self](list) in
            self?.mSource = list
        }.disposeOnDeactivate(interactor: self)
        
        self.getAppConfig().bind { [weak self](c) in
            self?.eAppConfig.onNext(c)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func loadData() {
        fetchData()
            .trackProgressActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self](list) in
            guard let wSelf = self else { return }
            defer {
                wSelf.paymentStream.update(source: list)
            }
            wSelf.eventSource.onNext(list)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func fetchData() -> Observable<[PaymentCardDetail]> {
        let router = authenticated.firebaseAuthToken.take(1).map { VatoAPIRouter.listCard(authToken: $0) }
        return router.flatMap {
                Requester.responseDTO(decodeTo: OptionalMessageDTO<[PaymentCardDetail]>.self, using: $0)
            }.map { r -> [PaymentCardDetail] in
                if let e = r.response.error {
                    throw e
                } else {
                    let list = r.response.data.orNil([])
                    return list
                }
            }.catchError { [weak self](e) -> Observable<[PaymentCardDetail]> in
                printDebug(e)
                self?.mError.onNext(e)
                return Observable.just([])
        }
    }
    
    private func getAppConfig() -> Observable<AppConfigure> {
        return self.firebaseDatabase.findAppConfigure().take(1)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func paymentManageMoveBack() {
        self.listener?.paymentManageMoveBack()
    }
    
    func paymentAddCard() {
        self.authenticated.firebaseAuthToken.take(1).bind { [weak self](token) in
            func mPath() -> String {
                #if DEBUG
                    return Config.dummyURL
                #else
                    return Config.realURL
                #endif
            }
            let path = mPath() + "#\(token)"
            guard let wSelf = self, let url = URL(string: path) else { return }
            wSelf.router?.paymentAddCard(from: url)
        }.disposeOnDeactivate(interactor: self)
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: Add card
extension PaymentMethodManageInteractor {
    func paymentAddCardMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func paymentAddCardSuccess() {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.loadData()
        })
    }
}

// MARK: Detail
extension PaymentMethodManageInteractor {
    func paymentDetailMoveback() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func paymentCardDetail(at idx: IndexPath) {
        guard let item = mSource[safe: idx.item] else {
            return
        }
        
        self.router?.paymentDetail(for: item)
    }
}

// MARK: Delete
extension PaymentMethodManageInteractor {
    func paymentDetailRemoveCard() {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.loadData()
        })
    }
}

extension PaymentCardDetail {
    var bgColor: UIColor {
        switch self.type.method {
        case PaymentMethodCash:
            return Color.battleshipGreyTwo
        case PaymentMethodVATOPay:
            return Color.orange
        default:
            return Color.orange
        }
    }
    
    var nameDisplay: String {
        guard self.napas else {
            return self.type.method?.name ?? ""
        }
        
        if let _ = self.params {
            return self.brand ?? ""
        } else {
            let last = self.name.suffix(4)
            return "Thẻ ***" + "\(last)"
        }
    }
}
