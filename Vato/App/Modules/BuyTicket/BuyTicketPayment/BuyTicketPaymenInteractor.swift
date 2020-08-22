//  File name   : BuyTicketPaymentInteractor.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCore
import FwiCoreRX
import Alamofire

enum BuyTicketPaymenState {
    case success
    case errorSystem(err: Error)
    case checkoutFailure
    case checkoutPaymentMethodInvalid
    case checkoutMissingUserId
    case checkoutTicketInvalid
    case checkoutTicketPayBefore
    case checkoutTicketPayInvalid
    case checkoutUseBalanceInvalid
    case badRequest
    case unauthorized
    case notFound
    case dataConflict
    case preconditionRequired
    case internalServerError
    case bookTicketNotSuccess
    case updateBookTicketNotSuccess
    case promotionErrorCode
    case requestNotMatchRule
    case other(message: String)
    
    func getMsg() -> String {
        switch self {
        case .success:
            return Text.buyTicketSuccess.localizedText
        case .errorSystem(let e):
            let code = (e as NSError).code
            if code == NSURLErrorNotConnectedToInternet ||
                code == NSURLErrorBadServerResponse {
                return Text.networkDownDescription.localizedText
            } else {
                return e.localizedDescription.orEmpty(Text.thereWasAnErrorFunction.localizedText)
            }
        case .checkoutFailure:
            return Text.paymentFailed.localizedText
        case .checkoutPaymentMethodInvalid:
            return Text.thePaymentMethodIsNotValid.localizedText
        case .checkoutMissingUserId:
            return Text.lackOfCustomerInformation.localizedText
        case .checkoutTicketInvalid:
            return Text.lackOfTicketInformation.localizedText
        case .checkoutTicketPayBefore:
            return Text.ticketsHaveBeenPaidInAdvance.localizedText
        case .checkoutTicketPayInvalid:
            return Text.theTicketIsNotValidForPayment.localizedText
        case .checkoutUseBalanceInvalid:
            return Text.notEnoughVATOPayDescription.localizedText
        case .badRequest:
            return Text.badRequest.localizedText
        case .unauthorized:
            return Text.unauthorized.localizedText
        case .notFound:
            return Text.notFound.localizedText
        case .dataConflict:
            return Text.dataConflict.localizedText
        case .preconditionRequired:
            return Text.preconditionRequired.localizedText
        case .internalServerError:
            return Text.internalServerError.localizedText
        case .bookTicketNotSuccess:
            return Text.bookTicketNotSuccess.localizedText
        case .updateBookTicketNotSuccess:
            return Text.updateBookTicketNotSuccess.localizedText
        case .promotionErrorCode:
            return Text.promotionErrorCode.localizedText
        case .requestNotMatchRule:
            return Text.requestNotMatchRule.localizedText
        case .other(let message):
            return message
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .success:
            return Text.buyTicketSuccess.localizedText
        default:
            return Text.paymentFailed.localizedText
        }
    }
    
    static func generateError(status: Int, message: String?) -> BuyTicketPaymenState {
        if Config.checkoutFailure == status {
            return BuyTicketPaymenState.checkoutFailure
        }
        if Config.checkoutPaymentMethodInvalid == status {
            return BuyTicketPaymenState.checkoutPaymentMethodInvalid
        }
        if Config.checkoutMissingUserId == status {
            return BuyTicketPaymenState.checkoutMissingUserId
        }
        if Config.checkoutTicketInvalid == status {
            return BuyTicketPaymenState.checkoutTicketInvalid
        }
        if Config.checkoutTicketPayBefore == status {
            return BuyTicketPaymenState.checkoutTicketPayBefore
        }
        if Config.checkoutTicketPayInvalid == status {
            return BuyTicketPaymenState.checkoutTicketPayInvalid
        }
        if Config.checkoutUseBalanceInvalid == status {
            return BuyTicketPaymenState.checkoutUseBalanceInvalid
        }
        if Config.badRequest == status {
            return BuyTicketPaymenState.badRequest
        }
        if Config.unauthorized == status {
            return BuyTicketPaymenState.unauthorized
        }
        if Config.notFound == status {
            return BuyTicketPaymenState.notFound
        }
        if Config.dataConflict == status {
            return BuyTicketPaymenState.dataConflict
        }
        if Config.preconditionRequired == status {
            return BuyTicketPaymenState.preconditionRequired
        }
        if Config.internalServerError == status {
            return BuyTicketPaymenState.internalServerError
        }
        if Config.bookTicketNotSuccess == status {
            return BuyTicketPaymenState.bookTicketNotSuccess
        }
        if Config.updateBookTicketNotSuccess == status {
            return BuyTicketPaymenState.updateBookTicketNotSuccess
        }
        if Config.promotionErrorCode == status {
            return BuyTicketPaymenState.promotionErrorCode
        }
        if Config.requestNotMatchRule == status {
            return BuyTicketPaymenState.requestNotMatchRule
        }
        return BuyTicketPaymenState.other(message: message ?? "")
    }
    
    struct Config {
        static let badRequest = 400
        static let unauthorized = 401
        static let notFound = 404
        static let dataConflict = 409
        static let preconditionRequired = 428
        static let internalServerError = 500
        static let bookTicketNotSuccess = 1000
        static let updateBookTicketNotSuccess = 1001
        static let promotionErrorCode = 1003
        static let requestNotMatchRule = 1004
        static let checkoutFailure = -10000
        static let checkoutPaymentMethodInvalid = -10001
        static let checkoutMissingUserId = -10002
        static let checkoutTicketInvalid = -10003
        static let checkoutTicketPayBefore = -10004
        static let checkoutTicketPayInvalid = -10005
        static let checkoutUseBalanceInvalid = -10006
    }
}

enum StopLoadingType {
    case success
    case error(e: Error?)
}

protocol BuyTicketPaymenRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToPaymentMethod()
    func routeToDetailPrice()
    func routeToAddCard()
    func routeToNote(note: NoteDeliveryModel?, noteTextConfig: NoteTextConfig)
    func routeToResultFailBuyTicket(state: BuyTicketPaymenState)
    func routeToResultBuyTicket(streamType: BuslineStreamType)
    func routeToTopupVATOPAY(use config: [TopupLinkConfigureProtocol])
    func showTopupNapas(htmlString: String, redirectUrl: String?)
    func paymentEWallet(method: String, amount: Int, fee: Int, name: String, editParams: ((NSMutableDictionary) -> NSMutableDictionary)?) -> Observable<(JSON, Bool)>
}

protocol BuyTicketPaymentPresentable: Presentable {
    var listener: BuyTicketPaymentPresentableListener? { get set }
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showPopupBalanceInvalid()
    func resetListenAddCard()
}

protocol BuyTicketPaymenListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func buyTicketPaymentMoveBack()
    func moveBackRoot()
    func buyTicketPaymenMoveBack()
    func moveBackBuyNewTicket()
    func moveManagerTicket()
}

final class BuyTicketPaymentInteractor: PresentableInteractor<BuyTicketPaymentPresentable>, ActivityTrackingProtocol {
    private struct Config {
        static let timeOutLoadingApiPayment: TimeInterval = 180// 3 minute
        static let timeOutCallApiPayment: TimeInterval = 120// 3 minute
        static let intervalCallApi = 30// 3 minute
        
        static let url: (String) -> String = { p in
            #if DEBUG
            return "https://api-busline-dev.vato.vn\(p)"
            #else
            return "https://api-busline.vato.vn\(p)"
            #endif
        }
    }
    
    /// Class's public properties.
    weak var router: BuyTicketPaymenRouting?
    weak var listener: BuyTicketPaymenListener?
    private var temp: [TicketRoundTripType: TicketHistoryType] = [:]
    /// Class's constructor.
    init(presenter: BuyTicketPaymentPresentable,
         component: BuyTicketPaymentComponent, streamType: BuslineStreamType ) {
        self.streamType = streamType
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }
    

    deinit {
        UIApplication.shared.endIgnoringInteractionEvents()
        LoadingManager.dismissProgress()
    }
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        loadTopupConfig()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func update(payment method: PaymentCardDetail) {
        component.dependency.buyTicketStream.update(method: method)
        
        // Only save cash || vatopay
        guard let m = method.type.method, m == PaymentMethodCash || m == PaymentMethodVATOPay else {
            return
        }
        
        // firebase update
        if let id = Auth.auth().currentUser?.uid {
            component.firebaseDatabase.updatePaymentMethod(method: m, firebaseId: id)
            component.dependency.mutableProfile.client.take(1).subscribe(onNext: { [weak self] client in
                var nextClient = client
                nextClient.paymentMethod = m
                self?.component.dependency.mutableProfile.updateClient(client: nextClient)
                }, onError: { error in
                    printDebug(error.localizedDescription)
            }).disposeOnDeactivate(interactor: self)
        }
    }
    
    /// Class's private properties.
    private var component: BuyTicketPaymentComponent
    internal let streamType: BuslineStreamType
    private lazy var mStateSubject: PublishSubject<BuyTicketPaymenState> = PublishSubject()
    private lazy var eTopupConfig = ReplaySubject<[TopupLinkConfigureProtocol]>.create(bufferSize: 1)
    private lazy var mProgress = PublishSubject<Double>()
    private let errorSubject = ReplaySubject<BuyTicketPaymenState>.create(bufferSize: 1)
}

// MARK: BuyTicketPaymenInteractable's members
extension BuyTicketPaymentInteractor: BuyTicketPaymenInteractable {
    var buyTicketStream: BuyTicketStreamImpl {
       return component.dependency.buyTicketStream
    }
    
    var paymentStream: PaymentStream {
        return component.dependency.mutablePaymentStream
    }
    
    func topUpMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackBuyNewTicket() {
        listener?.moveBackBuyNewTicket()
    }
    
    func moveManagerTicket() {
        listener?.moveManagerTicket()
    }
    
    func resultBuyTicketMoveBack() {
        listener?.moveBackRoot()
    }
    
    func dismiss() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func updateNote(note: NoteDeliveryModel) {
        component.dependency.buyTicketStream.update(note: note)
        router?.dismissCurrentRoute(completion: nil)
    }

    func switchPaymentMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func updateCardPayment(card: PaymentCardDetail) {
        guard let method = card.type.method else {
            return
        }
        if !(method == PaymentMethodCash || method == PaymentMethodVATOPay) {
            self.component.mutablePaymentStream.update(select: card)
        }
        self.update(payment: card)
    }
    
    func switchPaymentChoose(by card: PaymentCardDetail) {
        router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.update(payment: card)
        })
    }
    
    private func fetchCardData() -> Observable<[PaymentCardDetail]> {
        let router = VatoAPIRouter.listCard(authToken: "")
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: OptionalMessageDTO<[PaymentCardDetail]>.self).map { (result) -> [PaymentCardDetail] in
            let r = try result.get()
            if let e = r.error {
                throw e
            } else {
                return r.data ?? []
            }
        }.catchErrorJustReturn([])
    }
    
    private func updateListCard() {
        fetchCardData().bind(onNext: weakify({ (list, wSelf) in
            wSelf.component.dependency.mutablePaymentStream.update(source: list)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func processNapasPaymentFailure(status: Int, message: String) {
        let errType = BuyTicketPaymenState.generateError(status: status, message: message)
        self.router?.routeToResultFailBuyTicket(state: errType)
    }
}

// MARK: BuyTicketPaymentPresentableListener's members
extension BuyTicketPaymentInteractor: BuyTicketPaymentPresentableListener, Weakifiable {
    var isRoundTrip: Bool {
        return component.dependency.buyTicketStream.isRoundTrip
    }
    
    var returnTicketInformationObser: Observable<TicketInformation> {
        return component.dependency.buyTicketStream.returnTicketObservable
    }
    
    var mError: Observable<BuyTicketPaymenState> {
        return errorSubject.asObserver()
    }
    
    var noteDeliveryObser: Observable<NoteDeliveryModel?> {
        return component.dependency.buyTicketStream.noteDeliveryObser
    }

    func routToNote() {
        let note = component.dependency.buyTicketStream.note
        var noteTextConfig = NoteTextConfig()
        noteTextConfig.titleText = Text.note.localizedText
        noteTextConfig.notePlaceholder = Text.inputNote.localizedText
        noteTextConfig.confirmButton = Text.confirm.localizedText
        
        router?.routeToNote(note: note, noteTextConfig: noteTextConfig)
    }
    
    var stateResult: Observable<BuyTicketPaymenState> {
        return mStateSubject.asObserver()
    }
    
    var eMethod: Observable<PaymentCardDetail> {
        return component.dependency.buyTicketStream.eMethod
    }
    
    func moveBack() {
        listener?.buyTicketPaymenMoveBack()
    }

    var ticketInformation: TicketInformation {
        return component.dependency.buyTicketStream.ticketModel
    }
    
    var ticketInformationObser: Observable<TicketInformation> {
        return component.dependency.buyTicketStream.ticketObservable
    }
    
    var returnTicketInformation: TicketInformation {
        return component.dependency.buyTicketStream.returnTicketModel
    }
    
    func routToPaymentMethod() {
        router?.routeToPaymentMethod()
    }
    
    func routToDetailPrice() {
        router?.routeToDetailPrice()
    }
    
    private func validatePayment() -> Observable<Bool>{
        let card = component.dependency.mutablePaymentStream.currentSelect
        if card?.type == .vatoPay {
            let p = component.dependency.buyTicketStream.ticketModel.totalPrice ?? 0
            return component.dependency.mutableProfile.user.take(1).map { (u) -> Bool in
                let t = u.cash + u.coin
                return t >= p
            }
        } else {
            return Observable.just(true)
        }
    }
    
    private func excutePayment() {
        component.dependency.mutableProfile.client.take(1).bind(onNext: {[weak self] (client) in
            if let clientId = client.user?.id {
                self?.requestPaymentApi(userId: clientId)
            } else {
                // can't load infor user
            }
        }).disposeOnDeactivate(interactor: self)
    }
    
    func requestPaymentTicket() {
        // validate
        validatePayment().bind(onNext: weakify({ (r, wSelf) in
            guard r else {
                wSelf.mStateSubject.onNext(.checkoutUseBalanceInvalid)
                return
            }
            wSelf.excutePayment()
        })).disposeOnDeactivate(interactor: self)
    }
    
    func routeToTopupVATOPAY() {
        self.eTopupConfig.take(1).observeOn(MainScheduler.asyncInstance).bind { [weak self](list) in
            self?.router?.routeToTopupVATOPAY(use: list)
            }.disposeOnDeactivate(interactor: self)
    }
    
    struct ZaloPayRequestTransToken: Codable {
        var zptranstoken: String
    }
    
    func requestZaloPayToken() -> Observable<String> {
        let buyTicketStream = component.dependency.buyTicketStream
        let codes: [String?] = buyTicketStream.isRoundTrip ?
            [self.ticketInformation.ticketsCode, self.returnTicketInformation.ticketsCode] :
            [self.ticketInformation.ticketsCode]

        let paymentMethod = self.ticketInformation.paymentMethod?.type ?? .cash
        let noteStr = buyTicketStream.note?.note ?? ""
        let carId = Int(self.ticketInformation.paymentMethod?.id ?? "0") ?? 0
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ios_client_app"
        var params = JSON()
        let userId = UserManager.instance.info?.userID
        params["userId"] = userId
        params["method"] = paymentMethod.rawValue
        params["description"] = noteStr
        params["ticketCodes"] = codes.compactMap { $0 }
        params["cardId"] = carId
        params["deviceId"] = uuid
        params["autoPay"] = false
        params["paymentInfo"] = ["appid": TopUpAction.Configs.appId]
        let url = "\(VatoTicketApi.host)/buslines/futa/ticket/checkout"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: params, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network
            .request(using: router,
                     decodeTo: OptionalIgnoreMessageDTO<ZaloPayRequestTransToken>.self,
                     method: .post,
                     encoding: JSONEncoding.default)
            .map { try $0.get() }.map { r -> String? in
                if r.error != nil {
                    throw NSError(use: r.message)
                } else {
                    return r.data?.zptranstoken
                }
        }.filterNil()
    }
}

// MARK: Class's private methods
private extension BuyTicketPaymentInteractor {
//    struct Configs {
//        static let url: (String) -> String = { p -> String in
//            let rootURL: String
//            #if DEBUG
//                rootURL = "https://api-busline-dev.vato.vn/api"
//            #else
//                rootURL = "https://api-busline.vato.vn/api"
//            #endif
//            return rootURL + p
//        }
//    }
    
    private func setupRX() {
        eMethod.distinctUntilChanged().subscribe(onNext: {[weak self] (card) in
            self?.component.mutablePaymentStream.update(select: card)
            self?.getPriceFee()
        }).disposeOnDeactivate(interactor: self)
        // todo: Bind data stream here.
    }
    
    private func token() -> Observable<String> {
        return component.dependency
            .authenticatedStream
            .firebaseAuthToken
            .take(1)
    }
    
    private func checkout(params: [String: Any]) -> Observable<OptionalIgnoreMessageDTO<TopUpAtmResponse>> {
        let url = "\(VatoTicketApi.host)/buslines/futa/ticket/checkout"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: params, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network
            .request(using: router,
                     decodeTo: OptionalIgnoreMessageDTO<TopUpAtmResponse>.self,
                     method: .post,
                     encoding: JSONEncoding.default)
            .map { try $0.get() }
    }
    
    private func paymentTicket(by userId: Int64) -> Observable<OptionalIgnoreMessageDTO<TopUpAtmResponse>> {
        if self.ticketInformation.paymentMethod?.params != nil {
            return requestPaymentWithNapas(userId: userId)
        } else {
            let buyTicketStream = component.dependency.buyTicketStream
            let codes: [String?] = buyTicketStream.isRoundTrip ?
                [self.ticketInformation.ticketsCode, self.returnTicketInformation.ticketsCode] :
                [self.ticketInformation.ticketsCode]

            let paymentMethod = self.ticketInformation.paymentMethod?.type ?? .cash
            let noteStr = buyTicketStream.note?.note ?? ""
            let carId = Int(self.ticketInformation.paymentMethod?.id ?? "0") ?? 0
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ios_client_app"
            var params = JSON()
            params["userId"] = userId
            params["method"] = paymentMethod.rawValue
            params["description"] = noteStr
            params["ticketCodes"] = codes.compactMap { $0 }
            params["cardId"] = carId
            params["deviceId"] = uuid
            params["autoPay"] = false
            if let method = self.ticketInformation.paymentMethod,  let methodEwallet = method.methodEwallet {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.stopLoading(type: .success)
                }
                guard let router = self.router else {
                    return Observable.empty()
                }
                var addedFee: Bool = false
                var discount: Double = 0
                var mfee: Double = 0
                let total: Double = [self.ticketInformation, self.returnTicketInformation].filter(\.valid).reduce(0) {
                    let fee = !addedFee ? $1.ticketPrice?.fee : 0
                    addedFee = true
                    mfee += fee.orNil(0)
                    discount += $1.seats.orNil([]).reduce(0, { $0 + $1.discount.orNil(0) })
                    return $0 + $1.totalPrice.orNil(0) + Double(fee.orNil(0))
                }
                
                return router.paymentEWallet(method: methodEwallet, amount: Int(max(total - discount, 0)), fee: Int(mfee), name: method.type.generalName) { (p) -> NSMutableDictionary in
                    let news = p
                    switch method.type {
                    case .momo:
                        news["description"] = "Thanh toán vé Futa Busline"
                        news["merchantnamelabel"] = "Thanh toán vé"
                    default:
                        break
                    }
                    return news
                }.flatMap { [weak self] (p) -> Observable<OptionalIgnoreMessageDTO<TopUpAtmResponse>> in
                    guard let wSelf = self else { return Observable.empty() }
                    wSelf.startLoadingManual()
                    if p.1 {
                        params += p.0
                        return wSelf.checkout(params: params)
                    } else {
                        let json: JSON = ["message": "", "status": 200, "data": ""]
                        do {
                            let model = try OptionalIgnoreMessageDTO<TopUpAtmResponse>.toModel(from: json)
                            return Observable.just(model)
                        } catch {
                            return Observable.error(error)
                        }
                    }
                }
            }
            
            
            return checkout(params: params)
        }
    }
    
    private func requestPaymentWithNapas(userId: Int64) -> Observable<OptionalIgnoreMessageDTO<TopUpAtmResponse>> {
        
        guard var params = self.ticketInformation.paymentMethod?.params else {
            fatalError("Error")
        }
        let buyTicketStream = component.dependency.buyTicketStream
        let codes: [String?] = buyTicketStream.isRoundTrip ?
        [self.ticketInformation.ticketsCode, self.returnTicketInformation.ticketsCode] :
        [self.ticketInformation.ticketsCode]
        
        let url = Config.url("/api/buslines/futa/ticket/checkout-with-napas")
        params["ticketCode"] = codes.compactMap { $0 }.joined(separator: ",")
        params["userId"] = userId
        
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: params, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<TopUpAtmResponse>.self, method: .post, encoding: JSONEncoding.default).map { try $0.get() }
    }
    
    private func changeTicket(by userId: Int64, oldCode: String) -> Observable<OptionalIgnoreMessageDTO<TopUpAtmResponse>> {
        let code = self.ticketInformation.ticketsCode ?? ""
        let buyTicketStream = component.dependency.buyTicketStream
        let paymentMethod = self.ticketInformation.paymentMethod?.type ?? .cash
        let noteStr = buyTicketStream.note?.note ?? ""
        let e = token().flatMap {
            Requester.responseDTO(decodeTo: OptionalIgnoreMessageDTO<TopUpAtmResponse>.self,
                                  using: VatoTicketApi.changeTicket(authToken: $0, newCode: code, oldCode: oldCode, userId: userId, method: paymentMethod.rawValue, description: noteStr), method: .post, encoding: JSONEncoding.default,
                                  progress:
                { [weak self] value in
                    self?.mProgress.onNext(value ?? 0)
            })
            }.map { $0.response }
        return e
    }
    
    private func detailTicket(type: TicketRoundTripType) -> Observable<TicketHistoryType?> {
        let m = type == .startTicket ? self.ticketInformation : self.returnTicketInformation
        let code = m.ticketsCode ?? ""
        guard !code.isEmpty else {
            return Observable.empty()
        }
        
        let e = token().flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<TicketHistoryType>.self,
                                  using: VatoTicketApi.ticketDetail(authToken: $0, code: code),
                                  progress:
            { [weak self] value in
                self?.mProgress.onNext(value ?? 0)
            })
        }.map { $0.response.data }
        return e.catchErrorJustReturn(nil).map({ [weak self](r) -> TicketHistoryType? in
            self?.temp[type] = r
            if r?.status == .processing {
                throw NSError(domain: NSURLErrorDomain, code: 6, userInfo: nil)
            } else {
                return r
            }
        })
    }
    
    private func getPriceFee() {
        var price = self.ticketInformation.totalPrice.orNil(0)
        if self.component.dependency.buyTicketStream.isRoundTrip {
            price += self.returnTicketInformation.totalPrice.orNil(0)
        }
        
        let paymentMethod = self.ticketInformation.paymentMethod?.type ?? .vatoPay
        if paymentMethod == .none {
            //TOTO: need update later
            return
        }
        LoadingManager.showProgress(duration: 60)
        UIApplication.shared.beginIgnoringInteractionEvents()
        token().flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<TicketPrice>.self,
                                  using: VatoTicketApi.price(authToken: $0, price: price, paymentMethod: paymentMethod.rawValue), method: .get,
                                  progress:
                { [weak self] value in
                    self?.mProgress.onNext(value ?? 0)
            })
            .observeOn(MainScheduler.instance)
            }.subscribe(onNext: {[weak self] (r) in
                if r.response.fail == true {
                    let errType = BuyTicketPaymenState.generateError(status: r.response.status, message: r.response.message)
                    self?.errorSubject.onNext(errType)
                } else if let price = r.response.data {
                    self?.component.dependency.buyTicketStream.update(ticketPrice: price)
                }
                
                UIApplication.shared.endIgnoringInteractionEvents()
                LoadingManager.dismissProgress()
            }, onError: { [weak self] (e) in
                self?.errorSubject.onNext(.errorSystem(err: e))
                UIApplication.shared.endIgnoringInteractionEvents()
                LoadingManager.dismissProgress()
            }).disposeOnDeactivate(interactor: self)
    }
    
    private func repeatRequestDetail(times: Int,
                                     type: TicketRoundTripType) -> Observable<TicketHistoryType?>
    {
        let numberRetry = times
        return Observable<Int>.interval(.seconds(Config.intervalCallApi), scheduler: MainScheduler.asyncInstance)
            .take(1)
            .flatMap { [weak self](_) -> Observable<TicketHistoryType?> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.detailTicket(type: type)
        }.retry(numberRetry)
    }
    
    private func requestDetailTicket(retry: Bool = false) -> Observable<[TicketHistoryType?]> {
        var events: [Observable<TicketHistoryType?>] = []
        let roundTrip = self.component.buyTicketStream.isRoundTrip
        let update: (TicketRoundTripType, TicketHistoryType?) -> () = { [weak self] (t, res)   in
            switch t {
            case .startTicket:
                self?.component.dependency.buyTicketStream.ticketModel.detail = res
            case .returnTicket:
                self?.component.dependency.buyTicketStream.returnTicketModel.detail = res
            }
        }
        
        if roundTrip {
            let e1: Observable<TicketHistoryType?>
            let e2: Observable<TicketHistoryType?>
            
            if retry {
                func generateRequestDetail(type: TicketRoundTripType) -> Observable<TicketHistoryType?> {
                    return detailTicket(type: type).catchError { [weak self](e) -> Observable<TicketHistoryType?> in
                        guard let wSelf = self else { return Observable.empty() }
                        if (e as NSError).code == 6
                        || (e as NSError).code == NSURLErrorTimedOut {
                            return wSelf.repeatRequestDetail(times: 1, type: type).catchError { [weak self](e) -> Observable<TicketHistoryType?> in
                                if (e as NSError).code == 6, let temp = self?.temp[type] {
                                    return Observable.just(temp)
                                } else {
                                    return Observable.error(e)
                                }
                            }
                        }else {
                            return Observable.error(e)
                        }
                    }.do(onNext: {
                        update(type, $0)
                    })
                }
                e1 = generateRequestDetail(type: .startTicket)
                e2 = generateRequestDetail(type: .returnTicket)
                
            } else {
                e1 = detailTicket(type: .startTicket).do(onNext: {
                    update(.startTicket, $0)
                })
                e2 = detailTicket(type: .returnTicket).do(onNext: {
                   update(.returnTicket, $0)
                })
            }
            
            events += [e1, e2]
            
        } else {
            let e1: Observable<TicketHistoryType?>
            if !retry {
                e1 = detailTicket(type: .startTicket).do(onNext: {
                    update(.startTicket, $0)
                })
            } else {
                e1 = detailTicket(type: .startTicket).catchError { [weak self](e) -> Observable<TicketHistoryType?> in
                    guard let wSelf = self else { return Observable.empty() }
                    if (e as NSError).code == 6
                    || (e as NSError).code == NSURLErrorTimedOut {
                        return wSelf.repeatRequestDetail(times: 1, type: .startTicket).catchError { [weak self](e) -> Observable<TicketHistoryType?> in
                            if (e as NSError).code == 6, let temp = self?.temp[.startTicket] {
                                return Observable.just(temp)
                            } else {
                                return Observable.error(e)
                            }
                        }
                    }else {
                        return Observable.error(e)
                    }
                }.do(onNext: {
                    update(.startTicket, $0)
                })
            }
            
            events.append(e1)
        }
        return Observable.zip(events)
    }
    
    private func startLoadingManual() {
        LoadingManager.showProgress(duration: Config.timeOutLoadingApiPayment)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    private func requestPaymentApi(userId: Int64) {
        var result: Observable<OptionalIgnoreMessageDTO<TopUpAtmResponse>>
        switch self.streamType {
        case .changeTicket(let model):
            result = changeTicket(by: userId, oldCode: model.ticketCode)
        case .buyNewticket, .roundTrip:
            result = paymentTicket(by: userId)
        }
        
        let detail = requestDetailTicket(retry: true)
        startLoadingManual()
        result.flatMap { (r) -> Observable<OptionalIgnoreMessageDTO<TopUpAtmResponse>> in
            return detail.map { _ in r }
            }.observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (r) in
                if r.fail == false || r.status == BuyTicketPaymenState.Config.checkoutTicketPayBefore {
                    if let data = r.data, let html = data.html {
                        self?.router?.showTopupNapas(htmlString: html, redirectUrl: data.redirectUrl)
                    } else {
                        self?.processPaymentSuccess()

                    }
                } else {
                    self?.processPaymentFail(r: r)
                }
                
                self?.stopLoading(type: .success)
                }, onError: {[weak self] (e) in
                    // 6 timeout
                self?.stopLoading(type: .error(e: e))
            }).disposeOnDeactivate(interactor: self)
        
    }
    
    func processPaymentSuccess() {
        // Check
        let list = [self.component.buyTicketStream.ticketModel, self.component.buyTicketStream.ticketModel].filter(where: \.valid)
        let valid = list.map(\.detail?.status).reduce(true, { $0 && ($1 == .success)})
        guard valid else {
            self.router?.routeToResultFailBuyTicket(state: .bookTicketNotSuccess)
            return
        }
        
        if let originLocation = self.component.buyTicketStream.ticketModel.originLocation,
            let destLocation = self.component.buyTicketStream.ticketModel.destinationLocation {
            TicketLocalStore.shared.save(originLocation: originLocation, destLocation: destLocation)
        }
        NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: historyDidChangeNotify), object: nil)
        
        self.router?.routeToResultBuyTicket(streamType: self.streamType )
    }
    
    func processPaymentFail(r: OptionalIgnoreMessageDTO<TopUpAtmResponse>) {
        let errType = BuyTicketPaymenState.generateError(status: r.status, message: r.message)
        switch errType {
        case .checkoutUseBalanceInvalid:
            self.presenter.showPopupBalanceInvalid()
        default:
            if let m = r.message, !m.isEmpty {
                let e = NSError.error(message: m, code: r.status)
                self.router?.routeToResultFailBuyTicket(state: .errorSystem(err: e))
            } else {
                self.router?.routeToResultFailBuyTicket(state: errType)
            }
        }
    }
        
    private func stopLoading(type: StopLoadingType) {
        LoadingManager.dismissProgress()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        switch type {
        case .error(let error):
            let e = error ?? NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: Text.thereWasAnErrorFunction.localizedText])
            self.router?.routeToResultFailBuyTicket(state: .errorSystem(err: e))
            
        default:
            break
        }
    }
    
    private func getConfig() -> Observable<[TopupLinkConfigureProtocol]> {
        let router = self.token()
            .timeout(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .map({ VatoAPIRouter.userTopupConfig(authToken: $0) })
        
        let request = router.flatMap ({ r -> Observable<(HTTPURLResponse, OptionalMessageDTO<[TopupConfigResponse]>)> in
            Requester.requestDTO(using: r)
        }).map { r -> [TopupLinkConfigureProtocol] in
            r.1.data ?? []
            }.catchErrorJustReturn([])
        return request
    }
    
    private func loadTopupConfig() {
        getConfig().bind { [weak self] in
            self?.eTopupConfig.onNext($0)
        }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: - Generate request
extension BuyTicketPaymentInteractor {
    private func generateRequest(type: TicketRoundTripType) -> Observable<TicketHistoryType?> {
        return detailTicket(type: type).catchError { [weak self](e) -> Observable<TicketHistoryType?> in
             guard let wSelf = self else { return Observable.empty() }
                if (e as NSError).code == 6
                    || (e as NSError).code == NSURLErrorTimedOut {
                 return wSelf.repeatRequestDetail(times: 1, type: type)
             } else {
                 return Observable.error(e)
             }
        }
    }
}

// MARK: - Payment Napas
enum BuyNapasError: Int, Error {
    case retry
    case error
}
extension BuyTicketPaymentInteractor {
    func processNapasPaymentSuccess() {
        var events: [Observable<TicketHistoryType?>] = []
        let validate: (TicketHistoryType?) throws -> TicketHistoryType? = { item in
            if item?.statusInt == 3 {
                throw BuyNapasError.retry
            } else {
                return item
            }
        }
        
        let update: (TicketRoundTripType, TicketHistoryType?) -> () = { [weak self] (t, res)   in
            switch t {
            case .startTicket:
                self?.component.dependency.buyTicketStream.ticketModel.detail = res
            case .returnTicket:
                self?.component.dependency.buyTicketStream.returnTicketModel.detail = res
            }
        }
        
        let event1 = generateRequest(type: .startTicket).map(validate).catchError { [weak self](e) -> Observable<TicketHistoryType?> in
            if let e = e as? BuyNapasError, e == .retry {
                guard let wSelf = self else { return Observable.empty() }
                return wSelf.repeatRequestDetail(times: 1, type: .startTicket)
            } else {
                return Observable.error(e)
            }
        }.do(onNext: {
            update(.startTicket, $0)
        })
        events.append(event1)
        
        if self.component.buyTicketStream.isRoundTrip {
            let event2 = generateRequest(type: .returnTicket).map(validate).catchError { [weak self](e) -> Observable<TicketHistoryType?> in
                if let e = e as? BuyNapasError, e == .retry {
                    guard let wSelf = self else { return Observable.empty() }
                    return wSelf.repeatRequestDetail(times: 1, type: .returnTicket)
                } else {
                    return Observable.error(e)
                }
            }.do(onNext: {
                update(.returnTicket, $0)
            })
            events.append(event2)
        }
        LoadingManager.showProgress(duration: 60)
        UIApplication.shared.beginIgnoringInteractionEvents()
        Observable.zip(events).do(onDispose: {
            UIApplication.shared.endIgnoringInteractionEvents()
            LoadingManager.dismissProgress()
        }).bind { [weak self] items in
            guard let wSelf = self else { return }
            let success = items.map { $0?.status == .success }.reduce(true) { $0 && $1 }
            guard success else {
                wSelf.router?.routeToResultFailBuyTicket(state: .bookTicketNotSuccess)
                return
            }
            
            defer {
                wSelf.updateListCard()
            }
            
            wSelf.processPaymentSuccess()
        }.disposeOnDeactivate(interactor: self)
        
    }
}

// MARK: Wallet
extension BuyTicketPaymentInteractor {
    func wallet(handle action: WalletAction) {
        switch action {
        case .moveBack:
            router?.dismissCurrentRoute(completion: presenter.resetListenAddCard)
        }
    }
    
    func getBalance() {}
    func updateUserBalance(cash: Double, coin: Double) {}
    func showTopUp() {}
    
    func routeToAddCard() {
        router?.routeToAddCard()
    }
}

