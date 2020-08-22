//  File name   : LatePaymentInteractor.swift
//
//  Author      : Futa Corp
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCoreRX
import VatoNetwork
import Alamofire

fileprivate enum VATOPayAction {
    case presentWallet
    case pay(api: VatoAPIRouter)
}

protocol LatePaymentRouting: ViewableRouting {
    func routeToCardManagement()
    func routeToWallet()
}

protocol LatePaymentPresentable: Presentable {
    var listener: LatePaymentPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol LatePaymentListener: class {
    func requestToDismissLatePaymentModule()
}

final class LatePaymentInteractor: PresentableInteractor<LatePaymentPresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: LatePaymentRouting?
    weak var listener: LatePaymentListener?

    /// Class's constructor.
    init(presenter: LatePaymentPresentable,
         authenticated: AuthenticatedStream,
         profile: ProfileStream,
         payment: PaymentStream,
         debtInfo: UserDebtDTO)
    {
        self.authenticated = authenticated
        self.profile = profile
        self.payment = payment
        self.debtInfo = debtInfo
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
    private let authenticated: AuthenticatedStream
    private let profile: ProfileStream
    private let payment: PaymentStream
    private let debtInfo: UserDebtDTO

    private let errorPublisher = PublishSubject<String>()
}

// MARK: LatePaymentInteractable's members
extension LatePaymentInteractor: LatePaymentInteractable {
    func showTopUp() {
        
    }
    
    func updateUserBalance(cash: Double, coin: Double) {
        
    }
    
    func getBalance() {
        
    }
    
    func paymentManageMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }

    func wallet(handle action: WalletAction) {
        switch action {
        case .moveBack:
            router?.dismissCurrentRoute(completion: nil)
        }
    }
}

// MARK: LatePaymentPresentableListener's members
extension LatePaymentInteractor: LatePaymentPresentableListener {
    var cards: Observable<[PaymentCardDetail]> {
        return payment.source.map { cards in
            var list = cards as [PaymentCardDetail]
            list.insert(PaymentCardDetail.vatoPay(), at: 0)
            return list
        }
    }
    var errorMessage: Observable<String> {
        return errorPublisher.asObservable()
    }
    var isLoading: Observable<Bool> {
        return indicator.asObservable()
    }

    func handleVATOPayAction() {
        let o1 = authenticated.firebaseAuthToken.take(1)
        let o2 = profile.user.map { $0.cash }.take(1)
        let o3 = Observable<Double>.just(debtInfo.amount)
        let o4 = Observable<[String]>.just(debtInfo.tripIDs)

        Observable<VATOPayAction>.combineLatest(o1, o2, o3, o4) { (token, currentCash, debt, tripIDs) -> VATOPayAction in
            if currentCash >= debt {
                let api = VatoAPIRouter.payUserDebt(authToken: token, payment: 1, cardID: nil, tripIDs: tripIDs)
                return VATOPayAction.pay(api: api)
            } else {
                return VATOPayAction.presentWallet
            }
        }
        .take(1)
        .trackActivity(indicator)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(onNext: { [weak self] (action) in
            switch action {
            case .presentWallet:
                self?.router?.routeToWallet()

            case .pay(let api):
                self?.payDebt(with: api)
            }
        })
        .disposeOnDeactivate(interactor: self)
    }

    func handlePayWithCard(at index: Int) {
        let o1 = authenticated.firebaseAuthToken.take(1)
        let o2 = cards.map { $0[index] }.take(1)
        let o3 = Observable<[String]>.just(debtInfo.tripIDs)

        Observable<VatoAPIRouter>.combineLatest(o1, o2, o3) { (token, card, tripIDs) -> VatoAPIRouter in
            let api = VatoAPIRouter.payUserDebt(authToken: token, payment: card.type.rawValue, cardID: card.id, tripIDs: tripIDs)
            return api
        }
        .take(1)
        .trackActivity(indicator)
        .subscribe(onNext: { [weak self] (api) in
            self?.payDebt(with: api)
        })
        .disposeOnDeactivate(interactor: self)
    }

    func handleCardManagementAction() {
        router?.routeToWallet()
    }
}

// MARK: Class's private methods
private extension LatePaymentInteractor {
    private func setupRX() {
        
    }

    private func payDebt(with api: VatoAPIRouter) {
        let o: Observable<(HTTPURLResponse, MessageDTO<UserDebtDTO>)> = Requester.requestDTO(using: api,
                                                                                             method: .post,
                                                                                             encoding: JSONEncoding.default,
                                                                                             block: nil)

        o.trackActivity(indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (response) in
                guard response.1.data.amount <= 0 else {
                    self?.errorPublisher.onNext(Text.cannotPayDebt.localizedText)
                    return
                }
                self?.listener?.requestToDismissLatePaymentModule()
                NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
            }, onError: { [weak self] (err) in
                self?.errorPublisher.onNext(Text.cannotPayDebt.localizedText)
            })
            .disposeOnDeactivate(interactor: self)
    }
}
