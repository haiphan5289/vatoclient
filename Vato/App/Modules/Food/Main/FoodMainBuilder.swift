//  File name   : FoodMainBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FoodMainDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var mProfileStream: ProfileStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutableBookingStream: MutableBookingStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class FoodMainComponent: Component<FoodMainDependency> {
    /// Class's public properties.
    let FoodMainVC: FoodMainVC
    
    /// Class's constructor.
    init(dependency: FoodMainDependency, FoodMainVC: FoodMainVC) {
        self.FoodMainVC = FoodMainVC
        super.init(dependency: dependency)
    }
    
    var mutableStoreStream: MutableStoreStream {
        return shared { StoreStreamImpl() }
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FoodMainBuildable: Buildable {
    func build(withListener listener: FoodMainListener, type: ServiceCategoryType, action: ServiceCategoryAction?) -> FoodMainRouting
}

final class FoodMainBuilder: Builder<FoodMainDependency>, FoodMainBuildable {
    /// Class's constructor.
    override init(dependency: FoodMainDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FoodMainBuildable's members
    func build(withListener listener: FoodMainListener, type: ServiceCategoryType, action: ServiceCategoryAction?) -> FoodMainRouting {
        let vc = FoodMainVC()
        let component = FoodMainComponent(dependency: dependency, FoodMainVC: vc)

        let interactor = FoodMainInteractor(presenter: component.FoodMainVC, authenticated: component.dependency.authenticated, mutableBooking: component.dependency.mutableBookingStream, type: type, mutableStoreStream: component.mutableStoreStream, action: action)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let foodDetailBuilder = FoodDetailBuilder(dependency: component)
        let foodSearchBuilder = FoodSearchBuilder(dependency: component)
        let foodListBuilder = FoodListBuilder(dependency: component)
        let searchLocationBuilder = SearchDeliveryBuilder(dependency: component)
        let listCategoryBuilder = FoodListCategoryBuilder(dependency: component)
        let locationPickerBuilder = LocationPickerBuilder(dependency: component)
        let storeParentListBuilder = StoreParentListBuilder(dependency: component)
        let storeTrackingBuilder = StoreTrackingBuilder(dependency: component)
        let ecomReceiptBuilder = EcomReceiptBuilder(dependency: component)
        let checkoutBuilder = CheckOutBuilder(dependency: component)
        return FoodMainRouter(interactor: interactor,
                              viewController: component.FoodMainVC,
                              foodDetailBuildable: foodDetailBuilder,
                              foodSearchBuildable: foodSearchBuilder,
                              foodListBuildable: foodListBuilder,
                              searchDeliveryBuildable: searchLocationBuilder,
                              foodListCategoryBuildable: listCategoryBuilder,
                              locationPickerBuildable: locationPickerBuilder,
                              storeParentListBuildable: storeParentListBuilder,
                              storeTrackingBuildable: storeTrackingBuilder,
                              ecomReceiptBuildable: ecomReceiptBuilder,
                              checkOutBuildable: checkoutBuilder)
    }
}
