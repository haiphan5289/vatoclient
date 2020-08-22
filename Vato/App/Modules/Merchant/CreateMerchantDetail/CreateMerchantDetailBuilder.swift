//  File name   : CreateMerchantDetailBuilder.swift
//
//  Author      : khoi tran
//  Created date: 10/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol CreateMerchantDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var merchantDataStream: MerchantDataStream { get }
}

final class CreateMerchantDetailComponent: Component<CreateMerchantDetailDependency> {
    /// Class's public properties.
    let CreateMerchantDetailVC: CreateMerchantDetailVC
    
    /// Class's constructor.
    init(dependency: CreateMerchantDetailDependency, CreateMerchantDetailVC: CreateMerchantDetailVC) {
        self.CreateMerchantDetailVC = CreateMerchantDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol CreateMerchantDetailBuildable: Buildable {
    func build(withListener listener: CreateMerchantDetailListener, category: MerchantCategory?) -> CreateMerchantDetailRouting
}

final class CreateMerchantDetailBuilder: Builder<CreateMerchantDetailDependency>, CreateMerchantDetailBuildable {
    /// Class's constructor.
    override init(dependency: CreateMerchantDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: CreateMerchantDetailBuildable's members
    func build(withListener listener: CreateMerchantDetailListener, category: MerchantCategory?) -> CreateMerchantDetailRouting {
        let vc = CreateMerchantDetailVC()
        let component = CreateMerchantDetailComponent(dependency: dependency, CreateMerchantDetailVC: vc)

        let interactor = CreateMerchantDetailInteractor(presenter: component.CreateMerchantDetailVC, merchantStream: component.dependency.merchantDataStream, authStream: component.dependency.authenticatedStream, category: category)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return CreateMerchantDetailRouter(interactor: interactor, viewController: component.CreateMerchantDetailVC)
    }
}
