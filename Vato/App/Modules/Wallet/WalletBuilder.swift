//  File name   : WalletBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase

enum WalletSourceType: Int {
    case home
    case booking
}

// MARK: Dependency
protocol WalletDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    // authen key
    var authenticated: AuthenticatedStream { get }
    // database
    var firebaseDatabase: DatabaseReference { get }
    var mProfileStream: ProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class WalletComponent: Component<WalletDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol WalletBuildable: Buildable {
    func build(withListener listener: WalletListener, source: WalletSourceType) -> WalletRouting
}

final class WalletBuilder: Builder<WalletDependency>, WalletBuildable {

    override init(dependency: WalletDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: WalletListener, source: WalletSourceType) -> WalletRouting {
        let component = WalletComponent(dependency: dependency)
        let viewController = WalletVC()

        let interactor = WalletInteractor(presenter: viewController,
                                          authenticated: component.dependency.authenticated,
                                          firebaseDatabase: component.dependency.firebaseDatabase,
                                          profileStream: component.dependency.mProfileStream,
                                          paymentStream: component.dependency.mutablePaymentStream,
                                          source: source)
        
        interactor.listener = listener
        let historyDetailBuilder = WalletDetailHistoryBuilder(dependency: component)
        let listHistoryBuilder = WalletListHistoryBuilder(dependency: component)
        let paymentMethodManageBuildabler = PaymentMethodManageBuilder(dependency: component)
        let topupBuilder = TopUpByThirdPartyBuilder(dependency: component)
        return WalletRouter(interactor: interactor,
                            viewController: viewController,
                            historyDetailBuilder: historyDetailBuilder,
                            listHistoryBuildabler: listHistoryBuilder,
                            paymentMethodManageBuildabler: paymentMethodManageBuildabler,
                            topUpByThirdPartyBuildable: topupBuilder)
    }
}
