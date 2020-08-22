//  File name   : TopUpByThirdPartyBuilder.swift
//
//  Author      : khoi tran
//  Created date: 2/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TopUpByThirdPartyDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutablePaymentStream: MutablePaymentStream { get }
    var authenticated: AuthenticatedStream { get }

}

final class TopUpByThirdPartyComponent: Component<TopUpByThirdPartyDependency> {
    /// Class's public properties.
    let TopUpByThirdPartyVC: TopUpByThirdPartyVC
    
    /// Class's constructor.
    init(dependency: TopUpByThirdPartyDependency, TopUpByThirdPartyVC: TopUpByThirdPartyVC) {
        self.TopUpByThirdPartyVC = TopUpByThirdPartyVC
        super.init(dependency: dependency)
    }
    
    var mutableTopUpStream: MutableTopUpStream {
        return shared { TopUpStreamImpl() }
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TopUpByThirdPartyBuildable: Buildable {
    func build(withListener listener: TopUpByThirdPartyListener) -> TopUpByThirdPartyRouting
}

final class TopUpByThirdPartyBuilder: Builder<TopUpByThirdPartyDependency>, TopUpByThirdPartyBuildable {
    /// Class's constructor.
    override init(dependency: TopUpByThirdPartyDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TopUpByThirdPartyBuildable's members
    func build(withListener listener: TopUpByThirdPartyListener) -> TopUpByThirdPartyRouting {
        let vc = TopUpByThirdPartyVC.init(nibName: TopUpByThirdPartyVC.identifier, bundle: nil)
        let component = TopUpByThirdPartyComponent(dependency: dependency, TopUpByThirdPartyVC: vc)

        let interactor = TopUpByThirdPartyInteractor(presenter: component.TopUpByThirdPartyVC,
                                                     paymentStream: component.dependency.mutablePaymentStream,
                                                     authStream: component.dependency.authenticated,
                                                     mutableTopUpStream: component.mutableTopUpStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return TopUpByThirdPartyRouter(interactor: interactor, viewController: component.TopUpByThirdPartyVC)
    }
}
