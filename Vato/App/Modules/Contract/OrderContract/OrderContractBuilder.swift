//  File name   : OrderContractBuilder.swift
//
//  Author      : Phan Hai
//  Created date: 18/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol OrderContractDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class OrderContractComponent: Component<OrderContractDependency> {
    /// Class's public properties.
    let OrderContractVC: OrderContractVC
    
    /// Class's constructor.
    init(dependency: OrderContractDependency, OrderContractVC: OrderContractVC) {
        self.OrderContractVC = OrderContractVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol OrderContractBuildable: Buildable {
    func build(withListener listener: OrderContractListener) -> OrderContractRouting
}

final class OrderContractBuilder: Builder<OrderContractDependency>, OrderContractBuildable {
    /// Class's constructor.
    override init(dependency: OrderContractDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: OrderContractBuildable's members
    func build(withListener listener: OrderContractListener) -> OrderContractRouting {
        let vc = OrderContractVC(nibName: OrderContractVC.identifier, bundle: nil)
        let component = OrderContractComponent(dependency: dependency, OrderContractVC: vc)

        let interactor = OrderContractInteractor(presenter: component.OrderContractVC)
        interactor.listener = listener
        
        let chatOCBuildable = ChatOrderContractBuilder(dependency: component)

        // todo: Create builder modules builders and inject into router here.
        
        return OrderContractRouter(interactor: interactor,
                                   viewController: component.OrderContractVC,
                                   chatOCBuildable: chatOCBuildable)
    }
}
