//  File name   : FoodListCategoryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCore
import FwiCoreRX
import RxCocoa

protocol FoodListCategoryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToList(type: FoodListType)
    func routeToListCategory(detail: CategoryRequestProtocol)
}

protocol FoodListCategoryPresentable: Presentable {
    var listener: FoodListCategoryPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol FoodListCategoryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func foodCategoryMoveBack()
    func routeToFoodDetail()
    func showReceipt(salesOrder: SalesOrder)
}

final class FoodListCategoryInteractor: PresentableInteractor<FoodListCategoryPresentable> {
    /// Class's public properties.
    weak var router: FoodListCategoryRouting?
    weak var listener: FoodListCategoryListener?
    var current: CategoryRequestProtocol

    /// Class's constructor.
    init(presenter: FoodListCategoryPresentable, authenticated: AuthenticatedStream, current: CategoryRequestProtocol) {
        self.authenticated = authenticated
        self.current = current
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
    
    private func requestData() {
        var params = [String: Any]()
        params["rootId"] = current.id
        let router = VatoFoodApi.leafCategory(authToken: token, params: params)
        Requester.responseDTO(decodeTo: OptionalMessageDTO<[MerchantCategory]>.self, using: router).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                let items = (res.response.data ?? []).sorted(by: <)
                wSelf.mList.onNext(items)
            case .error(let e):
                assert(false, e.localizedDescription)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }

    /// Class's private properties.
    private let authenticated: AuthenticatedStream
    private var mList = ReplaySubject<[MerchantCategory]>.create(bufferSize: 1)
    private var token: String = ""
}

// MARK: FoodListCategoryInteractable's members
extension FoodListCategoryInteractor: FoodListCategoryInteractable, Weakifiable {
    func showReceipt(salesOrder: SalesOrder) {
        listener?.showReceipt(salesOrder: salesOrder)
    }
    
    func routeToFoodDetail() {
        listener?.routeToFoodDetail()
    }
    
    func foodListMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: FoodListCategoryPresentableListener's members
extension FoodListCategoryInteractor: FoodListCategoryPresentableListener {
    var list: Observable<[MerchantCategory]> {
        return mList.observeOn(MainScheduler.asyncInstance)
    }
    
    func refresh() {
        requestData()
    }
    
    func foodListCategoryMoveBack() {
        listener?.foodCategoryMoveBack()
    }
    
    func foodCategoryMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToList(type: FoodListType) {
        router?.routeToList(type: type)
    }
    
    func routeToListCategory(detail: CategoryRequestProtocol) {
        router?.routeToListCategory(detail: detail)
    }
    
}

// MARK: Class's private methods
private extension FoodListCategoryInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        authenticated.firebaseAuthToken.take(1).bind(onNext: weakify({ (token, wSelf) in
            wSelf.token = token
        })).disposeOnDeactivate(interactor: self)
    }
}
