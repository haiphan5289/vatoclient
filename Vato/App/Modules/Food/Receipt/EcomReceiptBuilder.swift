//  File name   : EcomReceiptBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol EcomReceiptDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class EcomReceiptComponent: Component<EcomReceiptDependency> {
    /// Class's public properties.
    let EcomReceiptVC: EcomReceiptVC
    
    /// Class's constructor.
    init(dependency: EcomReceiptDependency, EcomReceiptVC: EcomReceiptVC) {
        self.EcomReceiptVC = EcomReceiptVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol EcomReceiptBuildable: Buildable {
    func build(withListener listener: EcomReceiptListener, order: SalesOrder) -> EcomReceiptRouting
}

final class EcomReceiptBuilder: Builder<EcomReceiptDependency>, EcomReceiptBuildable {
    /// Class's constructor.
    override init(dependency: EcomReceiptDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: EcomReceiptBuildable's members
    func build(withListener listener: EcomReceiptListener, order: SalesOrder) -> EcomReceiptRouting {
        let vc = EcomReceiptVC()
        let component = EcomReceiptComponent(dependency: dependency, EcomReceiptVC: vc)

        let interactor = EcomReceiptInteractor(presenter: component.EcomReceiptVC, order: order)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return EcomReceiptRouter(interactor: interactor, viewController: component.EcomReceiptVC)
    }
}
