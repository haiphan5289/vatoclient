//  File name   : FoodMainInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import RxCocoa
import FwiCoreRX
import FwiCore
import KeyPathKit
import Alamofire

enum ListCategoryRequestType {
    case parent(category: CategoryRequestProtocol)
    case child(category: CategoryRequestProtocol)
}

protocol FoodMainRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToDetail(item: FoodExploreItem)
    func routeToSearch(type: ServiceCategoryType)
    func routeToList(type: FoodListType)
    func routeToSearchLocation(address: AddressProtocol?)
    func routeToListCategory(detail: CategoryRequestProtocol)
    func routeToListParent(items: [FoodCategoryItem])
    func routeToFoodTracking(salesOder: SalesOrder)
    func roueToEcomReceipt(salesOder: SalesOrder)
    
    func routeToCheckOut()
    func routeShowAlertCancel(title: String?, body: String?, completion: @escaping AlertBlock)
    func validDismissAllAlert() -> Bool
}

protocol FoodMainPresentable: Presentable, HandlerProtocol {
    var listener: FoodMainPresentableListener? { get set }
    func historyDismiss(completion: (() ->())?)
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showConfirmRemoveBasketAlert(cancelHandler: @escaping AlertBlock, confirmHandler: @escaping AlertBlock)
}

protocol FoodMainListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func foodMoveBack()
}

final class FoodMainInteractor: PresentableInteractor<FoodMainPresentable>, ManageListenerProtocol {
    var listenerManager: [Disposable] = []
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    
    struct Configs {
        static let numberItemsDiscovery = 10
        static let pageMin = 0
    }
    
    /// Class's public properties.
    weak var router: FoodMainRouting?
    weak var listener: FoodMainListener?
    internal var isLoading: Bool = false
    internal var disposeRequest: Disposable?
    private lazy var trackProgress = ActivityProgressIndicator()
    let type: ServiceCategoryType
    @Replay(queue: MainScheduler.asyncInstance) private var action: ServiceCategoryAction?
    
    /// Class's constructor.
    init(presenter: FoodMainPresentable, authenticated: AuthenticatedStream, mutableBooking: MutableBookingStream, type: ServiceCategoryType, mutableStoreStream: MutableStoreStream, action: ServiceCategoryAction?) {
        self.type = type
        self.mutableStoreStream = mutableStoreStream
        self.mutableBooking = mutableBooking
        self.authenticated = authenticated
        super.init(presenter: presenter)
        self.action = action
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        request()
        listenPushEcom()
        listenDeepLink()
        // todo: Implement business logic here.
    }
    
    func request() {
        requestBanners()
        requestCategories()
        requestFamiliarShops()
        requestNews()
//        requestNearest()
        requestDiscovery()
        requestWhatsToday()
        requestHighCommission()
        requestBookingTimeDelay()
        requestFreeShip()
        requestOldQuoteCart()
    }
    
    override func willResignActive() {
        super.willResignActive()
        cleanUpListener()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    internal let authenticated: AuthenticatedStream
    private let mutableBooking: MutableBookingStream
    internal var originalCoordinate: Observable<AddressProtocol> {
        return mutableBooking.booking.map { $0.originAddress }
    }
    
    @Replay(queue: MainScheduler.asyncInstance) internal var mBanners: [FoodBannerItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mCategories: [FoodCategoryItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mNews: [FoodExploreItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mWhatsTodays: [FoodExploreItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mHighCommissons: [FoodExploreItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mNearest: [FoodExploreItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mShopFamilarShops: [FoodExploreItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mFreeShipShops: [FoodExploreItem]
    @Replay(queue: MainScheduler.asyncInstance) internal var mDiscovery: ListUpdate<FoodExploreItem>
    @Replay(queue: MainScheduler.asyncInstance) internal var mOriginAddress: AddressProtocol?
    @Replay(queue: MainScheduler.asyncInstance) internal var mNumberProcessing: Int
    @Published private var errorSubject: MerchantState
    private var diposeRequest: Disposable?
    
    internal lazy var paging = Paging(page: Configs.pageMin - 1, canRequest: true, size: Configs.numberItemsDiscovery)
    let mutableStoreStream: MutableStoreStream
    private var disposeFindNumberProcessing: Disposable?
}

// MARK: FoodMainInteractable's members
extension FoodMainInteractor: FoodMainInteractable, Weakifiable, ActivityTrackingProtocol, LocationRequestProtocol {
    func routeToFoodDetail() {
        router?.dismissCurrentRoute(true, completion: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.getStoreDetail()
        })
    }
    
    private func getStoreDetail() {
        let e1 = self.mutableStoreStream.store.take(1)
        let e2 = self.mutableStoreStream.quoteCart.take(1)
        let e3 = self.mutableStoreStream.currentStoreId.take(1)
        
        Observable.combineLatest(e1, e2, e3).bind {[weak self] (f , q, currentId) in
            guard let wSelf = self else { return }
            Finding: if let f = f , f.id == Int(q?.storeId ?? "") {
                wSelf.routeToStoreDetail(foodExploreItem: f)
                return
            } else {
                guard let id = Int(q?.storeId ?? "") else {
                    break Finding
                }
                wSelf.routeToDetail(item: .store(id: id))
                return
            }
            
            guard let currentId = currentId else {
                return
            }
            wSelf.requestStoreDetailDeepLink(storeId: currentId)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func routeToStoreDetail(foodExploreItem: FoodExploreItem) {
        self.router?.routeToDetail(item: foodExploreItem)
    }
    
    func showReceipt(salesOrder: SalesOrder) {
        router?.roueToEcomReceipt(salesOder: salesOrder)
    }
    
    func dismissCheckOut() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ecomReceiptMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ecomReceiptPreorder(item: SalesOrder) {
        createOrder(item: item)
    }
    
    func dismissStoreTracking() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func trackingRouteToFood() {
        fatalError("Please Implement")
    }
    
    func storeParentListMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: AddressProtocol) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.update(model: model)
        }))
    }
    
    func routeToCheckOut() {
        router?.routeToCheckOut()
    }
    
    private func update(model: AddressProtocol) {
        updateAddress(model: model, update: weakify({ (new, wSelf) in
            wSelf.mutableBooking.updateBooking(originAddress: new)
            wSelf.mOriginAddress = new
            wSelf.refresh()
            wSelf.mutableStoreStream.update(address: new)
        
            wSelf.requestNearest()
        }))
    }
    
    func foodCategoryMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: MapModel.Place) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            let marker = MarkerHistory(with: model)
            wSelf.mutableBooking.updateBooking(originAddress: marker.address)
            wSelf.mOriginAddress = marker.address
            wSelf.refresh()
            wSelf.mutableStoreStream.update(address: marker.address)
            wSelf.requestNearest()
        }))
    }
    
    func dismiss() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func foodListMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToSearchLocation() {
        $mOriginAddress.timeout(.milliseconds(300), scheduler: MainScheduler.instance).take(1).catchErrorJustReturn(nil).bind(onNext: weakify({ (address, wSelf) in
            wSelf.router?.routeToSearchLocation(address: address)
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: FoodMainPresentableListener's members
extension FoodMainInteractor: FoodMainPresentableListener, ActivityTrackingProgressProtocol {
    // MARK: -- Value for presenter
    var selectedType: Observable<HistoryItemType> {
        return Observable.empty()
    }
    
    var error: Observable<MerchantState> {
        return $errorSubject.observeOn(MainScheduler.asyncInstance)
    }
    
    var rootId: Int {
        return type.categoryId
    }
    
    var numberProcessing: Observable<Int> {
        return $mNumberProcessing
    }
    
    var discovery: Observable<ListUpdate<FoodExploreItem>> {
        return $mDiscovery
    }
    
    var banners: Observable<[FoodBannerItem]> {
        return $mBanners
    }
    
    var categories: Observable<[FoodCategoryItem]> {
        return $mCategories
    }
    
    var news: Observable<[FoodExploreItem]> {
        return $mNews
    }
    
    var whatsTodays: Observable<[FoodExploreItem]> {
        return $mWhatsTodays
    }
    
    var nearest: Observable<[FoodExploreItem]> {
        return $mNearest
    }
    
    var familarShops: Observable<[FoodExploreItem]> {
        return $mShopFamilarShops
    }
    
    var freeShipShops: Observable<[FoodExploreItem]> {
        return $mFreeShipShops
    }
    
    var originAddress: Observable<AddressProtocol?> {
        return $mOriginAddress
    }
    
    var trackLoading: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var quoteCart: Observable<QuoteCart?> {
        return mutableStoreStream.quoteCart
    }
    
    var listHighCommission: Observable<[FoodExploreItem]> {
        return $mHighCommissons
    }
    
    // MARK: -- Func Public
    func refresh() {
        self.paging = Paging(page: Configs.pageMin - 1, canRequest: true, size: Configs.numberItemsDiscovery)
        cleanUpListener()
        request()
        requestNumberOrderProcessing()
    }
    
    func foodSearchMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func foodMoveBack() {
        listener?.foodMoveBack()
    }
    
    func routeToRootCategory() {
        $mCategories.take(1).bind(onNext: weakify({ (list, wSelf) in
            wSelf.router?.routeToListParent(items: list)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func routeToDetail(item: FoodDetailType) {
        switch item {
        case .item(let store):
            router?.routeToDetail(item: store)
        case .store(let id):
            request(map: { Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodExploreItem>.self, using: VatoFoodApi.storeDetail(authToken: $0, storeId: id)) })
                .observeOn(MainScheduler.asyncInstance)
                .trackProgressActivity(trackProgress)
                .subscribe(weakify({ (event, wSelf) in
                    switch event {
                    case .next(let res):
                        if let e = res.response.error {
                            assert(false, e.localizedDescription)
                        } else {
                            guard let item = res.response.data else {
                                return
                            }
                            wSelf.router?.routeToDetail(item: item)
                        }
                    case .error(let e):
                        assert(false, e.localizedDescription)
                    default:
                        break
                    }
                })).disposeOnDeactivate(interactor: self)
        case .category(let id):
            request(map: { Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodCategoryResponse>.self, using: VatoFoodApi.listCategory(authToken: $0, categoryId: id > 0 ? id : nil, params: nil)) })
                .observeOn(MainScheduler.asyncInstance)
                .trackProgressActivity(trackProgress)
                .subscribe(weakify({ (event, wSelf) in
                    switch event {
                    case .next(let res):
                        guard let data = res.response.data else {
                            return
                        }
                        if data.hasChildren {
                            wSelf.routeToListCategory(detail: data)
                        } else {
                            wSelf.routeToList(type: .category(model: data))
                        }
                    case .error(let e):
                        assert(false, e.localizedDescription)
                    default:
                        break
                    }
                })).disposeOnDeactivate(interactor: self)
        }
    }
    
    func detailFoodMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToSearch() {
        router?.routeToSearch(type: type)
    }
    
    func routeToList(type: FoodListType) {
        router?.routeToList(type: type)
    }
    
    func routeToListCategory(detail: CategoryRequestProtocol) {
        router?.routeToListCategory(detail: detail)
    }
    
    func requestBookingTimeDelay() {
        let url = VatoFoodApi.host + "/ecom/sale-order/time-delay"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<TimeInterval>.self, method: .get).observeOn(MainScheduler.instance)
            .bind { [weak self] (result) in
                guard let me = self else { return }
                switch result {
                case .success(let s):
                    me.mutableStoreStream.updateBookingTimeInterval(bookingTimeInterval: s.data.orNil(600000) / 1000)
                    break
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    struct FoodOrderProcessing: Codable {
        let processing: Int
    }
    
    func requestNumberOrderProcessing() {
        disposeFindNumberProcessing?.dispose()
        let url = VatoFoodApi.host + "/ecom/sale-order/process/count"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        disposeFindNumberProcessing = network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<FoodOrderProcessing>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                guard let n = r.data?.processing else {
                    wSelf.mNumberProcessing = 0
                    return
                }
                wSelf.mNumberProcessing = n
            case .failure(let e):
                #if DEBUG
                   print(e.localizedDescription)
                #endif
                wSelf.mNumberProcessing = 0
            }
        }))
    }
}

extension FoodMainInteractor {
    func report(tripCode: String, service: String) {}
    
    func historyDismiss() {
        presenter.historyDismiss(completion: nil)
    }
    
    func historyMoveHome() {
        presenter.historyDismiss(completion: nil)
    }
    
    
    func history(hiddenBottomLine: Bool) {
        //        presenter.history(hiddenBottomLine: hiddenBottomLine)
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
        return Requester.responseDTO(decodeTo: decodeTo, using: router, block: block).map { $0.response }
    }
    
    func alertConfirmCreateOrder(item: SalesOrder) {
        presenter.showConfirmRemoveBasketAlert(cancelHandler: {}, confirmHandler: weakify({ (wSelf) in
            wSelf.createOrder(item: item)
        }))
    }
    
    func handlerPreOrder(item: SalesOrder) {
        mutableStoreStream.currentStoreId.take(1).bind(onNext: weakify({ (id, wSelf) in
            guard id == nil else { return wSelf.alertConfirmCreateOrder(item: item)}
            wSelf.createOrder(item: item)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func detail(item: HistoryDetailItemType) {
        presenter.historyDismiss(completion: weakify({ (wSelf) in
            switch item {
            case .food(let salesOder):
                wSelf.router?.routeToFoodTracking(salesOder: salesOder)
            case .preorder(let order):
                wSelf.handlerPreOrder(item: order)
            default:
                break
            }
        }))
    }
    
    internal func requestStoreDetailDeepLink(storeId: Int) {
        let p = VatoFoodApi.host + "/ecom/store/\(storeId)/deep-link"
        
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        
        network.request(using: router, decodeTo: OptionalMessageDTO<FoodExploreItem>.self, method: .get).trackProgressActivity(indicator)
            .observeOn(MainScheduler.asyncInstance)
            .bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                if r.error != nil {
                    let e = NSError(use: r.message)
                    let errType = MerchantState.generalError(status: -404,
                    message: e.localizedDescription)
                    wSelf.errorSubject = errType
                    return
                }
                
                if let data = r.data {
                    wSelf.routeToDetail(item: .item(store: data))
                }
            case .failure(let e):
                let code = (e as NSError).code
                let errType = MerchantState.generalError(status: code,
                                                         message: e.localizedDescription)
                wSelf.errorSubject = errType
            }
            
            
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension FoodMainInteractor {
    private func setupRX() {
        // todo: Bind data stream here.s
        self.indicator.asObservable().bind(onNext: weakify({ (loading, wSelf) in
            wSelf.isLoading = loading
        })).disposeOnDeactivate(interactor: self)
        
        self.$action.filterNil().bind(onNext: weakify({ (type, wSelf) in
            switch type {
            case .storeId(let id):
                wSelf.requestStoreDetailDeepLink(storeId: id)
            }
        })).disposeOnDeactivate(interactor: self)
        
        self.originAddress.filterNil().bind(onNext: weakify({ (address, wSelf) in
            UserManager.instance.currentLocation = address.coordinate
        })).disposeOnDeactivate(interactor: self)
        
        self.originalCoordinate.take(1).timeout(.seconds(2), scheduler: MainScheduler.instance).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let a):
                wSelf.mutableStoreStream.update(address: a)
                wSelf.mOriginAddress = a
            case .error(let e):
                print(e.localizedDescription)
                wSelf.mOriginAddress = nil
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
        
        self.mutableStoreStream.storeBookingState.observeOn(MainScheduler.asyncInstance).bind { [weak self ](state) in
            guard let me = self else { return }
            switch state {
            case .NEW:
                me.router?.dismissCurrentRoute(completion: nil)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
        
    }
}

// MARK: -- Create order
private extension FoodMainInteractor {
    func handlerPush(from action: ManifestAction, info: JSON) {
        guard action == .ecom else {
            return
        }
        let t = info.value("saleOrderState", defaultValue: "-1")
        guard let v = Int(t), let type = StoreOrderState(rawValue: v) else {
            return
        }
        
        if type == .CANCELED {
            let aps: JSON? = info.value("aps", defaultValue: nil)
            let alert: JSON? = aps?.value("alert", defaultValue: nil)
            let title = alert?.value("title", defaultValue: "")
            let body = alert?.value("body", defaultValue: "")
            self.mutableStoreStream.update(showingAlert: true)
            router?.routeShowAlertCancel(title: title, body: body, completion: weakify({ (wSelf) in
                guard wSelf.router?.validDismissAllAlert() == true else { return }
                wSelf.mutableStoreStream.update(stateOrder: type)
                wSelf.mutableStoreStream.update(showingAlert: false)
            }))
        } else {
            mutableStoreStream.update(stateOrder: type)
        }
    }
    
    func listenPushEcom() {
        NotificationPushService.instance.new.observeOn(MainScheduler.asyncInstance).bind { [weak self](push) in
            guard let wSelf = self else { return }
            defer {
                wSelf.resetPush()
            }
            let value: String = push.value("type", defaultValue: "-1")
            
            guard let type = Int(value),
                let action = ManifestAction(rawValue: type)
                else {
                    return
            }
            wSelf.handlerPush(from: action, info: push)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func resetPush() {
        NotificationPushService.instance.reset()
    }
    
    func createOrder(item: SalesOrder) {
        mutableStoreStream.reset()
        var basket = BasketModel()
        item.orderItems?.forEach({ (order) in
            guard let i = DisplayProduct(order: order) else {
                return
            }
            let v = BasketProductIem.init(note: order.description, quantity: order.qty ?? 0)
            basket[i] = v
        })
        mutableStoreStream.update(basket: basket)
        mutableStoreStream.update(time: nil)
        let paymentMethod: PaymentCardDetail
        if let idx = item.salesOrderPayments?.first?.paymentMethod {
            switch idx {
            case 0:
                paymentMethod = .cash()
            case 1:
                paymentMethod = .vatoPay()
            case 6:
                paymentMethod = .momo()
            case 7:
                paymentMethod = .zaloPay()
            default:
                #if DEBUG
                    print("Check method \(idx) !!!")
                    paymentMethod = .cash()
                #else
                    paymentMethod = .cash()
                #endif
            }
        } else {
            paymentMethod = .cash()
        }
        
        mutableStoreStream.update(paymentCard: paymentMethod)
        guard let address = item.salesOrderAddress?.first else { return }
        let new = Address(coordinate: address.coordinate, thoroughfare: "", locality: "", subLocality: address.address ?? "", administrativeArea: "", postalCode: "", country: "Việt Nam", lines: [], favoritePlaceID: 0)
        mutableStoreStream.update(address: new)
        let store = HistoryStoreIdentify(id: Int(item.storeId ?? ""))
        mutableStoreStream.updateStore(identify: store)
        createQuoteCard(paymentMethod: paymentMethod)
    }
    
    private func createQuoteCard(paymentMethod: PaymentCardDetail) {
        guard let customerId = UserManager.instance.info?.id else {
            return
        }
        self.mutableStoreStream.update(paymentCard: paymentMethod)
        self.mutableStoreStream.createParams(customerId: customerId)
            .observeOn(MainScheduler.asyncInstance)
            .bind {[weak self] (params) in
                guard let wSelf = self, let p = params else { return }
                wSelf.requestCreateCard(params: p.params, method: p.method)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func requestCreateCard(params: JSON, method: HTTPMethod) {
        diposeRequest?.dispose()
        let router = VatoFoodApi.createQuoteCart(authToken: "", params: params)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        diposeRequest = network
            .request(using: router, decodeTo: OptionalMessageDTO<QuoteCart>.self, method: method, encoding: JSONEncoding.default)
            .trackProgressActivity(indicator)
            .bind(onNext: weakify({ (result, wSelf) in
                switch result {
                case .success(let res):
                    if res.fail {
                        guard let message = res.message else { return }
                        let errType = MerchantState.generalError(status: res.status,
                                                                 message: message)
                        wSelf.errorSubject = errType
                        wSelf.router?.dismissCurrentRoute(true, completion: nil)
                        
                    } else {
                        if let data = res.data {
                            wSelf.mutableStoreStream.update(quoteCard: data)
                            wSelf.router?.routeToCheckOut()
                        } else {
                            guard let message = res.message else { return }
                            let errType = MerchantState.generalError(status: res.status,
                                                                     message: message)
                            wSelf.errorSubject = errType
                            wSelf.router?.dismissCurrentRoute(true, completion: nil)
                        }
                    }
                case .failure(let e):
                    let code = (e as NSError).code
                    let errType = MerchantState.generalError(status: code,
                                                             message: e.localizedDescription)
                    wSelf.errorSubject = errType
                    wSelf.router?.dismissCurrentRoute(true, completion: nil)
                }
            }))
    }
}
