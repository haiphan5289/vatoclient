//  File name   : MainMerchantBuilder.swift
//
//  Author      : khoi tran
//  Created date: 10/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol MainMerchantDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
}



final class MainMerchantComponent: Component<MainMerchantDependency> {
    /// Class's public properties.
    let MainMerchantVC: MainMerchantVC
    
    /// Class's constructor.
    init(dependency: MainMerchantDependency, MainMerchantVC: MainMerchantVC) {
        self.MainMerchantVC = MainMerchantVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
    
    var merchantStream: MerchantDataStreamImpl {
        return shared { MerchantDataStreamImpl() }
    }

}

// MARK: Builder
protocol MainMerchantBuildable: Buildable {
    func build(withListener listener: MainMerchantListener) -> MainMerchantRouting
}

final class MainMerchantBuilder: Builder<MainMerchantDependency>, MainMerchantBuildable {
    /// Class's constructor.
    override init(dependency: MainMerchantDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: MainMerchantBuildable's members
    func build(withListener listener: MainMerchantListener) -> MainMerchantRouting {
        let vc = MainMerchantVC()
        let component = MainMerchantComponent(dependency: dependency, MainMerchantVC: vc)

        let interactor = MainMerchantInteractor(presenter: component.MainMerchantVC, authStream: component.dependency.authenticatedStream, merchantDataStream: component.merchantStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        let merchantDetailBuilder = MerchantDetailBuilder.init(dependency: component)
        let createMerchantTypeBuilder = CreateMerchantTypeBuilder.init(dependency: component)
        
        return MainMerchantRouter(interactor: interactor,
                                  viewController: component.MainMerchantVC,
                                  merchantDetailBuildable: merchantDetailBuilder,
                                createMerchantTypeBuildable: createMerchantTypeBuilder)
    }
}
