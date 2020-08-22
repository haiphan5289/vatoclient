//  File name   : FoodMainInteractor+Request.swift
//
//  Author      : Dung Vu
//  Created date: 7/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import VatoNetwork
import RxCocoa
import FwiCoreRX
import FwiCore
import KeyPathKit
import Alamofire

extension FoodMainInteractor {
    internal func requestOldQuoteCart() {
        let host = VatoFoodApi.host
        let router = VatoAPIRouter.customPath(authToken: "", path: "\(host)/ecom/quote", header: nil, params: nil, useFullPath: true)
        GET(router: router, type: OptionalMessageDTO<QuoteCart>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let res):
                guard let old = res.data else { return }
                wSelf.mutableStoreStream.update(quoteCard: old)
                let identify = HistoryStoreIdentify(id: Int(old.storeId ?? ""))
                wSelf.mutableStoreStream.updateStore(identify: identify)
                var basket = BasketModel()
                old.quoteItems?.forEach({ (item) in
                    let i = DisplayProduct(quoteItem: item)
                    let v = BasketProductIem.init(note: item.description, quantity: item.qty ?? 0)
                    basket[i] = v
                })
                wSelf.mutableStoreStream.update(basket: basket)
            case .failure(let e):
                #if DEBUG
                assert(false, e.localizedDescription)
                #endif
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    internal func requestBanners() {
        let id = type.categoryId
        let dispose = token.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<[FoodBannerItem]>.self, using: VatoFoodApi.listBanner(authToken: $0, params: ["rootCategoryId": id]))
        }.subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                guard let items = res.response.data else {
                    wSelf.mBanners = []
                    return
                }
                wSelf.mBanners = items
            case .error(let e):
                #if DEBUG
                   assert(false, e.localizedDescription)
                #endif
                wSelf.mBanners = []
            default:
                break
            }
        }))
        add(dispose)
    }
    
    internal func requestCategories() {
        let id = self.type.categoryId
        let dispose = token.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodCategoryResponse>.self, using: VatoFoodApi.listCategory(authToken: $0, categoryId: id , params: nil))
        }.subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                guard let data = res.response.data else {
                    wSelf.mCategories = []
                    return
                }
                wSelf.mCategories = data.children?.sorted(by: <) ?? []
            case .error(let e):
                #if DEBUG
                   assert(false, e.localizedDescription)
                #endif
                wSelf.mCategories = []
            default:
                break
            }
        }))
        add(dispose)
    }
    
    internal func requestFamiliarShops() {
        let format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"//"yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let today = Date()
        let from = Calendar.current.date(byAdding: .day, value: -15, to: today)
        var params = JSON()
        let id = type.categoryId
        params["fromDate"] = from?.toGMT().string(from: format)
        params["toDate"] = today.toGMT().string(from: format)
        params["indexPage"] = 0
        params["sizePage"] = 10
        params["rootCateId"] = id
        let host = VatoFoodApi.host
        let router = VatoAPIRouter.customPath(authToken: "", path: "\(host)/ecom/tracking/sale-order/store/history-buy", header: nil, params: params, useFullPath: true)
        
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        let dispose = network.request(using: router, decodeTo: OptionalMessageDTO<FoodStoreResponse>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let res):
                guard let data = res.data else {
                    wSelf.mShopFamilarShops = []
                    return
                }
                wSelf.mShopFamilarShops = data.listStore ?? []
            case .failure(let e):
                print(e.localizedDescription)
                wSelf.mShopFamilarShops = []
            }
        }))
        add(dispose)
    }
    
    internal func requestNews() {
        let id = type.categoryId
        let dispose = token.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodStoreResponse>.self, using: VatoFoodApi.explore(authToken: $0, params: ["indexPage": 0, "sizePage": 10, "rootCategoryId": id, "status": 4]))
        }.subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                guard let data = res.response.data else {
                    wSelf.mNews = []
                    return
                }
                wSelf.mNews = data.listStore ?? []
            case .error(let e):
                #if DEBUG
                   assert(false, e.localizedDescription)
                #endif
                wSelf.mNews = []
            default:
                break
            }
        }))
        add(dispose)
    }
    
    internal func requestNearest() {
        let dispose = originalCoordinate.take(1).flatMap({ [weak self] origin -> Observable<VatoNetwork.Response<OptionalMessageDTO<FoodStoreResponse>>> in
            guard let wSelf = self else {
                return Observable.empty()
            }
            let coor = origin.coordinate
            UserManager.instance.update(coordinate: coor)
            let id = wSelf.type.categoryId
            let params: [String: Any] = ["indexPage": 0, "sizePage": 10, "lat": coor.latitude, "lon": coor.longitude, "rootCategoryId": id, "status": 4, "sortParam": "ASC"]
            return wSelf.request(map: { Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodStoreResponse>.self, using: VatoFoodApi.nearly(authenToken: $0, params: params)) })
        }).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                guard let data = res.response.data else {
                    wSelf.mNearest = []
                    return
                }
                wSelf.mNearest = data.listStore ?? []
            case .error(let e):
                #if DEBUG
                   assert(false, e.localizedDescription)
                #endif
            default:
                break
            }
        }))
        add(dispose)
    }
    
    internal func requestFreeShip() {
        let host = VatoFoodApi.host
        let id = type.categoryId
        
        var params = JSON()
        params["indexPage"] = 0
        params["sizePage"] = 10
        params["rootCategory"] = id
        
        let router = VatoAPIRouter.customPath(authToken: "", path: "\(host)/ecom/promotion/vt/list-store-freeship", header: nil, params: params, useFullPath: true)
        let dispose = GET(router: router, type: OptionalMessageDTO<FoodStoreResponse>.self).bind(onNext: weakify({ (r, wSelf) in
            switch r {
            case .success(let r):
                wSelf.mFreeShipShops = r.data?.listStore ?? []
            case .failure(let e):
                #if DEBUG
                    assert(false, e.localizedDescription)
                #endif
            }
        }))
        add(dispose)
    }
    
    internal func createParamsDiscovery(next: Paging, rootId: Int) -> Observable<JSON> {
        return self.originAddress.filterNil().take(1).map { address -> JSON in
            var params: [String: Any] = [:]
            params["indexPage"] = next.page
            params["sizePage"] = next.size
            params["rootCategoryId"] = rootId
            params["status"] = 4
            let coord = address.coordinate
            params["lat"] = coord.latitude
            params["lon"] = coord.longitude
            params["sortParam"] = "ASC"
            return params
        }
    }
    
    func cancelRequestDiscovery() {
        disposeRequest?.dispose()
    }
    
    internal func requestDiscovery() {
        guard paging.page == Configs.pageMin - 1 || !isLoading else {
            return
        }
        
        guard let next = paging.next else {
            return
        }
        disposeRequest?.dispose()
        let isFirst = next.page <= Configs.pageMin
        let e = createParamsDiscovery(next: next, rootId: type.categoryId)
        let url = VatoFoodApi.host + "/ecom/store/explore/group-by-brand"
        isLoading = true
        disposeRequest = Observable.zip(e, token).flatMap { (item)  in
            Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodStoreResponse>.self, using: VatoAPIRouter.customPath(authToken: item.1, path: url, header: nil, params: item.0, useFullPath: true))
        }.do(onDispose: weakify({ (wSelf) in
            wSelf.isLoading = false
        })).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                guard let data = res.response.data else {
                    return
                }
                wSelf.paging = Paging(page: next.page, canRequest: data.next, size: next.size)
                if isFirst {
                    wSelf.mDiscovery = .reload(items: data.listStore ?? [])
                } else {
                    wSelf.mDiscovery = .update(items: data.listStore ?? [])
                }
            case .error(let e):
                #if DEBUG
                   assert(false, e.localizedDescription)
                #endif
                wSelf.paging = .default
                wSelf.mDiscovery = .reload(items: [])
            default:
                break
            }
        }))
    }
    
    internal func requestHighCommission() {
        let rootCategoryId = type.categoryId
        let location = self.originAddress.filterNil().take(1).map { $0.coordinate }
        let dispose = location.map { (coord) -> JSON in
            var params = JSON()
            params["indexPage"] = 0
            params["sizePage"] = 10
            params["lat"] = coord.latitude
            params["lon"] = coord.longitude
            params["rootCategoryId"] = rootCategoryId
            params["status"] = 4
            params["sortParam"] = "ASC"
            return params
        }.flatMap { [unowned self](params) -> Observable<[FoodExploreItem]?> in
            let url = VatoFoodApi.host + "/ecom/store/high-commission"
            let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: params, useFullPath: true)
            return self.GET(router: router, type: OptionalMessageDTO<FoodStoreResponse>.self).map { try $0.get().data?.listStore }
        }.catchErrorJustReturn(nil)
        .filterNil()
        .bind(onNext: weakify({ (list, wSelf) in
            wSelf.mHighCommissons = list
        }))
        add(dispose)
    }
    
    internal func requestWhatsToday() {
        let rootCategoryId = type.categoryId
        let location = self.originAddress.filterNil().take(1).map { $0.coordinate }
        let dispose = location.map { (coord) -> JSON in
            var params = JSON()
            params["indexPage"] = 0
            params["sizePage"] = 10
            params["lat"] = coord.latitude
            params["lon"] = coord.longitude
            params["rootCateId"] = rootCategoryId
            return params
        }.flatMap { [unowned self](params) -> Observable<[FoodExploreItem]?> in
            let url = VatoFoodApi.host + "/ecom/store/suggest-by-time"
            let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: params, useFullPath: true)
            return self.GET(router: router, type: OptionalMessageDTO<FoodStoreResponse>.self).map { try $0.get().data?.listStore }
        }.catchErrorJustReturn(nil)
        .filterNil()
        .bind(onNext: weakify({ (list, wSelf) in
            wSelf.mWhatsTodays = list
        }))
        add(dispose)
    }
    
    func requestStores(from brandId: Int) -> Observable<[FoodExploreItem]> {
        var params: JSON = [:]
        params["brandId"] = brandId
        params["indexPage"] = 0
        params["sizePage"] = 30
        params["status"] = 4
        let url = VatoFoodApi.host + "/ecom/store/from-brand"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: params, useFullPath: true)
        return GET(router: router, type: OptionalMessageDTO<FoodStoreResponse>.self)
            .trackProgressActivity(indicator)
            .map { try $0.get().data?.listStore }
            .catchErrorJustReturn([]).filterNil()
    }
    
    // MARK: -- Request
    internal func GET<T: Codable>(router: APIRequestProtocol, type: T.Type) -> Observable<Swift.Result<T, Error>> {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: type)
    }
}
