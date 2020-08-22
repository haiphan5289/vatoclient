//  File name   : MerchantDetailBuilder.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol MerchantDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var merchantDataStream: MerchantDataStream { get }
}

final class MerchantDetailComponent: Component<MerchantDetailDependency> {
    /// Class's public properties.
    let MerchantDetailVC: MerchantDetailVC
    
    /// Class's constructor.
    init(dependency: MerchantDetailDependency, MerchantDetailVC: MerchantDetailVC) {
        self.MerchantDetailVC = MerchantDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol MerchantDetailBuildable: Buildable {
    func build(withListener listener: MerchantDetailListener) -> MerchantDetailRouting
}

final class MerchantDetailBuilder: Builder<MerchantDetailDependency>, MerchantDetailBuildable {
    /// Class's constructor.
    override init(dependency: MerchantDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: MerchantDetailBuildable's members
    func build(withListener listener: MerchantDetailListener) -> MerchantDetailRouting {
        let storyboard = UIStoryboard(name: "MerchantDetail", bundle: nil)
        var merchantDetailVC = MerchantDetailVC()
        if let vc = storyboard.instantiateViewController(withIdentifier: "MerchantDetailVC") as? MerchantDetailVC {
            merchantDetailVC = vc
        }
        
        
        let component = MerchantDetailComponent(dependency: dependency, MerchantDetailVC: merchantDetailVC)

        let interactor = MerchantDetailInteractor(presenter: component.MerchantDetailVC, authStream: component.dependency.authenticatedStream, merchantStream: component.dependency.merchantDataStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let addStroreBuilder = AddStoreBuilder.init(dependency: component)
        let createMerchantDetailBuilder = CreateMerchantDetailBuilder.init(dependency: component)
        let storeDetailBuilder = StoreDetailBuilder.init(dependency: component)
        
        return MerchantDetailRouter(interactor: interactor, viewController: component.MerchantDetailVC, addStroreBuildable: addStroreBuilder, createMerchantDetailBuildable: createMerchantDetailBuilder, storeDetailBuildable: storeDetailBuilder)
    }
}
