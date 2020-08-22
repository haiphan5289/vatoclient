//  File name   : FoodListInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 11/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa
import FwiCore
import FwiCoreRX
import VatoNetwork

enum FoodListType {
    case none
    case news(rootId: Int)
    case nearest(rootId: Int)
    case discovery(rootId: Int)
    case familarShop(rootId: Int)
    case whatstoday(rootId: Int)
    case freeShipShop(rootId: Int)
    case highCommission(rootId: Int)
    case category(model: CategoryRequestProtocol)
    
    var title: String {
        switch self {
        case .news:
            return "Mới nhất"
        case .nearest:
            return "Gần tôi"
        case .discovery(let rootId):
            guard let type = ServiceCategoryType.loadEcom(category: rootId) else {
                return "Khám phá"
            }
            switch type {
            case .food:
                return "Quán ngon gần tôi"
            default:
                return "Khám phá"
            }
        case .category(let model):
            return model.name ?? ""
        case .familarShop:
            return "Quán quen"
        case .freeShipShop:
            return "Free ship"
        case .whatstoday:
            return "Hôm nay ăn gì"
        case .highCommission:
            return "Gợi ý"
        default:
            return ""
        }
    }
    
    var offsetRequest: Bool {
        return false
    }
}

protocol FoodListRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToDetail(item: FoodExploreItem)
    func routeToCheckOut()
}

protocol FoodListPresentable: Presentable {
    var listener: FoodListPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol FoodListListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func foodListMoveBack()
    func routeToFoodDetail()
    func showReceipt(salesOrder: SalesOrder)
}

final class FoodListInteractor: PresentableInteractor<FoodListPresentable> {
    struct Configs {
        static let numberItemsDiscovery = 10
        static let pageMin = 0
    }
    /// Class's public properties.
    weak var router: FoodListRouting?
    weak var listener: FoodListListener?
    private let type: FoodListType
    private var rootCategoryId: Int?

    /// Class's constructor.
    init(presenter: FoodListPresentable, type: FoodListType, authenticated: AuthenticatedStream, mutableStoreStream: MutableStoreStream) {
        self.mutableStoreStream = mutableStoreStream
        self.authenticated = authenticated
        self.type = type
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        requestData()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private func generate(params: [String: Any]) -> Observable<OptionalMessageDTO<FoodStoreResponse>> {
        let router: APIRequestProtocol
        switch type {
        case .news(let rootId), .discovery(let rootId):
            var params = params
            params["status"] = 4
            params["rootCategoryId"] = rootId
            router = VatoFoodApi.explore(authToken: token, params: params)
        case .nearest(let rootId):
            self.rootCategoryId = rootId
            let coordinate = UserManager.instance.currentLocation
            var params = params
            params["lat"] = coordinate?.latitude
            params["lon"] = coordinate?.longitude
            params["rootCategoryId"] = rootId
            params["status"] = 4
            params["sortParam"] = "ASC"
            router = VatoFoodApi.nearly(authenToken: token, params: params)
        case .freeShipShop(let id):
            var params = params
            params["rootCategory"] = id
            let host = VatoFoodApi.host
            router = VatoAPIRouter.customPath(authToken: token, path: "\(host)/ecom/promotion/vt/list-store-freeship", header: nil, params: params, useFullPath: true)
        case .highCommission(let rootId):
            let coordinate = UserManager.instance.currentLocation
            var params = params
            params["lat"] = coordinate?.latitude
            params["lon"] = coordinate?.longitude
            params["rootCategoryId"] = rootId
            params["status"] = 4
            params["sortParam"] = "ASC"
            let url = VatoFoodApi.host + "/ecom/store/high-commission"
            router = VatoAPIRouter.customPath(authToken: token, path: url, header: nil, params: params, useFullPath: true)
        case .whatstoday(let rootId):
            let coordinate = UserManager.instance.currentLocation
            var params = params
            params["lat"] = coordinate?.latitude
            params["lon"] = coordinate?.longitude
            params["rootCateId"] = rootId
            let url = VatoFoodApi.host + "/ecom/store/suggest-by-time"
            router = VatoAPIRouter.customPath(authToken: token, path: url, header: nil, params: params, useFullPath: true)
        case .familarShop(let rootId):
            let format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"//"yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let today = Date()
            let from = Calendar.current.date(byAdding: .day, value: -30, to: today)
            var params = params
            params["fromDate"] = from?.toGMT().string(from: format)
            params["toDate"] = today.toGMT().string(from: format)
            params["rootCateId"] = rootId
            let host = VatoFoodApi.host
            router = VatoAPIRouter.customPath(authToken: token, path: "\(host)/ecom/tracking/sale-order/store/history-buy", header: nil, params: params, useFullPath: true)
        case .category(let model):
            let id = model.id ?? 0
            var params = params
            params["status"] = 4
            router = VatoFoodApi.stores(authToken: token, categoryId: id, params: params)
        default:
            fatalError("Please Implement")
        }
        return Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodStoreResponse>.self, using: router).map { $0.response }
    }
    
    private func requestData() {
        guard paging.page == Configs.pageMin - 1 || !isLoading else {
            return
        }
        
        guard let next = paging.next else {
            return
        }
        disposeRequest?.dispose()
        let isFirst = next.page <= Configs.pageMin
        var params: [String: Any] = [:]
        if type.offsetRequest {
            params["offset"] = next.page
            params["pageSize"] = next.size
        } else {
            params["indexPage"] = next.page
            params["sizePage"] = next.size
        }
        disposeRequest = generate(params: params).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                guard let data = res.data else {
                    return
                }
                wSelf.paging = Paging(page: next.page, canRequest: data.next, size: next.size)
                if isFirst {
                    wSelf.mItems.onNext(.reload(items: data.listStore ?? []))
                } else {
                    wSelf.mItems.onNext(.update(items: data.listStore ?? []))
                }
            case .error(let e):
                assert(false, e.localizedDescription)
            default:
                break
            }
        }))
    }

    private let authenticated: AuthenticatedStream
    private lazy var paging = Paging(page: Configs.pageMin - 1, canRequest: true, size: Configs.numberItemsDiscovery)
    private lazy var mItems = ReplaySubject<ListUpdate<FoodExploreItem>>.create(bufferSize: 1)
    private var token: String = ""
    private var isLoading: Bool = false
    private var disposeRequest: Disposable?
    private var mutableStoreStream: MutableStoreStream
    /// Class's private properties.
}

// MARK: FoodListInteractable's members
extension FoodListInteractor: FoodListInteractable, ActivityTrackingProtocol, Weakifiable {
    func dismissCheckOut() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToFoodDetail() {
        listener?.routeToFoodDetail()
    }
    
    func showReceipt(salesOrder: SalesOrder) {
        listener?.showReceipt(salesOrder: salesOrder)
    }
    
    func routeToCheckOut() {
        router?.routeToCheckOut()
    }
}

// MARK: FoodListPresentableListener's members
extension FoodListInteractor: FoodListPresentableListener {
    var quoteCart: Observable<QuoteCart?> {
        return mutableStoreStream.quoteCart
    }
    
    var items: Observable<ListUpdate<FoodExploreItem>> {
        return mItems.observeOn(MainScheduler.asyncInstance)
    }
    
    func refresh() {
        paging = Paging(page: Configs.pageMin - 1, canRequest: true, size: Configs.numberItemsDiscovery)
        requestData()
    }
    
    func loadNext() {
        requestData()
    }
    
    func foodListMoveBack() {
        listener?.foodListMoveBack()
    }
    
    func routeToDetail(item: FoodExploreItem) {
        router?.routeToDetail(item: item)
    }
    
    func detailFoodMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: Class's private methods
private extension FoodListInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        self.indicator.asObservable().bind(onNext: weakify({ (loading, wSelf) in
            wSelf.isLoading = loading
        })).disposeOnDeactivate(interactor: self)
        
        authenticated.firebaseAuthToken.take(1).bind(onNext: weakify({ (token, wSelf) in
            wSelf.token = token
        })).disposeOnDeactivate(interactor: self)
    }
}
