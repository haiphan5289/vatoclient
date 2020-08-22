//  File name   : SwitchPaymentInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Firebase
import RxCocoa
import VatoNetwork
import FwiCore
import FwiCoreRX

enum SwitchPaymentType {
    case service(service: VatoServiceType)
    case topupNapas
    case all
    case food
    
    func listTypeAllow() -> [PaymentCardType] {
        switch self {
        case .service(let serviceId):
            let serviceIds = FireStoreConfigDataManager.shared.listPaymentMethodAllow(serviceId: serviceId.rawValue)
            return PaymentCardType.allCases.filter{ serviceIds.contains($0.rawValue) == true }
        case .topupNapas:
            return [.visa, .master]
        case .food:
            let serviceIds = FireStoreConfigDataManager.shared.listPaymentMethodAllow(serviceId: 512)
            return PaymentCardType.allCases.filter{ serviceIds.contains($0.rawValue) == true }
        default:
            return PaymentCardType.allCases
        }
    }
    
    func isAllowAddNapas() -> Bool {
        switch self {
        case .service(let serviceId):
            let serviceIds = FireStoreConfigDataManager.shared.listPaymentMethodAllow(serviceId: serviceId.rawValue)
            return serviceIds.contains(PaymentCardType.visa.rawValue) && serviceIds.contains(PaymentCardType.master.rawValue)
        default:
            return true
        }
    }
    
    func listDirectCard() -> [PaymentCardDetail] {
        switch self {
        case .service(let service):
            return FireStoreConfigDataManager.shared.allowPaymentDirect(service: service)
        default:
            return []
        }
        
    }
    
    func isAllowCheckoutDirectly() -> Bool {
        switch self {
        case .service(let service):
            return service == .buyTicket
        default:
            return false
        }
    }
}


protocol SwitchPaymentRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func switchPaymentMoveBack()
    func routeToManageCard()
    func paymentAddCard(from url: URL)

}

protocol SwitchPaymentPresentable: Presentable {
    var listener: SwitchPaymentPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showAlertConfirmPaymentMethod(payment: PaymentCardDetail)
}

protocol SwitchPaymentListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func switchPaymentMoveBack()
    func switchPaymentChoose(by card: PaymentCardDetail)
}

enum PaymentDetailSectionType {
    case existing
    case others
    
    var description: String {
        switch self {
        case .existing:
            return Text.selectPaymentMethod.localizedText
        case .others:
            return Text.otherMoneySource.localizedText
        }
    }
}


typealias PaymentDetailSection = (type: PaymentDetailSectionType, values: [PaymentCardDetail])

final class SwitchPaymentInteractor: PresentableInteractor<SwitchPaymentPresentable>, SwitchPaymentInteractable, SwitchPaymentPresentableListener, ActivityTrackingProtocol {
    
    
    var source: Observable<[PaymentDetailSection]> {
        return mSource.observeOn(MainScheduler.asyncInstance)
    }

    weak var router: SwitchPaymentRouting?
    weak var listener: SwitchPaymentListener?
    private (set) var currentSelect: PaymentCardDetail?
    private let firebaseDatabase: DatabaseReference
    private let paymentStream: MutablePaymentStream
    private let authenticatedStream: AuthenticatedStream
    private let profileStream: ProfileStream
    private lazy var mSource: ReplaySubject<[PaymentDetailSection]> = ReplaySubject.create(bufferSize: 1)
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    private lazy var mError: PublishSubject<Error> = PublishSubject()
    var switchPaymentType: SwitchPaymentType
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var error: Observable<Error> {
        return mError.observeOn(MainScheduler.asyncInstance)
    }
    
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: SwitchPaymentPresentable,
         firebaseDatabase: DatabaseReference,
         paymentStream: MutablePaymentStream,
         authenticatedStream: AuthenticatedStream,
         profileStream: ProfileStream,
         switchPaymentType: SwitchPaymentType) {
        self.firebaseDatabase = firebaseDatabase
        self.paymentStream = paymentStream
        self.authenticatedStream = authenticatedStream
        self.profileStream = profileStream
        self.switchPaymentType = switchPaymentType
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        self.currentSelect = self.paymentStream.currentSelect
        super.didBecomeActive()
        self.setupRX()
        // todo: Implement business logic here.
    }
    
    private func setupRX() {
        paymentStream.source.bind { [weak self](list) in
            var next = list
            let cash = PaymentCardDetail.cash()
            let vatoPay = PaymentCardDetail.vatoPay()
            
            next.insert(vatoPay, at: 0)
            next.insert(cash, at: 0)
            
            let listTypeAllow = self?.switchPaymentType.listTypeAllow() ?? []
            next = next.filter { listTypeAllow.contains($0.type) == true }
            
            
            let section1: PaymentDetailSection = (type: .existing, values: next)
            var sections: [PaymentDetailSection] = [section1]

            let listPaymentDirect = self?.switchPaymentType.listDirectCard() ?? []
            if !listPaymentDirect.isEmpty {
                sections.append((type: .others, values: listPaymentDirect))
            }
            
            self?.mSource.onNext(sections)
        }.disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func switchPaymentMoveBack() {
        self.router?.switchPaymentMoveBack()
    }
    
    func switchPaymentSelect(payment: PaymentCardDetail) {
       self.listener?.switchPaymentChoose(by: payment)
    }
    
    
    func routeToAddPaymentMethod() {
        self.router?.routeToManageCard()
    }
    
    func paymentManageMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func paymentAddCard() {
        self.authenticatedStream.firebaseAuthToken.take(1).bind { [weak self](token) in
            func mPath() -> String {
                #if DEBUG
                return PaymentMethodManageInteractor.Config.dummyURL
                #else
                return PaymentMethodManageInteractor.Config.realURL
                #endif
            }
            let path = mPath() + "#\(token)"
            guard let wSelf = self, let url = URL(string: path) else { return }
            wSelf.router?.paymentAddCard(from: url)
            }.disposeOnDeactivate(interactor: self)
    }
    
    func loadData() {
        fetchData()
            .trackProgressActivity(self.trackProgress)
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self](list) in
                guard let wSelf = self else { return }
                wSelf.paymentStream.update(source: list)
            }.disposeOnDeactivate(interactor: self)
    }
    
    private func fetchData() -> Observable<[PaymentCardDetail]> {
        let router = authenticatedStream.firebaseAuthToken.take(1).map { VatoAPIRouter.listCard(authToken: $0) }
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
    
    func paymentAddCardMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func paymentAddCardSuccess() {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            guard let me = self else { return }
            me.loadData()
        })
    }
}
