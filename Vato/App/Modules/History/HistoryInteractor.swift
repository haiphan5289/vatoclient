//  File name   : HistoryInteractor.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FirebaseFirestore
import Alamofire

struct HistoryStoreIdentify: StoreIdentifyProtocol {
    let id: Int?
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
}

protocol HistoryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToDetail()
    func loadTrip(info: [String : Any])
    func routeToFoodTracking(salesOder: SalesOrder)
    func routeToQuickSupport(requestModel: QuickSupportRequest, defaultContent: String?)
    func routeToCheckOut()
    func routeToDetail(item: FoodExploreItem)
    func routeToEcomReceipt(salesOder: SalesOrder)
}

protocol HistoryPresentable: Presentable {
    var listener: HistoryPresentableListener? { get set }
    func history(hiddenBottomLine: Bool)
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol HistoryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func routeToFood()
    func historyDismiss()
    func historyMoveHome()
    func inTripNewBook()
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?)
}

final class HistoryInteractor: PresentableInteractor<HistoryPresentable> {
    /// Class's public properties.
    weak var router: HistoryRouting?
    weak var listener: HistoryListener?

    /// Class's constructor.
    init(presenter: HistoryPresentable,
         authenticated: AuthenticatedStream,
         mutableStoreStream: MutableStoreStream,
         selected: HistoryItemType?)
    {
        self.mutableStoreStream = mutableStoreStream
        self.authenticated = authenticated
        super.init(presenter: presenter)
        presenter.listener = self
        mSelectType = selected
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
    
    private (set) var authenticated: AuthenticatedStream
    private let mutableStoreStream: MutableStoreStream
    @Published private var errorSubject: MerchantState
    private var diposeRequest: Disposable?
    @Replay(queue: MainScheduler.asyncInstance) private var mSelectType: HistoryItemType?
    /// Class's private properties.
}

// MARK: HistoryInteractable's members
extension HistoryInteractor: HistoryInteractable, Weakifiable {
    func detailFoodMoveBack() {
        self.router?.dismissCurrentRoute(true, completion: nil)
    }
    
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
        
        Observable.combineLatest(e1,e2,e3).bind {[weak self] (f, q, storeId) in
            guard let wSelf = self else { return }
            Finding: if let f = f, f.id == Int(q?.storeId ?? "") {
                wSelf.routeToStoreDetail(foodExploreItem: f)
                return
            } else {
                guard let q = q else {
                   break Finding
                }
                wSelf.requestStoreDetail(quoteCart: q)
                return
            }
            
            guard let id = storeId, q == nil else { return }
            wSelf.requestMoveToDetailMenu(storeId: id)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func requestMoveToDetailMenu(storeId: Int) {
        requestStoreInfo(storeId: storeId).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let r):
                guard let data = r.data, let rootCateId = data.rootCategoryId else {
                    return
                }
                guard let cat = ServiceCategoryType.loadEcom(category: rootCateId) else { return }
                wSelf.listener?.routeToServiceCategory(type: cat, action: .storeId(id: storeId))
            case .error(let e):
                let code = (e as NSError).code
                let errType = MerchantState.generalError(status: code,
                                                         message: e.localizedDescription)
                wSelf.errorSubject = errType
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func routeToStoreDetail(foodExploreItem: FoodExploreItem) {
        self.router?.routeToDetail(item: foodExploreItem)
    }
    
    private func requestStoreInfo(storeId: Int) -> Observable<OptionalMessageDTO<FoodExploreItem>> {
        let router = VatoFoodApi.storeDetail(authToken: "", storeId: storeId)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router,
                        decodeTo: OptionalMessageDTO<FoodExploreItem>.self,
                        method: .get)
            .trackProgressActivity(indicator)
            .map { try $0.get() }
            .observeOn(MainScheduler.asyncInstance)
    }
    
    
    private func requestStoreDetail(quoteCart: QuoteCart?) {
        guard let storeId = Int(quoteCart?.storeId ?? "") else { return }
        requestStoreInfo(storeId: storeId).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let r):
                if let data = r.data {
                    wSelf.mutableStoreStream.update(store: data)
                    wSelf.routeToFoodDetail()
                }
            case .error(let e):
                let code = (e as NSError).code
                let errType = MerchantState.generalError(status: code,
                                                         message: e.localizedDescription)
                wSelf.errorSubject = errType
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func showReceipt(salesOrder: SalesOrder) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.router?.routeToEcomReceipt(salesOder: salesOrder)
        }))
    }
    
    func dismissCheckOut() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ecomReceiptMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
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
    
    func ecomReceiptPreorder(item: SalesOrder) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.createOrder(item: item)
        }))
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
        diposeRequest = network.request(using: router, decodeTo: OptionalMessageDTO<QuoteCart>.self, method: method, encoding: JSONEncoding.default).trackProgressActivity(indicator).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let res):
                if res.fail {
                    guard let message = res.message else { return }
                    let errType = MerchantState.generalError(status: res.status,
                                                             message: message)
                    wSelf.errorSubject = errType

                } else {
                    if let data = res.data {
                        wSelf.mutableStoreStream.update(quoteCard: data)
                        wSelf.router?.routeToCheckOut()
                    } else {
                        guard let message = res.message else { return }
                        let errType = MerchantState.generalError(status: res.status,
                                                                 message: message)
                        wSelf.errorSubject = errType
                    }
                }
            case .failure(let e):
                let code = (e as NSError).code
                let errType = MerchantState.generalError(status: code,
                                                         message: e.localizedDescription)
                wSelf.errorSubject = errType
            }
        }))
    }
    
    func inTripComplete() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func inTripNewBook() {
        listener?.inTripNewBook()
    }
    
    func inTripCancel() {
        let database = Database.database().reference()
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            database.removeClientCurrentTrip(clientFirebaseId: UserManager.instance.info?.firebaseID)
        }))
    }

    func inTripMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func requestSupportMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func dismissStoreTracking() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func historyDetailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func trackingRouteToFood() {
        router?.dismissCurrentRoute(completion: {
            self.listener?.routeToFood()
        })
    }
    
}

// MARK: HistoryPresentableListener's members
extension HistoryInteractor: HistoryPresentableListener, ActivityTrackingProgressProtocol {
    var error: Observable<MerchantState> {
        return $errorSubject.observeOn(MainScheduler.asyncInstance)
    }
    
    var selectedType: Observable<HistoryItemType> {
        return $mSelectType.filterNil()
    }
    
    func report(tripCode: String, service: String) {
        
        #if DEBUG
        let id = "nzUbZg3SAm5NVSMoLI9g"
        #else
        let id = "oICDPTiiEEHh4Wxhbs7v"
        #endif
        
        QuickSupportManager.instance.listQuickSupport.take(1).bind {[weak self] (data) in
            guard let wSelf = self, let model = data.first(where: { $0.id == id }) else { return }
            
            let defaultContent = "Dịch vụ: \(service)\nMã chuyến đi: \(tripCode)\nChi tiết: "
            
            wSelf.router?.routeToQuickSupport(requestModel: model, defaultContent: defaultContent)
        }.disposeOnDeactivate(interactor: self)
        
    }
    
    func historyDismiss() {
        self.listener?.historyDismiss()
    }
    
    func historyMoveHome() {
        self.listener?.historyMoveHome()
    }

    
    func history(hiddenBottomLine: Bool) {
        presenter.history(hiddenBottomLine: hiddenBottomLine)
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable {
        return Requester.responseDTO(decodeTo: decodeTo, using: router, block: block).map { $0.response }
    }
        
    func detail(item: HistoryDetailItemType) {
        switch item {
        case .trip(let tripCode):
            self.loadTrip(by: tripCode)
        case .express(_):
            router?.routeToDetail()
        case .food(let saleOrder):
            router?.routeToFoodTracking(salesOder: saleOrder)
        case .preorder(let saleOrder):
            createOrder(item: saleOrder)
        }
    }
}

// MARK: Class's private methods
private extension HistoryInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        mutableStoreStream.storeBookingState.bind(onNext: weakify({ (_, wSelf) in
            wSelf.router?.dismissCurrentRoute(completion: nil)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func loadTrip(by tripId: String, history: Bool = false) {
        self.findTripJSON(by: tripId)
            .subscribe(onNext: { [weak self] (tripInfo) in
                var book: FCBooking?
                do {
                    book = try FCBooking(dictionary: tripInfo)
                } catch {}
                
                guard (tripInfo["info"] as? [String : Any]) != nil,
                    let _book = book,
                    _book.isIntrip() else {
                        return
                }
                self?.router?.loadTrip(info: tripInfo)
                }, onError: { (error) in
                    let err = error as NSError
                    printDebug(err.localizedDescription)
            }).disposeOnDeactivate(interactor: self)
    }
    
     func findTripJSON(by tripId: String) -> Observable<JSON> {
            let documentRef = Firestore.firestore().documentRef(collection: .trip, storePath: .custom(path: tripId), action: .read)
            return  documentRef
                .find(action: .get, json: nil)
                .map { $0?.data() ?? [:] }
                .take(1)
                .observeOn(MainScheduler.asyncInstance)
        }
}
