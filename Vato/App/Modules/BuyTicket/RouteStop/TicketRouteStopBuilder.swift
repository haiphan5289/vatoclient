//  File name   : TicketRouteStopBuilder.swift
//
//  Author      : khoi tran
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol TicketRouteStopDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class TicketRouteStopComponent: Component<TicketRouteStopDependency> {
    /// Class's public properties.
    let TicketRouteStopVC: TicketRouteStopVC
    
    /// Class's constructor.
    init(dependency: TicketRouteStopDependency, TicketRouteStopVC: TicketRouteStopVC) {
        self.TicketRouteStopVC = TicketRouteStopVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketRouteStopBuildable: Buildable {
    func build(withListener listener: TicketRouteStopListener, routeStopParam: ChooseRouteStopParam?, currentRouteStopId: Int?, listRouteStop: [RouteStop]?) -> TicketRouteStopRouting
}

final class TicketRouteStopBuilder: Builder<TicketRouteStopDependency>, TicketRouteStopBuildable {
    /// Class's constructor.
    override init(dependency: TicketRouteStopDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketRouteStopBuildable's members
    func build(withListener listener: TicketRouteStopListener, routeStopParam: ChooseRouteStopParam?, currentRouteStopId: Int?, listRouteStop: [RouteStop]?) -> TicketRouteStopRouting {
        let vc = TicketRouteStopVC(nibName: TicketRouteStopVC.identifier, bundle: nil)
        let component = TicketRouteStopComponent(dependency: dependency, TicketRouteStopVC: vc)

        let interactor = TicketRouteStopInteractor(presenter: component.TicketRouteStopVC, routeStopParam: routeStopParam, currentRouteStopId: currentRouteStopId, listRouteStop: listRouteStop)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return TicketRouteStopRouter(interactor: interactor, viewController: component.TicketRouteStopVC)
    }
}
