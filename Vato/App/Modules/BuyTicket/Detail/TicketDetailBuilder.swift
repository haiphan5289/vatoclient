//  File name   : TicketDetailBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TicketDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class TicketDetailComponent: Component<TicketDetailDependency> {
    /// Class's public properties.
    let TicketDetailVC: TicketDetailVC
    
    /// Class's constructor.
    init(dependency: TicketDetailDependency, TicketDetailVC: TicketDetailVC) {
        self.TicketDetailVC = TicketDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketDetailBuildable: Buildable {
    func build(withListener listener: TicketDetailListener) -> TicketDetailRouting
}

final class TicketDetailBuilder: Builder<TicketDetailDependency>, TicketDetailBuildable {
    /// Class's constructor.
    override init(dependency: TicketDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketDetailBuildable's members
    func build(withListener listener: TicketDetailListener) -> TicketDetailRouting {
        let vc = TicketDetailVC()
        let component = TicketDetailComponent(dependency: dependency, TicketDetailVC: vc)

        let interactor = TicketDetailInteractor(presenter: component.TicketDetailVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return TicketDetailRouter(interactor: interactor, viewController: component.TicketDetailVC)
    }
}
