//  File name   : TicketHistoryDetailInteractor.swift
//
//  Author      : vato.
//  Created date: 10/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire
import FwiCore
import FwiCoreRX

protocol TicketHistoryDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToCancel(item: TicketHistoryType)
    func routeToChangeTicket(item: TicketHistoryType)
    func routeToTicketRouteDetail(_ info: DetailRouteInfo)
}

protocol TicketHistoryDetailPresentable: Presentable {
    var listener: TicketHistoryDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showPopupPaymentSucces()
    func setupModel(ticketHistoryType: TicketHistoryType?)
}

protocol TicketHistoryDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func paymentSuccess()
    func didCancelTicket()
    func ticketHistoryDetailMoveBack()
    func moveBackBuyNewTicket()
}

final class TicketHistoryDetailInteractor: PresentableInteractor<TicketHistoryDetailPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: TicketHistoryDetailRouting?
    weak var listener: TicketHistoryDetailListener?

    /// Class's constructor.
    init(presenter: TicketHistoryDetailPresentable,
         ticketHistoryType: TicketHistoryType?,
         authStream: AuthenticatedStream?,
         profileStream: ProfileStream? ) {
         self.authStream =  authStream
         self.profileStream =  profileStream
        self.ticketHistoryType = ticketHistoryType
        super.init(presenter: presenter)
        presenter.listener = self
        presenter.setupModel(ticketHistoryType: ticketHistoryType)
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        requestDetailTicket()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private let authStream: AuthenticatedStream?
    private let profileStream: ProfileStream?
    private var ticketHistoryType: TicketHistoryType? {
        didSet {
            if let _ticketHistoryType = self.ticketHistoryType {
                ticketHistoryTypeSubject.onNext(_ticketHistoryType)
            }
        }
    }
    private lazy var mStateSubject: PublishSubject<BuyTicketPaymenState> = PublishSubject()
    private lazy var ticketHistoryTypeSubject: PublishSubject<TicketHistoryType?> = PublishSubject()
}

// MARK: TicketHistoryDetailInteractable's members
extension TicketHistoryDetailInteractor: TicketHistoryDetailInteractable {
    func ticketDetailRouteMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveManagerTicket() {
        self.listener?.ticketHistoryDetailMoveBack()
    }
    
    func moveBackRoot() {
        self.listener?.ticketHistoryDetailMoveBack()
    }
    
    func moveBackBuyNewTicket() {
        self.listener?.moveBackBuyNewTicket()
    }
    
    func changeTicketMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func cancelTicketMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func cancelTicketSuccess(item: TicketHistoryType) {
        router?.dismissCurrentRoute(completion: nil)
        self.listener?.didCancelTicket()
        self.requestDetailTicket()
    }
}

// MARK: TicketHistoryDetailPresentableListener's members
extension TicketHistoryDetailInteractor: TicketHistoryDetailPresentableListener {
    var ticketHistoryTypeObser: Observable<TicketHistoryType?> {
        return ticketHistoryTypeSubject.asObserver()
    }
    
    func ticketHistoryDetailMoveBack() {
        listener?.ticketHistoryDetailMoveBack()
    }
    
    func paymentSuccess() {
        self.requestDetailTicket()
        self.listener?.paymentSuccess()
    }
    
    var eLoadingObser: Observable<(Bool,Double)> {
        return self.indicator.asObservable()
    }
    
    var stateResult: Observable<BuyTicketPaymenState> {
        return mStateSubject.asObserver()
    }
    
    private func requestDetailTicketRoute(item: TicketHistoryType?) {
        guard let value = item else {
            return
        }
        
        guard let routeId = value.routeId,
            let wayID = value.wayId else
        {
            return
        }
        
        let url = "\(VatoTicketApi.host)/buslines/futa/routes/\(routeId)/roadmap?wayId=\(wayID)"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[DetailRoute]>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail == false {
                        var item = DetailRouteInfo()
                        item.listDetailRoute = d.data ?? []
                        item.nameFrom = value.originName
                        item.nameTo = value.destName
                        item.departureDate = value.departureDate
                        item.departureTime = value.departureTime
                        wSelf.showTicketRouteDetail(item)
                    } else {
                        print(d.message ?? "")
                  }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func showTicketRouteDetail(_ info: DetailRouteInfo) {
        router?.routeToTicketRouteDetail(info)
    }
    
    func processAction(type: ActionSelectTicket, ticketHistoryType: TicketHistoryType) {
        switch type {
        case .routeInfo:
            requestDetailTicketRoute(item: ticketHistoryType)
        case .changeTicket:
            router?.routeToChangeTicket(item: ticketHistoryType)
        case .cancelTicket:
            router?.routeToCancel(item: ticketHistoryType)
        case .rebookTicket:
            break
        case .supportTicket:
            break
        case .shareTicket:
            break
        }
    }
    
    func didSeletctPayment() {
        profileStream?.client.take(1).bind(onNext: {[weak self] (client) in
            if let clientId = client.user?.id {
                self?.requestPaymentApi(userId: clientId)
            } else {
                // can't load infor user
            }
        }).disposeOnDeactivate(interactor: self)
    }
    
    func requestDetailTicket() {
        guard let code = self.ticketHistoryType?.code else { return }
        authStream?
            .firebaseAuthToken
            .take(1)
            .flatMap{ (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<TicketHistoryType>)> in
                Requester.requestDTO(using: VatoTicketApi.ticketDetail(authToken: token, code: code))
            }.observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: {[weak self] (r) in
                if r.1.fail == true {
                    let errType = BuyTicketPaymenState.generateError(status: r.1.status, message: r.1.message)
                    self?.mStateSubject.onNext(errType)
                    self?.ticketHistoryTypeSubject.onNext(self?.ticketHistoryType)
                } else {
                    self?.ticketHistoryType = r.1.data
                }
                }, onError: {[weak self] (e) in
                    self?.mStateSubject.onNext(.errorSystem(err: e))
                    self?.ticketHistoryTypeSubject.onNext(self?.ticketHistoryType)
            }).disposeOnDeactivate(interactor: self)
    }
    
}

// MARK: Class's private methods
private extension TicketHistoryDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    private func requestPaymentApi(userId: Int64) {
        let noteStr = ""
        let code = ticketHistoryType?.code ?? ""
        let paymentMethodVATOPay = PaymentMethodVATOPay
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ios_client_app"
        let codes = [ticketHistoryType?.code]
        authStream?
            .firebaseAuthToken
            .take(1)
            .flatMap{ (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<ScanQRResult>)> in
                Requester.requestDTO(using: VatoTicketApi.payment(authToken: token, ticketsCodes: [code], userId: userId, method: paymentMethodVATOPay.rawValue, description: noteStr, cardId: 0, deviceId: uuid), method: .post, encoding: JSONEncoding.default)
            }.observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: {[weak self] (r) in
                if r.1.fail == true {
                    let errType = BuyTicketPaymenState.generateError(status: r.1.status, message: r.1.message)
                    self?.mStateSubject.onNext(errType)
                } else {
                    self?.presenter.showPopupPaymentSucces()
                    NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
                }
                }, onError: {[weak self] (e) in
                    self?.mStateSubject.onNext(.errorSystem(err: e))
            }).disposeOnDeactivate(interactor: self)
    }
    
    
    
    private func loadMethod(by m: PaymentMethod) -> PaymentCardDetail {
        switch m {
        case PaymentMethodVATOPay:
            return PaymentCardDetail.vatoPay()
        default:
            return PaymentCardDetail.cash()
        }
    }
}
