//  File name   : HistoryBuilder.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol HistoryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var profile: ProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var mutableBookingStream: MutableBookingStream { get }
}

final class HistoryComponent: Component<HistoryDependency> {
    /// Class's public properties.
    let historyVC: HistoryVC
    
    /// Class's constructor.
    init(dependency: HistoryDependency, historyVC: HistoryVC) {
        self.historyVC = historyVC
        super.init(dependency: dependency)
    }
    
    var mutableStoreStream: MutableStoreStream {
        return shared { StoreStreamImpl() }
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol HistoryBuildable: Buildable {
    func build(withListener listener: HistoryListener, selected: HistoryItemType?) -> HistoryRouting
}

final class HistoryBuilder: Builder<HistoryDependency>, HistoryBuildable {
    /// Class's constructor.
    override init(dependency: HistoryDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: HistoryBuildable's members
    func build(withListener listener: HistoryListener, selected: HistoryItemType?) -> HistoryRouting {
        guard let vc = UIStoryboard(name: "History", bundle: nil).instantiateViewController(withIdentifier: HistoryVC.identifier) as? HistoryVC else { fatalError("Please Implement") }
        let component = HistoryComponent(dependency: dependency, historyVC: vc)

        let interactor = HistoryInteractor(presenter: component.historyVC,
                                           authenticated: component.dependency.authenticated,
                                           mutableStoreStream: component.mutableStoreStream,
                                           selected: selected)
        interactor.listener = listener

        let expressHistoryDetailBuilder = ExpressHistoryDetailBuilder(dependency: component)
        let storeTrackingBuilder = StoreTrackingBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        let requestQuickSupportBuilder = RequestQuickSupportBuilder(dependency: component)
        let inTripBuilder = InTripBuilder(dependency: component)
        let receiptBuilder = EcomReceiptBuilder(dependency: component)
        let checkoutBuilder = CheckOutBuilder(dependency: component)
        let foodDetailBuilder = FoodDetailBuilder(dependency: component)
        
        return HistoryRouter(interactor: interactor,
                             viewController: component.historyVC,
                             expressHistoryDetailBuildable: expressHistoryDetailBuilder,
                            storeTrackingBuildable: storeTrackingBuilder,
                            requestQuickSupportBuildable: requestQuickSupportBuilder,
                            inTripBuildable: inTripBuilder,
                            ecomReceiptBuildable: receiptBuilder,
                            checkOutBuildable: checkoutBuilder,
                            foodDetailBuildable: foodDetailBuilder)
    }
}
