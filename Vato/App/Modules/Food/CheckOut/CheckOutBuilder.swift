//  File name   : CheckOutBuilder.swift
//
//  Author      : khoi tran
//  Created date: 12/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol CheckOutDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var mutableStoreStream: MutableStoreStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var profile: ProfileStream { get }
}

final class CheckOutComponent: Component<CheckOutDependency> {
    /// Class's public properties.
    let CheckOutVC: CheckOutVC
    
    /// Class's constructor.
    init(dependency: CheckOutDependency, CheckOutVC: CheckOutVC) {
        self.CheckOutVC = CheckOutVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol CheckOutBuildable: Buildable {
    func build(withListener listener: CheckOutListener) -> CheckOutRouting
}

final class CheckOutBuilder: Builder<CheckOutDependency>, CheckOutBuildable {
    /// Class's constructor.
    override init(dependency: CheckOutDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: CheckOutBuildable's members
    func build(withListener listener: CheckOutListener) -> CheckOutRouting {
        let vc = CheckOutVC(nibName: CheckOutVC.identifier, bundle: nil)
        let component = CheckOutComponent(dependency: dependency, CheckOutVC: vc)

        let interactor = CheckOutInteractor(presenter: component.CheckOutVC,
                                            authenticated: component.dependency.authenticated,
                                            mutableStoreStream: component.dependency.mutableStoreStream,
                                            mutablePaymentStream: component.dependency.mutablePaymentStream,
                                            mProfileStream: component.dependency.profile,
                                            firebaseDatabase: component.dependency.firebaseDatabase)
        let noteDeliveryBuilder = NoteDeliveryBuilder(dependency: component)
        let switchPaymentBuilder = SwitchPaymentBuilder(dependency: component)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let locationPickerBuilder = LocationPickerBuilder(dependency: component)
        let storeTrackingBuilder = StoreTrackingBuilder(dependency: component)
        let storeDetailPriceBuilder = StoreDetailPriceBuilder(dependency: component)
        let productMenuBuilder = ProductMenuBuilder(dependency: component)
        let topUpBuilder = TopUpByThirdPartyBuilder(dependency: component)
        let ecomPromotionBuildable = EcomPromotionBuilder(dependency: component)
        let walletBuilder = WalletBuilder(dependency: component)
        return CheckOutRouter(interactor: interactor,
                              viewController: component.CheckOutVC,
                              locationPickerBuildable: locationPickerBuilder,
                              noteDeliveryBuildable: noteDeliveryBuilder,
                              switchPaymentBuildable: switchPaymentBuilder,
                              storeTrackingBuildable: storeTrackingBuilder,
                              storeDetailPriceBuildable: storeDetailPriceBuilder,
                              productMenuBuildable: productMenuBuilder,
                              topUpByThirdPartyBuildable: topUpBuilder,
                              ecomPromotionBuildable: ecomPromotionBuildable,
                              walletBuildable: walletBuilder)
    }
}
