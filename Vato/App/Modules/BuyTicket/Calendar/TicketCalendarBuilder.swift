//  File name   : TicketCalendarBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol TicketCalendarDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class TicketCalendarComponent: Component<TicketCalendarDependency> {
    /// Class's public properties.
    let TicketCalendarVC: TicketCalendarVC
    
    /// Class's constructor.
    init(dependency: TicketCalendarDependency, TicketCalendarVC: TicketCalendarVC) {
        self.TicketCalendarVC = TicketCalendarVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketCalendarBuildable: Buildable {
    func build(withListener listener: TicketCalendarListener, dateSelected: Date?, ticketType: TicketRoundTripType) -> TicketCalendarRouting
}

final class TicketCalendarBuilder: Builder<TicketCalendarDependency>, TicketCalendarBuildable {
    /// Class's constructor.
    override init(dependency: TicketCalendarDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketCalendarBuildable's members
    func build(withListener listener: TicketCalendarListener,
               dateSelected: Date?, ticketType: TicketRoundTripType) -> TicketCalendarRouting {
        let vc = TicketCalendarVC(nibName: TicketCalendarVC.identifier, bundle: nil)
        let component = TicketCalendarComponent(dependency: dependency, TicketCalendarVC: vc)

        let interactor = TicketCalendarInteractor(presenter: component.TicketCalendarVC,
                                                  dateSelected: dateSelected, ticketType: ticketType)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return TicketCalendarRouter(interactor: interactor, viewController: component.TicketCalendarVC)
    }
}
