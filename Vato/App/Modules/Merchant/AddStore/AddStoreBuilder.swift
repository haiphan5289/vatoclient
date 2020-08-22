//  File name   : AddStoreBuilder.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol AddStoreDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var merchantDataStream: MerchantDataStream { get }
}

final class AddStoreComponent: Component<AddStoreDependency> {
    /// Class's public properties.
    let AddStoreVC: AddStoreVC
    
    /// Class's constructor.
    init(dependency: AddStoreDependency, AddStoreVC: AddStoreVC) {
        self.AddStoreVC = AddStoreVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol AddStoreBuildable: Buildable {
    func build(withListener listener: AddStoreListener) -> AddStoreRouting
}

final class AddStoreBuilder: Builder<AddStoreDependency>, AddStoreBuildable {
    /// Class's constructor.
    override init(dependency: AddStoreDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: AddStoreBuildable's members
    func build(withListener listener: AddStoreListener) -> AddStoreRouting {

        let addStoreVC = AddStoreVC()    
 
        let component = AddStoreComponent(dependency: dependency, AddStoreVC: addStoreVC)

        let interactor = AddStoreInteractor(presenter: component.AddStoreVC, authStream: component.dependency.authenticatedStream, merchantStream: component.dependency.merchantDataStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let searchDeliveryBuildable = SearchDeliveryBuilder(dependency: component)
        
        return AddStoreRouter(interactor: interactor, viewController: component.AddStoreVC, searchDeliveryBuildable: searchDeliveryBuildable)
    }
}
