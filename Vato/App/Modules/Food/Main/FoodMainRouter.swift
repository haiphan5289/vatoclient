//  File name   : FoodMainRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

typealias FoodMainListenerProtocol = FoodDetailListener &
    FoodSearchListener &
    FoodListListener &
    SearchDeliveryListener &
    FoodListCategoryListener &
    LocationPickerListener &
    StoreParentListListener &
    StoreTrackingListener &
    EcomReceiptListener &
    CheckOutListener
protocol FoodMainInteractable: Interactable, FoodMainListenerProtocol {
    var router: FoodMainRouting? { get set }
    var listener: FoodMainListener? { get set }
}

protocol FoodMainViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FoodMainRouter: ViewableRouter<FoodMainInteractable, FoodMainViewControllable> {
    /// Class's constructor.
    init(interactor: FoodMainInteractable,
         viewController: FoodMainViewControllable,
         foodDetailBuildable: FoodDetailBuildable,
         foodSearchBuildable: FoodSearchBuildable,
         foodListBuildable: FoodListBuildable,
         searchDeliveryBuildable: SearchDeliveryBuildable,
         foodListCategoryBuildable: FoodListCategoryBuildable,
         locationPickerBuildable: LocationPickerBuildable,
         storeParentListBuildable: StoreParentListBuildable,
         storeTrackingBuildable: StoreTrackingBuildable,
         ecomReceiptBuildable: EcomReceiptBuildable,
         checkOutBuildable: CheckOutBuildable)
    {
        self.storeTrackingBuildable = storeTrackingBuildable
        self.foodListCategoryBuildable = foodListCategoryBuildable
        self.searchDeliveryBuildable = searchDeliveryBuildable
        self.foodSearchBuildable = foodSearchBuildable
        self.foodDetailBuildable = foodDetailBuildable
        self.foodListBuildable = foodListBuildable
        self.locationPickerBuildable = locationPickerBuildable
        self.storeParentListBuildable = storeParentListBuildable
        self.ecomReceiptBuildable = ecomReceiptBuildable
        self.checkOutBuildable = checkOutBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let foodDetailBuildable: FoodDetailBuildable
    private let foodSearchBuildable: FoodSearchBuildable
    private let foodListBuildable: FoodListBuildable
    private let searchDeliveryBuildable: SearchDeliveryBuildable
    private let foodListCategoryBuildable: FoodListCategoryBuildable
    private let locationPickerBuildable: LocationPickerBuildable
    private let storeParentListBuildable: StoreParentListBuildable
    private let storeTrackingBuildable: StoreTrackingBuildable
    private let ecomReceiptBuildable: EcomReceiptBuildable
    private let checkOutBuildable: CheckOutBuildable
}

// MARK: FoodMainRouting's members
extension FoodMainRouter: FoodMainRouting {
    func routeToListParent(items: [FoodCategoryItem]) {
        let route = storeParentListBuildable.build(withListener: interactor, list: items)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToDetail(item: FoodExploreItem) {
        let route = foodDetailBuildable.build(withListener: interactor,item: item)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToSearch(type: ServiceCategoryType) {
        let route = foodSearchBuildable.build(withListener: interactor, type: type)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToList(type: FoodListType) {
        let route = foodListBuildable.build(withListener: interactor, type: type)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToSearchLocation(address: AddressProtocol?) {
        let route = locationPickerBuildable.build(withListener: interactor,
                                                  placeModel: address,
                                                  searchType: .booking(origin: true, placeHolder: nil, icon: UIImage(named: "ic_origin"), fillInfo: true),
                                                  typeLocationPicker: .full)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToListCategory(detail: CategoryRequestProtocol) {
        let route = foodListCategoryBuildable.build(withListener: interactor, current: detail)
        let segue = RibsRouting(use: route, transitionType: .push, needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func roueToEcomReceipt(salesOder: SalesOrder) {
        let route = ecomReceiptBuildable.build(withListener: interactor, order: salesOder)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToFoodTracking(salesOder: SalesOrder) {
        guard !salesOder.completed else {
            return roueToEcomReceipt(salesOder: salesOder)
        }
        let route = storeTrackingBuildable.build(withListener: interactor, order: salesOder, id: nil)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToCheckOut() {
        let route = checkOutBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeShowAlertCancel(title: String?, body: String?, completion: @escaping AlertBlock) {
        let topVC = UIApplication.topViewController(controller: viewControllable.uiviewController)
        let alertCancel = AlertAction(style: .default, title: "OK", handler: completion)
        AlertVC.show(on: topVC, title: title, message: body, from: [alertCancel], orderType: .horizontal)
    }
    
    func validDismissAllAlert() -> Bool {
        let topVC = UIApplication.topViewController(controller: viewControllable.uiviewController)
        return !(topVC is AlertVC)
    }
}

// MARK: Class's private methods
private extension FoodMainRouter {
}
