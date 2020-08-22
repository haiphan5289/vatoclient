//  File name   : TicketDetailRouteBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 5/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol TicketDetailRouteDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class TicketDetailRouteComponent: Component<TicketDetailRouteDependency> {
    /// Class's public properties.
    let TicketDetailRouteVC: TicketDetailRouteVC
    
    /// Class's constructor.
    init(dependency: TicketDetailRouteDependency, TicketDetailRouteVC: TicketDetailRouteVC) {
        self.TicketDetailRouteVC = TicketDetailRouteVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketDetailRouteBuildable: Buildable {
    func build(withListener listener: TicketDetailRouteListener, item: DetailRouteInfo) -> TicketDetailRouteRouting
}

final class TicketDetailRouteBuilder: Builder<TicketDetailRouteDependency>, TicketDetailRouteBuildable {
    /// Class's constructor.
    override init(dependency: TicketDetailRouteDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketDetailRouteBuildable's members
    func build(withListener listener: TicketDetailRouteListener, item: DetailRouteInfo) -> TicketDetailRouteRouting {
        let vc = TicketDetailRouteVC(nibName: TicketDetailRouteVC.identifier, bundle: nil)
        let component = TicketDetailRouteComponent(dependency: dependency, TicketDetailRouteVC: vc)

        let interactor = TicketDetailRouteInteractor(presenter: component.TicketDetailRouteVC, itemDetail: item)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return TicketDetailRouteRouter(interactor: interactor, viewController: component.TicketDetailRouteVC)
    }
}
