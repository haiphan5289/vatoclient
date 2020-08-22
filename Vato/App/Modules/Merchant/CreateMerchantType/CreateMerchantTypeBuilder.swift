//  File name   : CreateMerchantTypeBuilder.swift
//
//  Author      : khoi tran
//  Created date: 10/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  ---
//-----------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol CreateMerchantTypeDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenStream: AuthenticatedStream {get}
    var merchantDataStream: MerchantDataStream { get }
}

final class CreateMerchantTypeComponent: Component<CreateMerchantTypeDependency> {
    /// Class's public properties.
    let CreateMerchantTypeVC: CreateMerchantTypeVC
    
    /// Class's constructor.
    init(dependency: CreateMerchantTypeDependency, CreateMerchantTypeVC: CreateMerchantTypeVC) {
        self.CreateMerchantTypeVC = CreateMerchantTypeVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}


extension CreateMerchantTypeComponent: CreateMerchantDetailDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenStream
    }
    
    var merchantDataStream: MerchantDataStream {
        return dependency.merchantDataStream
    }
    
}

// MARK: Builder
protocol CreateMerchantTypeBuildable: Buildable {
    func build(withListener listener: CreateMerchantTypeListener) -> CreateMerchantTypeRouting
}

final class CreateMerchantTypeBuilder: Builder<CreateMerchantTypeDependency>, CreateMerchantTypeBuildable {
    /// Class's constructor.
    override init(dependency: CreateMerchantTypeDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: CreateMerchantTypeBuildable's members
    func build(withListener listener: CreateMerchantTypeListener) -> CreateMerchantTypeRouting {
        let vc = CreateMerchantTypeVC()
        let component = CreateMerchantTypeComponent(dependency: dependency, CreateMerchantTypeVC: vc)

        let interactor = CreateMerchantTypeInteractor(presenter: component.CreateMerchantTypeVC,
                                                      authStream: component.dependency.authenStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        let createMerchantDetailBuilder = CreateMerchantDetailBuilder.init(dependency: component)

        return CreateMerchantTypeRouter(interactor: interactor, viewController: component.CreateMerchantTypeVC, createMerchantDetailBuildable: createMerchantDetailBuilder)
    }
}
