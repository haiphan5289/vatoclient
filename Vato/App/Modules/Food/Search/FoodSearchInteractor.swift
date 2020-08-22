//  File name   : FoodSearchInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 11/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa
import FwiCoreRX
import VatoNetwork
import KeyPathKit

protocol FoodSearchRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToDetail(item: FoodExploreItem)
}

protocol FoodSearchPresentable: Presentable {
    var listener: FoodSearchPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol FoodSearchListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func foodSearchMoveBack()
    func showReceipt(salesOrder: SalesOrder)
}


final class FoodSearchInteractor: PresentableInteractor<FoodSearchPresentable>, RequestInteractorProtocol {
    struct Configs {
        static let numberItemsDiscovery = 2
        static let pageMin = -1
    }
    
    private struct FoodSearchHistory {
        struct Configs {
            static let fName: String = "food_keyword_history_%@.txt"
        }
        @CacheFile(fileName: "") var list: [String]
        init(categoryId: Int) {
            let name = String(format: Configs.fName, "\(categoryId)")
            self._list.fName = name
        }
        
        mutating func add(item: String?) {
            _list.add(item: item, clear: false)
        }
        
        func save() {
            _list.save()
        }
    }
        
    /// Class's public properties.
    weak var router: FoodSearchRouting?
    weak var listener: FoodSearchListener?
    private var isLoading: Bool = false

    /// Class's constructor.
    init(presenter: FoodSearchPresentable, authenticated: AuthenticatedStream, type: ServiceCategoryType) {
        self.type = type
        self.authenticated = authenticated
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        requestKeyword()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        history.save()
        // todo: Pause any business logic.
    }
    
    func search(keyword: String?) {
        if !(paging.keyword == keyword) {
            paging.update(keyword: keyword)
            paging.resetPage()
        }
        
        if keyword == nil || keyword?.isEmpty == true {
            self.mSearchItem.onNext(.reload(items: []))
            return
        }
        
        guard paging.page == Configs.pageMin || !isLoading else {
            return
        }
        
        guard let next = paging.next else {
            return
        }
        disposeSearch?.dispose()
        let isFirst = paging.first
        var params = next.params
        let cateId = type.categoryId
        let url = VatoFoodApi.host + "/ecom/store/by-key-words"
        let coordinate = UserManager.instance.currentLocation
        params["lat"] = coordinate?.latitude
        params["lon"] = coordinate?.longitude
        params["rootCateId"] = cateId

        disposeSearch = token.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodSearchStoreResponse>.self,
                                  using: VatoAPIRouter.customPath(authToken: $0, path: url, header: nil, params: params, useFullPath: true))
            }.trackProgressActivity(indicator).subscribe(weakify({ (event, wSelf) in
                switch event {
                case .next(let res):
                    defer {
                        wSelf.history.add(item: keyword)
                    }
                    guard let data = res.response.data else {
                        return
                    }
                    
                    wSelf.paging = PagingKeyword(keyword: keyword, page: next.page, size: next.size, canRequest: data.next)
                    if isFirst {
                        wSelf.mSearchItem.onNext(.reload(items: data.listStore ?? []))
                    } else {
                        wSelf.mSearchItem.onNext(.update(items: data.listStore ?? []))
                    }
                case .error(let e):
                    #if DEBUG
                       assert(false, e.localizedDescription)
                    #endif
                default:
                    break
                }
            }))
        
    }
    
    func refreshSearch() {
        paging.resetPage()
        self.search(keyword: paging.keyword)
    }
    
    private func requestKeyword() {
        var params = [String: Any]()
        params["indexPage"] = 0
        params["rootCategoryId"] = type.categoryId
        params["sizePage"] = 8
        
        request(map: { Requester.responseCacheDTO(decodeTo: OptionalMessageDTO<StoreKeywordsResponse>.self, using: VatoFoodApi.suggestKeyword(authToken: $0, params: params))}).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                let items = res.response.data?.listSearchText?.sorted(by: >).compactMap({ $0.textSearch })
                wSelf.mTags.accept(items ?? [])
            case .error(let e):
                assert(false, e.localizedDescription)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func requestNextSearch() {
        self.search(keyword: paging.keyword)
    }

    /// Class's private properties.
    private let authenticated: AuthenticatedStream
    private var disposeSearch: Disposable?
    private var mTags: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    private var mSearchItem: ReplaySubject<ListUpdate<FoodExploreItem>> = ReplaySubject.create(bufferSize: 1)
    var token: Observable<String> {
        return authenticated.firebaseAuthToken.take(1)
    }
    private lazy var paging = PagingKeyword.default
    private lazy var history = FoodSearchHistory(categoryId: self.type.categoryId)
    private let type: ServiceCategoryType
}

// MARK: FoodSearchInteractable's members
extension FoodSearchInteractor: FoodSearchInteractable, ActivityTrackingProgressProtocol {
    func showReceipt(salesOrder: SalesOrder) {
        listener?.showReceipt(salesOrder: salesOrder)
    }
}

// MARK: FoodSearchPresentableListener's members
extension FoodSearchInteractor: FoodSearchPresentableListener, Weakifiable {
    var tags: Observable<[String]> {
        return mTags.observeOn(MainScheduler.asyncInstance)
    }
    
    var search: Observable<ListUpdate<FoodExploreItem>> {
        return mSearchItem.observeOn(MainScheduler.asyncInstance)
    }
    
    var keywordsHistory: Observable<[String]> {
        return history.$list.observeOn(MainScheduler.asyncInstance)
    }
    
    func foodSearchMoveBack() {
        listener?.foodSearchMoveBack()
    }
    
    func detailFoodMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToDetail(item: FoodExploreItem) {
        router?.routeToDetail(item: item)
    }
}

// MARK: Class's private methods
private extension FoodSearchInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        loadingProgress.bind(onNext: weakify({ (flag, wSelf) in
            wSelf.isLoading = flag.0
        })).disposeOnDeactivate(interactor: self)
    }
}
