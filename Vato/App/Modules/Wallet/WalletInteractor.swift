//  File name   : WalletInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Firebase
import VatoNetwork
import FirebaseFirestore

import Alamofire

protocol WalletRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
//    func showTopup(items: [TopupLinkConfigureProtocol], paymentStream: MutablePaymentStream?)
    func showDetail(by item: WalletDetailHistoryType)
    func showListWalletHistory()
    func routeToManageCard()
    func routeToTopup()
    func showTopupNapas(type: TopUpNapasWebType)
}

protocol WalletPresentable: Presentable {
    var listener: WalletPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showAlertError(message: String)
}

enum WalletAction {
    case moveBack
}

final class TopupConfigResponse: NSObject, TopupLinkConfigureProtocol, Codable {
    func clone() -> TopupLinkConfigureProtocol {
        let clone = TopupConfigResponse()
        clone.type = self.type
        clone.name = self.name
        clone.url = self.url
        clone.auth = self.auth
        clone.active = self.active
        clone.iconURL = self.iconURL
        clone.min = self.min
        clone.max = self.max
        clone.options = self.options
        return clone
    }
    
    var type: Int = 0
    var name: String?
    var url: String?
    var auth: Bool = false
    var active: Bool = false
    var iconURL: String?
    var min: Int = 0
    var max: Int = 0
    var options: [Double]?
}



protocol WalletListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func wallet(handle action: WalletAction)
    func getBalance()
    func updateUserBalance(cash: Double, coin: Double)
    func showTopUp()
}

final class WalletInteractor: PresentableInteractor<WalletPresentable>, WalletInteractable, WalletPresentableListener, ActivityTrackingProgressProtocol, LoadingAnimateProtocol {
    weak var router: WalletRouting?
    weak var listener: WalletListener?
    
    let authenticated: AuthenticatedStream
    let firebaseDatabase: DatabaseReference
    let profileStream: ProfileStream
    let paymentStream: MutablePaymentStream
    private (set) lazy var _walletResponse = ReplaySubject<WalletResponse>.create(bufferSize: 1)
    var walletResponse: Observable<WalletResponse> {
        return _walletResponse.asObserver().observeOn(MainScheduler.asyncInstance)
    }
    
    var enableTopUp: Observable<Bool> {
        return eTopupConfig.observeOn(MainScheduler.asyncInstance).map { $0.filter { $0.active }.count > 0 }
    }
    
    var enableManageCard: Observable<Bool> {
        return eAppConfig.map { $0.client_card_config?.active }.filterNil().observeOn(MainScheduler.asyncInstance)
    }
    
    var listCard: Observable<[PaymentCardDetail]> {
        return paymentStream.source
    }
    
    private let balanceType: Int = 3
    private lazy var eTopupConfig = ReplaySubject<[TopupLinkConfigureProtocol]>.create(bufferSize: 1)
    private lazy var eAppConfig = ReplaySubject<AppConfigure>.create(bufferSize: 1)
    private let source: WalletSourceType
    
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: WalletPresentable,
         authenticated: AuthenticatedStream,
         firebaseDatabase: DatabaseReference,
         profileStream: ProfileStream,
         paymentStream: MutablePaymentStream,
         source: WalletSourceType) {
        self.profileStream = profileStream
        self.authenticated = authenticated
        self.firebaseDatabase = firebaseDatabase
        self.paymentStream = paymentStream
        self.source = source
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        processNapasPaymentSuccess(showAlert: false)
        setupRX()
//        requestBalance()
    }
    
    func requestConfig() {
        getConfig().bind { [weak self] in
            self?.eTopupConfig.onNext($0)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func refresh() {
        requestBalance()
        processNapasPaymentSuccess(showAlert: false)
    }
    
    private func setupRX() {
        NotificationCenter.default.rx.notification(NSNotification.Name.topupSuccess).observeOn(MainScheduler.asyncInstance).bind { [weak self](_) in
            // Refesh
            self?.updateBalance()
        }.disposeOnDeactivate(interactor: self)
        
        showLoading(use: self.indicator.asObservable())
        
        self.getAppConfig().bind { [weak self](c) in
            self?.eAppConfig.onNext(c)
        }.disposeOnDeactivate(interactor: self)
        self.profileStream.client.delay(.milliseconds(300), scheduler: SerialDispatchQueueScheduler(qos: .background)).bind { [weak self](_) in
            self?.requestBalance()
        }.disposeOnDeactivate(interactor: self)
        
        paymentStream.newCard
            .skip(1)
            .filterNil()
            .take(1).bind(onNext: weakify({ (_, wSelf) in
            guard wSelf.source == .booking else {
                return
            }
            wSelf.listener?.wallet(handle: .moveBack)
        })).disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func walletMoveBack() {
        self.listener?.wallet(handle: .moveBack)
    }
    
    func paymentManageMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    private func hander(error: Error?) {
        
    }
    
    func detailHistoryMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func showDetail(by item: WalletDetailHistoryType) {
        router?.showDetail(by: item)
    }
    
    func listDetailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func showWalletListHistory() {
        router?.showListWalletHistory()
    }
    
    func routeToManageCard() {
        router?.routeToManageCard()
    }
    
    private func getConfig() -> Observable<[TopupLinkConfigureProtocol]> {
        let router = authenticated.firebaseAuthToken.take(1)
            .timeout(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .map({ VatoAPIRouter.userTopupConfig(authToken: $0) })
        
        let request = router.flatMap ({ r -> Observable<(HTTPURLResponse, OptionalMessageDTO<[TopupConfigResponse]>)> in
            Requester.requestDTO(using: r)
        }).map { r -> [TopupLinkConfigureProtocol] in
            r.1.data ?? []
        }.catchErrorJustReturn([])
        return request
    }
    
    private func getAppConfig() -> Observable<AppConfigure> {
        return self.firebaseDatabase.findAppConfigure().take(1)
    }
    
    func showTopup() {
        self.router?.routeToTopup()
    }
    
    func topUpMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func updateBalance() {
        requestBalance()
    }
    
    func requestBalance() {
        let router = authenticated.firebaseAuthToken.take(1)
            .map({ VatoAPIRouter.getBalance(authToken: $0) })
        
        let request = router.flatMap ({ r -> Observable<(HTTPURLResponse, OptionalMessageDTO<WalletResponse>)> in
            Requester.requestDTO(using: r)
        }).trackProgressActivity(self.indicator)
        .observeOn(MainScheduler.asyncInstance)
        
        request.subscribe { [weak self](e) in
            switch e {
            case .next(let response):
                if let w = response.1.data {
                    self?._walletResponse.onNext(w)
                    self?.listener?.updateUserBalance(cash: w.cash, coin: w.coin)
                } else {
                    self?.hander(error: response.1.error)
                }
            case .error(let e):
                self?.hander(error: e)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    struct Config {
        static let limitdays: Double = 2505600000
    }
    
    func requestListTransactions() -> Observable<[WalletItemDisplayProtocol]> {
        let to = Date().timeIntervalSince1970 * 1000
        let from = to - Config.limitdays
        let balanceType = self.balanceType
        let router = authenticated.firebaseAuthToken.take(1)
            .timeout(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .map({
                VatoAPIRouter.userTransactions(authToken: $0, fromDate: UInt64(from), toDate: UInt64(to), page: 0, size: 10, balanceType: balanceType)
            })
        
        let request = router.flatMap ({ r -> Observable<(HTTPURLResponse, OptionalMessageDTO<WalletTransactionsHistoryResponse>)> in
            Requester.requestDTO(using: r)
        }).observeOn(MainScheduler.asyncInstance).map { item -> [WalletItemDisplayProtocol] in
            let trans = item.1.data?.transactions
            let result: [WalletItemDisplayProtocol] = (trans ?? [])
            return result
        }
        return request
    }
}

struct DataKeyNapas: Codable {
    var apiOperation: String?
    var clientIp: String?
    var html: String?
}

extension WalletInteractor: Weakifiable {
    func routeToAddCard(card: PaymentCardDetail) {
        guard var params = card.params, !params.isEmpty else {
            return
        }
        params["description"] = nil
        params["orderAmount"] = 5000
        params["orderCurrency"] = "VND"
        params["deviceId"] = "unknown"
        params["enable3DSecure"] = card.enable3d
        let router = VatoAPIRouter.customPath(authToken: "", path: "balance/napas/get_data_key", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<DataKeyNapas>.self, method: .post, encoding: JSONEncoding.default).trackProgressActivity(indicator).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                if let e = r.error {
                    wSelf.processNapasPaymentFailure(status: -1000, message: e.localizedDescription)
                } else {
                    guard let html = r.data?.html else {
                        return
                    }
                    wSelf.router?.showTopupNapas(type: .local(htmlString: html, redirectUrl: nil))
                }
            case .failure(let e):
                wSelf.processNapasPaymentFailure(status: -1000, message: e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
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
            }.catchError { (e) -> Observable<[PaymentCardDetail]> in
            return Observable.error(e)
        }
    }
    
    func processNapasPaymentSuccess(showAlert: Bool) {
        fetchData().trackProgressActivity(indicator).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let list):
                wSelf.paymentStream.update(source: list)
            case .error(let e):
                guard showAlert else {
                    return
                }
                wSelf.processNapasPaymentFailure(status: -1000, message: e.localizedDescription)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func processNapasPaymentFailure(status: Int, message: String) {
        presenter.showAlertError(message: message)
    }
}
