//  File name   : VatoTabbarBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol VatoTabbarDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

protocol VatoDependencyMainServiceProtocol: AnyObject {
    var firebaseDatabase: DatabaseReference { get }
    var mutableAuthenticated: MutableAuthenticatedStream { get }
    var mutableProfile: MutableProfileStream  { get }
    var mutablePromotionNows: MutablePromotionNowStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class VatoTabbarComponent: Component<VatoTabbarDependency>, VatoDependencyMainServiceProtocol {
    /// Class's public properties.
    let VatoTabbarVC: VatoTabbarVC
    
    /// Class's constructor.
    init(dependency: VatoTabbarDependency, VatoTabbarVC: VatoTabbarVC) {
        self.VatoTabbarVC = VatoTabbarVC
        super.init(dependency: dependency)
    }
    
    var firebaseDatabase: DatabaseReference {
        return shared { Database.database().reference() }
    }
    
    var mutableAuthenticated: MutableAuthenticatedStream {
        return shared { AuthenticatedStreamImpl() }
    }
    
    var mutableProfile: MutableProfileStream {
        return shared { ProfileStreamImpl() }
    }
    
    var mutablePromotionNows: MutablePromotionNowStream {
        return shared { PromotionNowStreamImpl() }
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return shared { PaymentStreamImpl() }
    }
    
    var mutableBookingStream: MutableBookingStream {
        return shared { BookingStreamImpl() }
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol VatoTabbarBuildable: Buildable {
    func build(withListener listener: VatoTabbarListener) -> VatoTabbarRouting
}

final class VatoTabbarBuilder: Builder<VatoTabbarDependency>, VatoTabbarBuildable {
    /// Class's constructor.
    override init(dependency: VatoTabbarDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: VatoTabbarBuildable's members
    func build(withListener listener: VatoTabbarListener) -> VatoTabbarRouting {
        let vc = VatoTabbarVC()
        let component = VatoTabbarComponent(dependency: dependency, VatoTabbarVC: vc)

        let interactor = VatoTabbarInteractor(presenter: component.VatoTabbarVC, component: component, mutableBooking: component.mutableBookingStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let vatoMainBuilder = VatoMainBuilder(dependency: component)
        let walletBuilder = WalletBuilder(dependency: component)
        let promotionDetail = PromotionDetailBuilder(dependency: component)
        let promotionBuilder = PromotionBuilder(dependency: component)
        let walletListHistoryBuilder = WalletListHistoryBuilder(dependency: component)
        let profileBuilder = ProfileBuilder(dependency: component)
        let mainDeliveryBuilder = MainDeliveryBuilder(dependency: component)
        
        let ticketDestinationBuilder = TicketDestinationBuilder(dependency: component)
        let mainMerchantBuilder = MainMerchantBuilder(dependency: component)
        let foodMainBuider = FoodMainBuilder(dependency: component)
        let historyBuilder = HistoryBuilder(dependency: component)
        let notificationBuilder = NotificationBuilder(dependency: component)
        let topUpByThirdPartyBuilder = TopUpByThirdPartyBuilder(dependency: component)
        
        let quickSupportBuilder = QuickSupportMainBuilder(dependency: component)
        let storeTrackingBuilder = StoreTrackingBuilder(dependency: component)
        let toShortcutBuilder = TOShortcutBuilder(dependency: component)
        let setLocationBuilder = SetLocationBuilder(dependency: component)
        let shoppingMainBuilder = ShoppingMainBuilder(dependency: component)
        return VatoTabbarRouter(interactor: interactor,
                                viewController: component.VatoTabbarVC,
                                vatoMainBuildable: vatoMainBuilder,
                                walletBuildable: walletBuilder,
                                promotionDetailBuildable: promotionDetail,
                                promotionBuildable: promotionBuilder,
                                walletListHistoryBuildable: walletListHistoryBuilder,
                                profileBuildable: profileBuilder,
                                mainDeliveryBuildable: mainDeliveryBuilder,
                                ticketDestinationBuildable: ticketDestinationBuilder,
                                mainMerchantBuildable: mainMerchantBuilder,
                                foodMainBuildable: foodMainBuider,
                                historyBuildable: historyBuilder,
                                notificationBuildable: notificationBuilder,
                                quickSupportBuildable: quickSupportBuilder,
                                topUpByThirdPartyBuildable: topUpByThirdPartyBuilder,
                                storeTrackingBuildable: storeTrackingBuilder,
                                shortcutBuildable: toShortcutBuilder,
                                setLocationBuildable: setLocationBuilder,
                                shoppingMainBuildable: shoppingMainBuilder)
                                
    }
}
