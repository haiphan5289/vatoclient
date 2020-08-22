//  File name   : StoreTrackingBuilder.swift
//
//  Author      : khoi tran
//  Created date: 12/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol StoreTrackingDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var storeStream: MutableStoreStream? { get }
    var trackingProfile: ProfileStream { get }
}

final class StoreTrackingComponent: Component<StoreTrackingDependency> {
    /// Class's public properties.
    let StoreTrackingVC: StoreTrackingVC
    
    /// Class's constructor.
    init(dependency: StoreTrackingDependency, StoreTrackingVC: StoreTrackingVC) {
        self.StoreTrackingVC = StoreTrackingVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
    var mutableChatStream: MutableChatStream {
        return shared { ChatStreamImpl(with: nil) }
    }
}

// MARK: Builder
protocol StoreTrackingBuildable: Buildable {
    func build(withListener listener: StoreTrackingListener, order: SalesOrder?, id: String?) -> StoreTrackingRouting
}

final class StoreTrackingBuilder: Builder<StoreTrackingDependency>, StoreTrackingBuildable {
    /// Class's constructor.
    override init(dependency: StoreTrackingDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: StoreTrackingBuildable's members
    func build(withListener listener: StoreTrackingListener, order: SalesOrder?, id: String?) -> StoreTrackingRouting {
        let vc = StoreTrackingVC(nibName: StoreTrackingVC.identifier, bundle: nil)
        let component = StoreTrackingComponent(dependency: dependency, StoreTrackingVC: vc)

        let interactor = StoreTrackingInteractor(presenter: component.StoreTrackingVC, order: order, authenticated: component.dependency.authenticated, mutableStoreStream: component.dependency.storeStream, orderId: id, mutableChatStream: component.mutableChatStream, profile: component.dependency.trackingProfile)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let chatBuilder = ChatBuilder(dependency: component)
        return StoreTrackingRouter(interactor: interactor, viewController: component.StoreTrackingVC, chatBuildable: chatBuilder)
    }
}
