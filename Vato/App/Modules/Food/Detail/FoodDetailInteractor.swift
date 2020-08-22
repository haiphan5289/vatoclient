//  File name   : FoodDetailInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa
import VatoNetwork
import Alamofire

protocol FoodDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToMap(item: FoodExploreItem)
    func routeToProductMenu(product: DisplayProduct, basketItem: BasketStoreValueProtocol?)
    func routeToCheckOut(item: FoodExploreItem)
}

protocol FoodDetailPresentable: Presentable {
    var listener: FoodDetailPresentableListener? { get set }
    func add(item: DisplayProduct, number: BasketStoreValueProtocol?)
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showConfirmRemoveBasketAlert(cancelHandler: @escaping AlertBlock, confirmHandler: @escaping AlertBlock)

}

protocol FoodDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func detailFoodMoveBack()
    func showReceipt(salesOrder: SalesOrder)
}

final class FoodDetailInteractor: PresentableInteractor<FoodDetailPresentable>, RequestInteractorProtocol, ActivityTrackingProgressProtocol {
    var token: Observable<String> {
        return authenticated.firebaseAuthToken.take(1)
    }
    
    /// Class's public properties.
    weak var router: FoodDetailRouting?
    weak var listener: FoodDetailListener?

    /// Class's constructor.
    init(presenter: FoodDetailPresentable, item: FoodExploreItem, authenticated: AuthenticatedStream, mutableStoreStream: MutableStoreStream, mutablePaymentStream: MutablePaymentStream) {
        self.item = item
        self.mutableStoreStream = mutableStoreStream
        self.authenticated = authenticated
        self.mutablePaymentStream = mutablePaymentStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        requestMenu()
        requestPromotions()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private func requestMenu() {
        guard let id = item.id else { return }
        self.request { Requester.responseDTO(decodeTo: OptionalMessageDTO<[DisplayProductCategory]>.self,
                                             using: VatoFoodApi.listDisplayProduct(authToken: $0, storeId: id, statusList:"3", params: nil), progress: nil)
            }
            .trackProgressActivity(indicator)
            .subscribe(weakify({ (event, wSelf) in
                switch event {
                case .next(let res):
                    if let e = res.response.error {
                        wSelf.errorSubject = .errorSystem(err: e)
                        print(e.localizedDescription)
                    } else {
                        let items = res.response.data ?? []
                        wSelf.mMenu.onNext(items)
                    }
                case .error(let e):
                    wSelf.errorSubject = .errorSystem(err: e)
                    print(e.localizedDescription)
                default:
                    break
                }
            })).disposeOnDeactivate(interactor: self)
    }

    /// Class's private properties.
    private (set)var item: FoodExploreItem
    private let authenticated: AuthenticatedStream
    private lazy var mMenu = ReplaySubject<[DisplayProductCategory]>.create(bufferSize: 1)
    private let mutableStoreStream: MutableStoreStream
    private let mutablePaymentStream: MutablePaymentStream
    @Replay(queue: MainScheduler.asyncInstance) private var errorSubject: MerchantState
    @Replay(queue: MainScheduler.asyncInstance) var mItemsPromotion: [EcomPromotion]?

}

// MARK: FoodDetailInteractable's members
extension FoodDetailInteractor: FoodDetailInteractable, Weakifiable {
    func routeToFoodDetail() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func showReceipt(salesOrder: SalesOrder) {
        listener?.showReceipt(salesOrder: salesOrder)
    }
    
    
    func dismissCheckOut() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func productMenuMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    private func updateBasket(product: DisplayProduct, basketItem: BasketStoreValueProtocol?) {
        self.mutableStoreStream.update(item: product, value: basketItem)
        self.presenter.add(item: product, number: basketItem)
    }
    
    func productMenuConfirm(product: DisplayProduct, basketItem: BasketStoreValueProtocol?) {
        self.router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.updateBasket(product: product, basketItem: basketItem)
        }))
    }
    
    private func requestPromotions() {
        guard let storeId = item.id else { return }
        let host = VatoFoodApi.host
        let p = "\(host)" + "/ecom/promotion/merchant/list-all-campaign/\(storeId)"
        var params = JSON()
        params["indexPage"] = 0
        params["sizePage"] = 1000
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: params, useFullPath: true)
        request(router: router, decodeTo: EcomPromotionResponse.self).bind(onNext: weakify({ (response, wSelf) in
            let i = response.items.map { items -> [EcomPromotion] in
                items.map {
                    var new = $0
                    new.canApply = false
                    return new
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
}

// MARK: FoodDetailPresentableListener's members
extension FoodDetailInteractor: FoodDetailPresentableListener {
    var itemsPromotion: Observable<[EcomPromotion]?> {
        return $mItemsPromotion
    }
    
    var errorObserable: Observable<MerchantState> {
        return $errorSubject
    }
    
    var basket: Observable<BasketModel> {
        return mutableStoreStream.basket
    }
    
    var menu: Observable<[DisplayProductCategory]> {
        return mMenu.observeOn(MainScheduler.asyncInstance)
    }
    
    var loading: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func detailFoodMoveBack() {
        listener?.detailFoodMoveBack()
    }
    
    func routeToMap() {
        router?.routeToMap(item: item)
    }
    
    func foodMapMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func removeProduct(item: DisplayProduct) {
        updateBasket(product: item, basketItem: nil)
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
    
    private func excuteClearBasket() -> Observable<Void> {
        return self.mutableStoreStream.quoteCart.take(1).flatMap { [weak self] (quote) -> Observable<Void> in
            if let q = quote, let id = q.id {
                guard let wSelf = self else { return Observable.empty() }
                return wSelf.deleteQuoute(id: id)
            } else {
                return Observable.just(())
            }
        }
    }
    
    private func clearAndMoveToProductMenu(item: DisplayProduct) {
        self.clearStoreStream()
        let value = self.mutableStoreStream[item]
        self.router?.routeToProductMenu(product: item, basketItem: value)
    }
    
    private func showAlertConfirmClear(item: DisplayProduct) {
        self.presenter.showConfirmRemoveBasketAlert(cancelHandler: {}, confirmHandler: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.clearAndMoveToProductMenu(item: item)
        })
    }
    
    func routeToProductMenu(item: DisplayProduct) {
        let e1 = self.mutableStoreStream.currentStoreId.take(1)
        let e2 = self.mutableStoreStream.basket.take(1)
        
        Observable.combineLatest(e1, e2).observeOn(MainScheduler.asyncInstance).bind {[weak self] (f, basketModel) in
            guard let wSelf = self else { return }
            if let storeId = f, !basketModel.isEmpty {
                if storeId != wSelf.item.id ?? 0 {
                    wSelf.showAlertConfirmClear(item: item)
                } else {
                    let value = wSelf.mutableStoreStream[item]
                    wSelf.router?.routeToProductMenu(product: item, basketItem: value)
                }
            } else {
               wSelf.clearStoreStream()
               let value = wSelf.mutableStoreStream[item]
               wSelf.router?.routeToProductMenu(product: item, basketItem: value)
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func clearStoreStream() {
        self.mutableStoreStream.update(basket: [:])
//
        self.mutableStoreStream.update(store: self.item)
    }
    
    func routeToCheckOut(item: FoodExploreItem) {
        self.router?.routeToCheckOut(item: item)
    }
    
    func value(from item: DisplayProduct) -> BasketStoreValueProtocol? {
        let value = mutableStoreStream[item]
        return value
    }

    
    func createQuoteCard() {
        guard let customerId = UserManager.instance.info?.id else {
            return
        }
        
        self.mutableStoreStream.createParams(customerId: customerId).bind {[weak self] (params) in
            guard let wSelf = self, let p = params else { return }
            wSelf.requestCreateCard(params: p.params, method: p.method)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func requestCreateCard(params: JSON, method: HTTPMethod) {
        self.request { key -> Observable<(HTTPURLResponse, OptionalMessageDTO<QuoteCart>)>  in
            printDebug("Authtoken ----------")
            printDebug(key)
            return Requester.requestDTO(using: VatoFoodApi.createQuoteCart(authToken: key, params: params),
                                 method: method,
                                 encoding: JSONEncoding.default)
            }
            .trackProgressActivity(indicator)
            .subscribe(weakify({ (event, wSelf) in
                switch event {
                case .next(let res):
                    if res.1.fail == true {
                        let errType = MerchantState.generalError(status: res.1.status, message: res.1.message ?? "")
                        wSelf.errorSubject = errType
                    } else {
                        if let data = res.1.data {                            
                            wSelf.mutableStoreStream.update(quoteCard: data)
                            wSelf.routeToCheckOut(item: wSelf.item)
                        }
                        
                    }
                case .error(let e):
                     wSelf.errorSubject = .errorSystem(err: e)
                    print(e.localizedDescription)
                default:
                    break
                }
            })).disposeOnDeactivate(interactor: self)
    }
    
}


// MARK: Class's private methods
private extension FoodDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        self.basket.filter { $0.isEmpty }.flatMap { [weak self](_) -> Observable<Void> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.excuteClearBasket()
        }.bind { [weak self](_) in
            self?.mutableStoreStream.update(quoteCard: nil)
            #if DEBUG
               print("Completed clear basket!!!")
            #endif
        }.disposeOnDeactivate(interactor: self)
    }
}
