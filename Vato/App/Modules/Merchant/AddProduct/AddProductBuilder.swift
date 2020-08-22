//  File name   : AddProductBuilder.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol AddProductDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var merchantDataStream: MerchantDataStream { get }
}

final class AddProductComponent: Component<AddProductDependency> {
    /// Class's public properties.
    let AddProductVC: AddProductVC
    
    /// Class's constructor.
    init(dependency: AddProductDependency, AddProductVC: AddProductVC) {
        self.AddProductVC = AddProductVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol AddProductBuildable: Buildable {
    func build(withListener listener: AddProductListener, currentProduct: DisplayProduct?) -> AddProductRouting
}

final class AddProductBuilder: Builder<AddProductDependency>, AddProductBuildable {
    /// Class's constructor.
    override init(dependency: AddProductDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: AddProductBuildable's members
    func build(withListener listener: AddProductListener, currentProduct: DisplayProduct?) -> AddProductRouting {
        let vc = AddProductVC(nibName: AddProductVC.identifier, bundle: nil)
        let component = AddProductComponent(dependency: dependency, AddProductVC: vc)

        let interactor = AddProductInteractor(presenter: component.AddProductVC, authStream: component.dependency.authenticatedStream, merchantStream: component.dependency.merchantDataStream, currentProduct: currentProduct)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let addProductTypeBuildable = AddProductTypeBuilder.init(dependency: component)
        return AddProductRouter(interactor: interactor, viewController: component.AddProductVC, addProductTypeBuildable: addProductTypeBuildable)
    }
}
