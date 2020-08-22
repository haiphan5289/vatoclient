//  File name   : CheckOutInteractor.swift
//
//  Author      : khoi tran
//  Created date: 12/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Alamofire
import VatoNetwork

protocol CheckOutRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToLocationPicker(placeModel: AddressProtocol?, searchType: SearchType, typeLocationPicker: LocationPickerDisplayType)
    func routeToChooseTime(model: DateTime?)
    func routeToNote(note: NoteDeliveryModel?, noteTextConfig: NoteTextConfig)
    func routeToPaymentMethod()
    func routeToStoreTracking(order: SalesOrder)
    func routeToDetailPrice()
    func routeToProductMenu(product: DisplayProduct, basketItem: BasketStoreValueProtocol?)
    func routeToTopup()
    func routeToPromotionStore(storeID: Int)
    func routeToAddCard()
}

protocol CheckOutPresentable: Presentable {
    var listener: CheckOutPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func update(from type: BookingConfirmUpdateType)
    func showAlertComfirmClearBasket()
    func showAlertTopUp()
    func showDetailPromotion(promotionItem: EcomPromotion?, removed: Bool)
    func resetListenAddCard()
    func cleanUpWindows(completion: (() -> ())?)
    func alertNotifyRemoveOrder(cancel: @escaping AlertBlock, ok: @escaping AlertBlock)
}

protocol CheckOutListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismissCheckOut()
    func showReceipt(salesOrder: SalesOrder)
    func routeToFoodDetail()
}

final class CheckOutInteractor: PresentableInteractor<CheckOutPresentable>, RequestInteractorProtocol, ActivityTrackingProgressProtocol, Weakifiable {
    /// Class's public properties.
    weak var router: CheckOutRouting?
    weak var listener: CheckOutListener?
    
    struct Config {
        struct Tracking {
            static let CreateOrderFail = "food_createorder_fail"
        }
        static let url: (String) -> String = { p in
            return VatoFoodApi.host + p
        }
    }
    
    /// Class's constructor.
    init(presenter: CheckOutPresentable,
         authenticated: AuthenticatedStream,
         mutableStoreStream: MutableStoreStream,
         mutablePaymentStream: MutablePaymentStream,
         mProfileStream: ProfileStream,
         firebaseDatabase: DatabaseReference) {
        
        self.firebaseDatabase = firebaseDatabase
        self.mProfileStream = mProfileStream
        self.mutablePaymentStream = mutablePaymentStream
        self.authenticated = authenticated
        self.mutableStoreStream = mutableStoreStream
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        // promotions
        requestPromotions()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func update(payment method: PaymentCardDetail) {
        mutableStoreStream.update(paymentCard: method)
        createQuoteCard()
    }
    
    private func requestPromotions() {
        mutableStoreStream.currentStoreId.filterNil().take(1).bind(onNext: weakify({ (id, wSelf) in
            wSelf.requestPromotions(storeID: id)
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func requestPromotions(storeID: Int) {
        let host = VatoFoodApi.host
        let p = "\(host)" + "/ecom/promotion/merchant/list-all-campaign/\(storeID)"
        var params = JSON()
        params["indexPage"] = 0
        params["sizePage"] = 1000
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: params, useFullPath: true)
        request(router: router, decodeTo: EcomPromotionResponse.self).bind(onNext: weakify({ (response, wSelf) in
            let i = response.items.map { items -> [EcomPromotionDisplay] in
                items.map {
                    return EcomPromotionDisplay(with: $0)
                }
            }
            wSelf.mItemsPromotion = i
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : InitializeValueProtocol {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: OptionalMessageDTO<T>.self)
            .map {
                try $0.get().data
            }
            .filterNil()
    }
    
    private func checkSelectPromotion() {
        $mItemsPromotion.filterNil().take(1).bind(onNext: weakify({ (list, wSelf) in
            list.forEach { $0.applied = false }
            defer {
                wSelf.mItemsPromotion = list
            }
            guard let current = wSelf.promotionItem else { return }
            list.first(where: { $0.promotion == current })?.applied = true
        })).disposeOnDeactivate(interactor: self)
    }
    
    /// Class's private properties.
    
    var token: Observable<String> {
        return authenticated.firebaseAuthToken.take(1)
    }
    private var disposeWallet: Disposable?
    private var topUpAction: TopUpAction?
    private var disposeCreateQuoteCard: Disposable?
    private lazy var defaultReachabilityService: DefaultReachabilityService? = try? DefaultReachabilityService()
    private let authenticated: AuthenticatedStream
    private let mutableStoreStream: MutableStoreStream
    private let mutablePaymentStream: MutablePaymentStream
    private lazy var infoReceiver: DeliveryInputInformation = DeliveryInputInformation(type: .receiver)
    private lazy var mReceiver = ReplaySubject<DeliveryInputInformation>.create(bufferSize: 1)
    private let mProfileStream: ProfileStream
    private let firebaseDatabase: DatabaseReference
    private var voucher: String?
    private var promotionItem: EcomPromotion? {
        didSet {
            guard promotionItem != oldValue else {
                return
            }
            checkSelectPromotion()
        }
    }
    @Replay(queue: MainScheduler.asyncInstance) private var errorSubject: MerchantState
    @Replay(queue: MainScheduler.asyncInstance) var mItemsPromotion: [EcomPromotionDisplay]?
    private var orderId: String? {
        didSet {
            guard let old = oldValue, self.orderId != old  else {
                return
            }
            cancelOrder(id: old)
        }
    }
    private var userId: Int64?
    private var currentOrder: SalesOrder?
}

private extension CheckOutInteractor {
    func loadMethod(by m: PaymentMethod) -> PaymentCardDetail {
        switch m {
        case PaymentMethodVATOPay:
            return PaymentCardDetail.vatoPay()
        default:
            return PaymentCardDetail.cash()
        }
    }
}

// MARK: CheckOutInteractable's members
extension CheckOutInteractor: CheckOutInteractable, LocationRequestProtocol {
    var paymentStream: PaymentStream {
        return mutablePaymentStream
    }
    
    var listPromotions: Observable<[EcomPromotionDisplay]?> {
        return $mItemsPromotion
    }
    
    var interval: TimeInterval {
        return mutableStoreStream.bookingTimeInterval
    }
    
    func ecomPromotionMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ecomPromotion(selected: EcomPromotion) {
        router?.dismissCurrentRoute(completion: { [weak self] in
            self?.applyPromotion(item: selected)
        })
    }
    
    func ecomPromotionVoucher(string: String?) {
        router?.dismissCurrentRoute(completion: { [weak self] in
            self?.applyVoucher(v: string)
        })
    }
    
    func topUpMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func productMenuMoveBack() {
        self.router?.dismissCurrentRoute(true, completion: nil)
    }
    
    func productMenuConfirm(product: DisplayProduct, basketItem: BasketStoreValueProtocol?) {
        self.router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.updateBasket(product: product, basketItem: basketItem)
        }))
    }
    
    func removeProduct(productId: Int) {
        self.mutableStoreStream.basket.take(1).bind(onNext: weakify({ (b, wSelf) in
            guard let i =  b.keys.first(where: { $0.productId == productId }) else { return }
            wSelf.updateBasket(product: i, basketItem: nil)
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func updateBasket(product: DisplayProduct, basketItem: BasketStoreValueProtocol?) {
        self.mutableStoreStream.update(item: product, value: basketItem)
        
        self.mutableStoreStream.basket.take(1).bind {[weak self] (basket) in
            guard let wSelf = self else { return }
            if !basket.isEmpty {
                wSelf.createQuoteCard()
            } else {
                wSelf.clearBasket()
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func showReceipt(salesOrder: SalesOrder) {
        // reset store stream, when show receipt for new order
        self.mutableStoreStream.reset()
        listener?.showReceipt(salesOrder: salesOrder)
    }
    
    func detailPriceDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func trackingRouteToFood() {}
    
    func detailPriceCheckOut() {
        self.router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.createOrder()
        }))
    }
    
    func dismissStoreTracking() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            guard let me = self else { return }
            me.update(model: model)
        })
    }
    
    private func update(model: AddressProtocol) {
        updateAddress(model: model, update: weakify({ (new, wSelf) in
            wSelf.mutableStoreStream.update(address: new)
            wSelf.createQuoteCard()
        }))
    }
    
    // switchPayment
    func switchPaymentMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func switchPaymentChoose(by card: PaymentCardDetail) {
        guard let method = card.type.method else {
            return
        }
        router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            if !(method == PaymentMethodCash || method == PaymentMethodVATOPay) {
                wSelf.mutablePaymentStream.update(select: card)
            }
            wSelf.update(payment: card)
        })
    }
    
    // time picker
    func selectTime(model: DateTime?) {
        mutableStoreStream.update(time: model)
        self.createQuoteCard()
    }
    
    // note
    func dismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func updateNote(note: NoteDeliveryModel) {
        mutableStoreStream.update(note: note)
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToProductMenu(productId: Int) {
        self.mutableStoreStream.basket.take(1).bind {[weak self] (basket) in
            guard let wSelf = self else { return }
            
            guard let product = basket.keys.first(where: { (d) -> Bool in
                return d.productId == productId
            }) else { return }
            
            
            let value = basket[product]
            
            wSelf.router?.routeToProductMenu(product: product, basketItem: value)
            
        }.disposeOnDeactivate(interactor: self)
    }
    
    func routeToFoodDetail() {
        self.listener?.routeToFoodDetail()
    }
}

// MARK: Apply Promotion
extension CheckOutInteractor {
    private func applyVoucher(v: String?) {
        apply(p: nil, v: v)
    }
    
    private func apply(p: EcomPromotion?, v: String?) {
        self.createQuoteCard { (original) -> JSON in
            var n = original
            if let promotion = p, let id = promotion.ruleId {
                if !promotion.isVatoPromotion {
                    n["appliedRuleIds"] = [id]
                    n["appliedVatoRuleIds"] = nil
                } else {
                    n["appliedVatoRuleIds"] = id
                    n["appliedRuleIds"] = []
                }
            } else {
                n["appliedRuleIds"] = []
                n["appliedVatoRuleIds"] = nil
            }
            
            if let v = v {
                var child = JSON()
                child["code"] = v
                child["value"] = 0
                n["coupons"] = [child]
            } else {
                n["coupons"] = []
            }
            return n
        }
    }
    
    func applyPromotion(item: EcomPromotion?) {
        self.voucher = nil
        apply(p: item, v: nil)
    }
    
    func removePromotionItem() {
        applyPromotion(item: nil)
    }
}

// MARK: CheckOutPresentableListener's members
extension CheckOutInteractor: CheckOutPresentableListener {
    func routeToPromotionStore() {
        guard promotionItem == nil else {
            return presenter.showDetailPromotion(promotionItem: promotionItem, removed: true)
        }
        
        mutableStoreStream.currentStoreId.filterNil().take(1).bind(onNext: weakify({ (id, wSelf) in
            wSelf.router?.routeToPromotionStore(storeID: id)
        })).disposeOnDeactivate(interactor: self)
    }
    
    
    var store: Observable<FoodExploreItem?> {
        return mutableStoreStream.store.observeOn(MainScheduler.asyncInstance)
    }

    
    var basket: Observable<BasketModel> {
        return mutableStoreStream.basket.observeOn(MainScheduler.asyncInstance)
    }
    
    var quoteCart: Observable<QuoteCart?> {
        return mutableStoreStream.quoteCart.observeOn(MainScheduler.asyncInstance)
    }
    
    var timeDelivery: Observable<DateTime?> {
        return mutableStoreStream.timeDelivery
    }
    
    var receiver: Observable<DestinationDisplayProtocol> {
        return mReceiver.map { $0 as DestinationDisplayProtocol}.observeOn(MainScheduler.asyncInstance).asObservable()
    }
    
    var errorObserable: Observable<MerchantState> {
        return $errorSubject
    }
    
    // payment method
    var eMethod: Observable<PaymentCardDetail> {
        return mutableStoreStream.paymentMethod
    }
    
    func routeToTopup() {
        presenter.cleanUpWindows(completion: weakify({ (wSelf) in
            wSelf.router?.routeToTopup()
        }))
        
    }
    
    func dismissCheckOut() {
        self.listener?.dismissCheckOut()
    }
    
    func routeToLocationPicker() {
        
        let location = UserManager.instance.currentLocation ?? kCLLocationCoordinate2DInvalid
        let address = Address(
            placeId: nil,
            coordinate: location,
            name:  "",
            thoroughfare: "",
            locality: "",
            subLocality: "",
            administrativeArea: "",
            postalCode: "",
            country: "",
            lines: [],
            zoneId: 0,
            isOrigin: false,
            counter: 0,
            distance: nil,
            favoritePlaceID: 0)
        self.router?.routeToLocationPicker(placeModel: address, searchType: .express(origin: false, fillInfo: false), typeLocationPicker: .full)
    }
    
    private func validatePayment() -> Observable<Bool> {
        if self.orderId != nil {
            return Observable.just(true)
        }
        let card = mutableStoreStream.paymentMethod.take(1)
        let quoteCart = mutableStoreStream.quoteCart.filterNil().take(1)
        let event = Observable.combineLatest(card, quoteCart) { (card, q) -> (card: PaymentCardDetail, price: Double) in
            return (card, q.grandTotal ?? 0)
        }
        return event.flatMap { [weak self](v) -> Observable<Bool> in
            guard let wSelf = self else { return Observable.empty() }
            if v.card.type == .vatoPay {
                return wSelf.mProfileStream.user.take(1).map { (u) -> Bool in
                    let t = u.cash + u.coin
                    return t >= v.price
                }
            } else {
                return Observable.just(true)
            }
        }
    }
    
    // picker time
    func routeToChooseTime() {
        mutableStoreStream
            .timeDelivery
            .take(1)
            .bind { [weak self] (time) in
                self?.router?.routeToChooseTime(model: time)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func deleteQuoute(id: String) -> Observable<Void> {
        let url = VatoFoodApi.host + "/ecom/quote?quoteId=\(id)"
        let router = VatoAPIRouter.customPath(authToken: "", path: url , header: nil , params: nil, useFullPath: true)
                
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        let event = network
            .request(using: router, decodeTo: OptionalIgnoreMessageDTO<String>.self, method: .delete)
            .trackProgressActivity(indicator)
        return event.map { _ in }.catchErrorJustReturn(())
    }
    
    func clearBasket() {
        let completedClearBasket = { [weak self] in
            guard let wSelf = self else { return }
            wSelf.mutableStoreStream.reset()
//            wSelf.mutableStoreStream.update(bookingState: .NEW)
            wSelf.listener?.routeToFoodDetail()
        }
        
        self.mutableStoreStream.quoteCart.take(1).flatMap { [weak self] (quote) -> Observable<Void> in
            if let q = quote, let id = q.id {
                guard let wSelf = self else { return Observable.empty() }
                return wSelf.deleteQuoute(id: id)
            } else {
                return Observable.just(())
            }
        }.bind(onNext: completedClearBasket).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension CheckOutInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        mProfileStream.user.bind(onNext: weakify({ (user, wSelf) in
            wSelf.userId = user.id
        })).disposeOnDeactivate(interactor: self)
        
        mutableStoreStream.note.bind { [weak self] (n) in
            self?.presenter.update(from: BookingConfirmUpdateType.note(string: n.note ?? ""))
        }.disposeOnDeactivate(interactor: self)
        
        eMethod.subscribe(onNext: { [weak self] card in
            self?.mutablePaymentStream.update(select: card)
            self?.presenter.update(from: BookingConfirmUpdateType.updateMethod(method: card))
        }).disposeOnDeactivate(interactor: self)
        
        self.mutableStoreStream.address.observeOn(MainScheduler.asyncInstance).bind {[weak self] (model) in
            guard let wSelf = self else { return }
            wSelf.infoReceiver.originalDestination = model
            wSelf.mReceiver.onNext(wSelf.infoReceiver)
            
        }.disposeOnDeactivate(interactor: self)
        
        let e1 = mutableStoreStream.quoteCart.filterNil()
        let e2 = $mItemsPromotion.filterNil().take(1)
        
        Observable.combineLatest(e1, e2, resultSelector: { return ($0, $1) }).bind(onNext: weakify({ (i, wSelf) in
            guard let str = i.0.appliedRuleIds ?? i.0.appliedVatoRuleIds, let ruleId = Int(str) else {
                wSelf.promotionItem = nil
                return
            }
            wSelf.promotionItem = i.1.first(where: { $0.promotion.ruleId == ruleId })?.promotion
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Pay by Ewallet
extension CheckOutInteractor {
    private func paymentEWallet(method: String,
                        amount: Int,
                        fee: Int,
                        editParams: ((NSMutableDictionary) -> NSMutableDictionary)?) -> Observable<(JSON, Bool)> {
        return Observable.create { [weak self](s) -> Disposable in
            let controller = UIApplication.topViewController(controller: self?.router?.viewControllable.uiviewController)
            #if DEBUG
               assert(controller != nil, "Check!!!!")
            #endif
            let topUpAction = TopUpAction(with: method, amount: amount, controller: controller, topUpItem: nil)
            topUpAction.topUpEditParams = editParams
            topUpAction.topUpHandlerResult = { (params, check) in
                var params = params
                params["appid"] = TopUpAction.Configs.appId
                s.onNext((params, check))
                s.onCompleted()
            }
            
            topUpAction.topUpBlockRequestZaloPayToken = self?.requestZaloPayToken
            self?.topUpAction = topUpAction
            topUpAction.eAction.onNext(.next)
            return Disposables.create {
                self?.topUpAction = nil
            }
        }
    }
}

// MARK: -- Handler Action
extension CheckOutInteractor {
    func move(to type: BookingConfirmType) {
        switch type {
        case .note:
            mutableStoreStream
                .note
                .take(1)
                .timeout(DispatchTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
                .catchErrorJustReturn(NoteDeliveryModel(note: "", option: ""))
                .bind { [weak self] (note) in
                    var noteTextConfig = NoteTextConfig()
                    noteTextConfig.titleText = Text.note.localizedText
                    noteTextConfig.notePlaceholder = Text.inputNote.localizedText
                    noteTextConfig.confirmButton = Text.confirm.localizedText
                    self?.router?.routeToNote(note: note, noteTextConfig: noteTextConfig)
            }.disposeOnDeactivate(interactor: self)
        case .wallet:
            router?.routeToPaymentMethod()
            break
        case .booking:
            validatePayment().bind(onNext: weakify({ (r, wSelf) in
                if r {
                    wSelf.createOrder()
                } else {
                    wSelf.presenter.showAlertTopUp()
                }
            })).disposeOnDeactivate(interactor: self)
            
        case .detailPrice:
            self.router?.routeToDetailPrice()
        case .coupon:
            self.routeToPromotionStore()
        default:
            break
        }
    }
}

// MARK: -- QuoteCard
private extension CheckOutInteractor {
    func createQuoteCard(params modify: ((JSON) -> JSON)? = nil) {
        self.currentOrder = nil
        guard let customerId = UserManager.instance.info?.id else {
            return
        }
        self.mutableStoreStream.createParams(customerId: customerId).observeOn(MainScheduler.asyncInstance).bind {[weak self] (params) in
            guard let wSelf = self, let p = params else { return }
            var n = p.params
            if let modify = modify {
                n = modify(n)
            }
            wSelf.requestCreateCard(params: n, method: p.method)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func requestCreateCard(params: JSON, method: HTTPMethod) {
        disposeCreateQuoteCard?.dispose()
        disposeCreateQuoteCard = self.request { key -> Observable<(HTTPURLResponse, OptionalMessageDTO<QuoteCart>)>  in
            return Requester.requestDTO(using: VatoFoodApi.createQuoteCart(authToken: key, params: params),
                                        method: method,
                                        encoding: JSONEncoding.default)
        }.trackProgressActivity(indicator)
        .retryOnBecomesReachable(defaultReachabilityService)
        .subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                if res.1.fail == true {
                    guard let message = res.1.message else { return }
                    let errType = MerchantState.generalError(status: res.1.status,
                                                             message: message)
                    wSelf.errorSubject = errType
                    
                } else {
                    if let data = res.1.data {
                        wSelf.mutableStoreStream.update(quoteCard: data)
                    } else {
                        guard let message = res.1.message else { return }
                        let errType = MerchantState.generalError(status: res.1.status,
                                                                 message: message)
                        wSelf.errorSubject =  errType
                    }
                    
                }
            case .error(let e):
                print(e.localizedDescription)
                wSelf.errorSubject =  .errorSystem(err: e)
            default:
                break
            }
        }))
    }
    
    func removeQuoteCard() {
        currentOrder = nil
        self.mutableStoreStream.update(quoteCard: nil)
    }
    
    func resetQuoteCardIfNeeded() {
        self.removeQuoteCard()
        self.createQuoteCard()
    }
}

// MARK: -- Order
extension CheckOutInteractor {
    func changeInfoOrder() {
        guard self.orderId != nil else {
            presenter.cleanUpWindows(completion: nil)
            return
        }
        
        presenter.alertNotifyRemoveOrder(cancel: {}, ok: weakify({ (wSelf) in
            wSelf.orderId = nil
            wSelf.resetQuoteCardIfNeeded()
            wSelf.presenter.cleanUpWindows(completion: nil)
        }))
    }
    
    private func createOrder() {
        if let currentOrder = currentOrder {
            updateOrder(for: currentOrder)
            return
        }
        
        let quoteCartObserver = self.mutableStoreStream.quoteCart.take(1)
        let noteObserver = self.mutableStoreStream.note.take(1)
        
        Observable.zip(quoteCartObserver, noteObserver).bind {[weak self] (q, n) in
            guard let wSelf = self, let quoteCard = q, let quoteId = quoteCard.id else { return }
            var params: JSON = [:]
            params["customerNote"] = n.note ?? ""
            wSelf.requestCreateOrder(quoteId: quoteId, params: params)
        }.disposeOnDeactivate(interactor: self)
    }
     
    private func requestCreateOrder(quoteId: String, params: JSON) {
        self.request { key -> Observable<(HTTPURLResponse, OptionalMessageDTO<SalesOrder>)>  in
            return Requester.requestDTO(using: VatoFoodApi.createSaleOrder(authToken: key, quoteId: quoteId, params: params),
                                        method: .post,
                                        encoding: JSONEncoding.default)
        }
        .trackProgressActivity(indicator)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                if res.1.fail == true {
                    defer {
                        LogEventHelper.log(key: Config.Tracking.CreateOrderFail, params: ["response": res])
                    }
                    wSelf.resetQuoteCardIfNeeded()
                    guard let message = res.1.message else { return }
                    let errType = MerchantState.generalError(status: res.1.status, message: message)
                    wSelf.errorSubject = errType
                } else {
                    if let order = res.1.data {
                        wSelf.updateOrder(for: order)
                    } else {
                        LogEventHelper.log(key: Config.Tracking.CreateOrderFail, params: ["response": res])
                        guard let message = res.1.message else { return }
                        let errType = MerchantState.generalError(status: res.1.status,
                                                                 message: message)
                        wSelf.errorSubject =  errType
                    }
                }
            case .error(let e):
                defer {
                    LogEventHelper.log(key: Config.Tracking.CreateOrderFail, params: ["response": e.localizedDescription])
                }
                wSelf.resetQuoteCardIfNeeded()
                wSelf.errorSubject = .errorSystem(err: e)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    // MARK: -- Update
    private func cleanUpAndTracking(order: SalesOrder) {
        presenter.cleanUpWindows { [weak self] in
            guard let wSelf = self else {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
            wSelf.router?.routeToStoreTracking(order: order)
        }
    }
    
    private func updateOrder(for order: SalesOrder) {
        removeQuoteCard()
        currentOrder = order
        orderId = order.id
        disposeWallet?.dispose()
        
        let routeToTracking: (SalesOrder) -> () = { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.cleanUpAndTracking(order: $0)
        }
        
        let handlerError: (String?, Int) -> () = { [weak self] m, status in
            guard let wSelf = self, let m = m else {
                return
            }
            defer {
                LogEventHelper.log(key: Config.Tracking.CreateOrderFail, params: ["response": m])
            }
            wSelf.resetQuoteCardIfNeeded()
            let errType = MerchantState.generalError(status: status,
                                                     message: m)
            wSelf.errorSubject =  errType
        }
        
        guard let card = self.mutablePaymentStream.currentSelect else {
            return
        }
        
        let type = card.type
        if type > PaymentCardType.vatoPay {
            switch type {
            case .master, .visa:
                let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "ios_client_app"
                var params: JSON = JSON()
                params["cardScheme"] = "CreditCard"
                params["deviceId"] = uuid
                params["orderId"] = order.id
                params["environment"] = "MobileApp"
                params["tokenId"] = card.id
                
                let p = Config.url("/ecom/sale-order/payment-credit-card-with-token")
                let router = VatoAPIRouter.customPath(authToken: "", path: p , header: nil , params: params, useFullPath: true)
                let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
                network.request(using: router,
                                decodeTo: OptionalMessageDTO<SalesOrder>.self,
                                method: .put,
                                encoding: JSONEncoding.default)
                    .trackProgressActivity(indicator)
                    .bind { (result) in
                        switch result {
                        case .success(let r):
                            if r.fail {
                                handlerError(r.message, r.status)
                            } else {
                                guard let new = r.data else { return }
                                routeToTracking(new)
                            }
                        case .failure(let e):
                            handlerError(e.localizedDescription, 0)
                        }

                }.disposeOnDeactivate(interactor: self)
            case .momo, .zaloPay:
                guard let nameEwallet = card.methodEwallet else {
                    fatalError("Please Implement!!!")
                }
                let amount = order.grandTotal.orNil(0)
                disposeWallet = self.paymentEWallet(method: nameEwallet, amount: amount, fee: 0) { (p) -> NSMutableDictionary in
                    let news = p
                    switch type {
                    case .momo:
                        news["description"] = "Thanh toán đơn hàng VATO"
                        news["merchantnamelabel"] = "Thanh toán đơn hàng"
                    default:
                        break
                    }
                    return news
                }.flatMap { [weak self](result) -> Observable<SalesOrder> in
                    guard let wSelf = self else {
                        return Observable.empty()
                    }
                    return wSelf.checkResultPayEWallet(item: result.0, method: type, order: order)
                }
                .subscribe(weakify({ (event, wSelf) in
                    switch event {
                    case .next(let new):
                        routeToTracking(new)
                    case .error(let e):
                        handlerError(e.localizedDescription, 0)
                    default:
                        break
                    }
                }))
            default:
                break
            }
        } else {
            routeToTracking(order)
        }
    }
}

// MARK: -- Wallet Flow Payment
extension CheckOutInteractor {
    struct MoMoEcomResponse: Codable {
        var salesOrder: SalesOrder?
        var msg: String?
        var pay: Bool
    }
    
    struct ZaloPayEcomResponse: Codable {
        var zptranstoken: String?
    }
    
    private func BASE_REQUEST<E: Codable>(router: APIRequestProtocol,
                                          decodeTo: E.Type,
                                          method: HTTPMethod,
                                          encoding: ParameterEncoding) -> Observable<E>
    {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router,
                        decodeTo: OptionalMessageDTO<E>.self,
                        method: method,
                        encoding: encoding).map { (result) -> E? in
                            switch result {
                            case .success(let r):
                                if r.fail {
                                    throw NSError(use: r.message)
                                } else {
                                    return r.data
                                }
                            case .failure(let e):
                                throw e
                            }
        }.filterNil()
    }
    
    private func REQUEST<E: Codable>(path: String,
                                     decodeTo: E.Type,
                                     params: JSON,
                                     method: HTTPMethod,
                                     encoding: ParameterEncoding) -> Observable<E>
    {
        let host = VatoFoodApi.host
        let p = host + path
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: params, useFullPath: true)
        return BASE_REQUEST(router: router, decodeTo: decodeTo, method: method, encoding: encoding)
    }
    
    private func cancelOrder(id: String) {
        let param: JSON = ["idOrder":id]
        let router = VatoFoodApi.cancelOrder(authToken: "", id: id, params: param)
        BASE_REQUEST(router: router, decodeTo: SalesOrder.self, method: .put, encoding: JSONEncoding.default).bind { (result) in
            #if DEBUG
               print(result)
            #endif
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func requestPayMomo(params: JSON) -> Observable<MoMoEcomResponse> {
        var params = params
        params["userId"] = self.userId
        return REQUEST(path: "/ecom/sale-order/payment-momo",
                decodeTo: MoMoEcomResponse.self,
                params: params,
                method: .put,
                encoding: JSONEncoding.default).map { (res) -> MoMoEcomResponse in
                    if !res.pay {
                        throw NSError(use: res.msg)
                    }
                    return res
        }
    }
    
    private func requestConfirmMomo(response: MoMoEcomResponse,
                                    item: JSON,
                                    order: SalesOrder) -> Observable<SalesOrder>
    {
        var params = JSON()
        params["appData"] = item["appData"]
        params["referId"] = order.id
        params["success"] = response.pay
        params["userId"] = self.userId
        
        return REQUEST(path: "/ecom/sale-order/payment-momo/confirm",
                decodeTo: SalesOrder.self,
                params: params,
                method: .put,
                encoding: JSONEncoding.default)
    }
    
    internal func requestZaloPayToken() -> Observable<String> {
        var params = JSON()
        params["appid"] = TopUpAction.Configs.appId
        params["orderId"] = orderId
        
        return REQUEST(path: "/ecom/sale-order/payment-zalo",
                decodeTo: ZaloPayEcomResponse.self,
                params: params,
                method: .put,
                encoding: JSONEncoding.default)
            .map { $0.zptranstoken }
            .filterNil()
    }
    
    private func requestOrder() -> Observable<SalesOrder> {
        guard let id = self.orderId else { return Observable.empty() }
        let router = VatoFoodApi.getOrder(authToken: "", id: id, params: nil)
        return BASE_REQUEST(router: router, decodeTo: SalesOrder.self, method: .get, encoding: URLEncoding.default)
    }
    
    private func reCheckSaleOrder(old: SalesOrder, idx: Int) -> Observable<SalesOrder> {
        guard idx <= 3 else {
            return Observable.just(old)
        }
        let time = 5 * (idx + 1)
        let e = Observable<Int>.interval(.seconds(time), scheduler: MainScheduler.asyncInstance).take(1).flatMap { [weak self](_) -> Observable<SalesOrder> in
            guard let wSelf = self else {
                return Observable.empty()
            }
            return wSelf.requestOrder()
        }.flatMap { [weak self](order) -> Observable<SalesOrder> in
            guard let wSelf = self else {
                return Observable.empty()
            }
            
            if order.payment == true {
                return Observable.just(order)
            } else {
                return wSelf.reCheckSaleOrder(old: order, idx: idx + 1)
            }
        }
        
        return e
    }
    
    // MARK: -- Check result from eWallet
    private func checkResultPayEWallet(item: JSON, method: PaymentCardType, order: SalesOrder) -> Observable<SalesOrder> {
        assert(method == .momo || method == .zaloPay, "Please check!!!!")
        let showProgrgress = {
            LoadingManager.showProgress(duration: 120)
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        
        let endProgrgress = {
            LoadingManager.dismissProgress()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
        showProgrgress()
        switch method {
        case .momo:
            var params = item
            params["orderId"] = order.id
            return requestPayMomo(params: params)
                .retry(2)
                .map { $0.salesOrder }
                .filterNil()
                .do(onDispose: endProgrgress)
        case .zaloPay:
            return reCheckSaleOrder(old: order, idx: 0).do(onDispose: endProgrgress)
        default:
            fatalError("Please Implement!!!")
        }
    }
}

// MARK: -- Wallet
extension CheckOutInteractor {
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

