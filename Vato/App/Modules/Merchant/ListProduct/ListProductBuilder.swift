//  File name   : ListProductBuilder.swift
//
//  Author      : khoi tran
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ListProductDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenStream: AuthenticatedStream {get}
    var merchantDataStream: MerchantDataStream { get }
}

final class ListProductComponent: Component<ListProductDependency> {
    /// Class's public properties.
    let ListProductVC: ListProductVC
    
    /// Class's constructor.
    init(dependency: ListProductDependency, ListProductVC: ListProductVC) {
        self.ListProductVC = ListProductVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ListProductBuildable: Buildable {
    func build(withListener listener: ListProductListener) -> ListProductRouting
}

final class ListProductBuilder: Builder<ListProductDependency>, ListProductBuildable {
    /// Class's constructor.
    override init(dependency: ListProductDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ListProductBuildable's members
    func build(withListener listener: ListProductListener) -> ListProductRouting {
        let vc = ListProductVC(nibName: ListProductVC.identifier, bundle: nil)
        let component = ListProductComponent(dependency: dependency, ListProductVC: vc)

        let interactor = ListProductInteractor(presenter: component.ListProductVC, authStream: component.dependency.authenStream, merchantStream: component.dependency.merchantDataStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let addProductBuilder = AddProductBuilder.init(dependency: component)

        return ListProductRouter(interactor: interactor, viewController: component.ListProductVC, addProductBuildable: addProductBuilder)
    }
}
