//  File name   : ProductMenuBuilder.swift
//
//  Author      : khoi tran
//  Created date: 12/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol ProductMenuDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ProductMenuComponent: Component<ProductMenuDependency> {
    /// Class's public properties.
    let ProductMenuVC: ProductMenuVC
    
    /// Class's constructor.
    init(dependency: ProductMenuDependency, ProductMenuVC: ProductMenuVC) {
        self.ProductMenuVC = ProductMenuVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ProductMenuBuildable: Buildable {
    func build(withListener listener: ProductMenuListener, product: DisplayProduct, basketItem: BasketStoreValueProtocol?, minValue: Int) -> ProductMenuRouting
}

final class ProductMenuBuilder: Builder<ProductMenuDependency>, ProductMenuBuildable {
    /// Class's constructor.
    override init(dependency: ProductMenuDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ProductMenuBuildable's members
    func build(withListener listener: ProductMenuListener, product: DisplayProduct, basketItem: BasketStoreValueProtocol?, minValue: Int) -> ProductMenuRouting {
        let vc = UIStoryboard(name: "ProductMenu", bundle: nil).instantiateViewController(withIdentifier: "ProductMenuVC") as! ProductMenuVC
        let component = ProductMenuComponent(dependency: dependency, ProductMenuVC: vc)

        let item = ProductMenuItem(basketItem: basketItem, product: product)
        let interactor = ProductMenuInteractor(presenter: component.ProductMenuVC, basketItem: item, minValue: minValue)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ProductMenuRouter(interactor: interactor, viewController: component.ProductMenuVC)
    }
}
