//  File name   : SearchDeliveryBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import VatoNetwork

// MARK: Dependency tree
protocol SearchDeliveryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
}

final class SearchDeliveryComponent: Component<SearchDeliveryDependency> {
    /// Class's public properties.
    let SearchDeliveryVC: SearchDeliveryVC
    
    /// Class's constructor.
    init(dependency: SearchDeliveryDependency, SearchDeliveryVC: SearchDeliveryVC) {
        self.SearchDeliveryVC = SearchDeliveryVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol SearchDeliveryBuildable: Buildable {
    func build(withListener listener: SearchDeliveryListener,
               placeModel: AddressProtocol?,
               searchType: SearchType) -> SearchDeliveryRouting
}

final class SearchDeliveryBuilder: Builder<SearchDeliveryDependency>, SearchDeliveryBuildable {
    /// Class's constructor.
    override init(dependency: SearchDeliveryDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: SearchDeliveryBuildable's members
    func build(withListener listener: SearchDeliveryListener,
               placeModel: AddressProtocol?,
               searchType: SearchType) -> SearchDeliveryRouting {
        let vc = SearchDeliveryVC()
        let component = SearchDeliveryComponent(dependency: dependency, SearchDeliveryVC: vc)

        let interactor = SearchDeliveryInteractor(presenter: component.SearchDeliveryVC,
                                                  authStream: component.dependency.authenticatedStream,
                                                  placeModel: placeModel, searchType: searchType)
        
        let pinAddressBuilder = PinAddressBuilder(dependency: component)
        interactor.listener = listener
        // todo: Create builder modules builders and inject into router here.
        
        return SearchDeliveryRouter(interactor: interactor,
                                    viewController: component.SearchDeliveryVC,
                                    pinAddressBuildable: pinAddressBuilder)
    }
}
