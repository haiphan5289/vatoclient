//  File name   : StoreParentListInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 11/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import RxCocoa
import VatoNetwork

protocol StoreParentListRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToListCategory(detail: CategoryRequestProtocol)
    func routeToList(type: FoodListType)
}

protocol StoreParentListPresentable: Presentable {
    var listener: StoreParentListPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol StoreParentListListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func storeParentListMoveBack()
    func routeToFoodDetail()
}

final class StoreParentListInteractor: PresentableInteractor<StoreParentListPresentable> {
    /// Class's public properties.
    weak var router: StoreParentListRouting?
    weak var listener: StoreParentListListener?

    /// Class's constructor.
    init(presenter: StoreParentListPresentable, authenticated: AuthenticatedStream, list: [FoodCategoryItem]) {
        self.authenticated = authenticated
        super.init(presenter: presenter)
        presenter.listener = self
        mSource.accept(list)
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

    /// Class's private properties.
    private lazy var mSource: BehaviorRelay<[FoodCategoryItem]> = BehaviorRelay(value: [])
    private let authenticated: AuthenticatedStream
}

// MARK: StoreParentListInteractable's members
extension StoreParentListInteractor: StoreParentListInteractable, RequestInteractorProtocol {
    func showReceipt(salesOrder: SalesOrder) {}
    
    func routeToFoodDetail() {
        listener?.routeToFoodDetail()
    }
    
    func foodCategoryMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func foodListMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    
    var token: Observable<String> {
        return authenticated.firebaseAuthToken.take(1)
    }
    
    var source: Observable<[FoodCategoryItem]> {
        return mSource.observeOn(MainScheduler.asyncInstance)
    }
    
    func storeParentListMoveBack() {
        listener?.storeParentListMoveBack()
    }
    
}

// MARK: StoreParentListPresentableListener's members
extension StoreParentListInteractor: StoreParentListPresentableListener, ActivityTrackingProgressProtocol, Weakifiable {
    var trackLoading: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func select(at idx: Int) {
        guard let item = mSource.value[safe: idx], let id = item.id else {
            return
        }
        
        request(map: { Requester.responseDTO(decodeTo: OptionalMessageDTO<FoodCategoryResponse>.self, using: VatoFoodApi.listCategory(authToken: $0, categoryId: id > 0 ? id : nil, params: nil)) })
            .observeOn(MainScheduler.asyncInstance)
            .trackProgressActivity(indicator)
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

// MARK: Class's private methods
private extension StoreParentListInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
    
    func routeToList(type: FoodListType) {
        router?.routeToList(type: type)
    }
    
    func routeToListCategory(detail: CategoryRequestProtocol) {
        router?.routeToListCategory(detail: detail)
    }
}
