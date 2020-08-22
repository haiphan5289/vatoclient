//  File name   : HistoryRouter.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol HistoryInteractable: Interactable, ExpressHistoryDetailListener, StoreTrackingListener, RequestQuickSupportListener, InTripListener, EcomReceiptListener, CheckOutListener, FoodDetailListener {
    var router: HistoryRouting? { get set }
    var listener: HistoryListener? { get set }
}

protocol HistoryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class HistoryRouter: ViewableRouter<HistoryInteractable, HistoryViewControllable> {
    /// Class's constructor.
    init(interactor: HistoryInteractable,
         viewController: HistoryViewControllable,
         expressHistoryDetailBuildable: ExpressHistoryDetailBuildable,
         storeTrackingBuildable: StoreTrackingBuildable,
         requestQuickSupportBuildable: RequestQuickSupportBuildable,
         inTripBuildable: InTripBuildable,
         ecomReceiptBuildable: EcomReceiptBuildable,
         checkOutBuildable: CheckOutBuildable,
         foodDetailBuildable: FoodDetailBuildable)
    {
        self.checkOutBuildable = checkOutBuildable
        self.inTripBuildable = inTripBuildable
        self.expressHistoryDetailBuildable = expressHistoryDetailBuildable
        self.storeTrackingBuildable = storeTrackingBuildable
        self.requestQuickSupportBuildable = requestQuickSupportBuildable
        self.ecomReceiptBuildable = ecomReceiptBuildable
        self.foodDetailBuildable = foodDetailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let expressHistoryDetailBuildable: ExpressHistoryDetailBuildable
    private let storeTrackingBuildable: StoreTrackingBuildable
    
    private let requestQuickSupportBuildable: RequestQuickSupportBuildable
    private let inTripBuildable: InTripBuildable
    private let ecomReceiptBuildable: EcomReceiptBuildable
    private let checkOutBuildable: CheckOutBuildable
    private let foodDetailBuildable: FoodDetailBuildable

}

// MARK: HistoryRouting's members
extension HistoryRouter: HistoryRouting {
    
    func routeToDetail(item: FoodExploreItem) {
        let route = foodDetailBuildable.build(withListener: interactor,item: item)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    func routeToCheckOut() {
        let route = checkOutBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToQuickSupport(requestModel: QuickSupportRequest, defaultContent: String?) {
        let route = requestQuickSupportBuildable.build(withListener: interactor, requestModel: requestModel, defaultContent: defaultContent)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToEcomReceipt(salesOder: SalesOrder) {
        let route = ecomReceiptBuildable.build(withListener: interactor, order: salesOder)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToFoodTracking(salesOder: SalesOrder) {
        guard !salesOder.completed else {
            return routeToEcomReceipt(salesOder: salesOder)
        }
        let route = storeTrackingBuildable.build(withListener: interactor, order: salesOder, id: nil)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToDetail() {
        let router = expressHistoryDetailBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func loadTrip(info: [String : Any]) {
        guard let info: JSON = info.value(for: "info", defaultValue: nil), let tripId: String = info.value(for: "tripId", defaultValue: nil) else {
            return
        }
        let route = inTripBuildable.build(withListener: interactor, tripId: tripId)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension HistoryRouter {
}
