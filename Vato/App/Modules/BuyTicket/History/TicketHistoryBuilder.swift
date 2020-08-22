//  File name   : TicketHistoryBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol TicketHistoryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authStream: AuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class TicketHistoryComponent: Component<TicketHistoryDependency> {
    /// Class's public properties.
    let ticketHistoryVC: TicketHistoryVC
    
    /// Class's constructor.
    init(dependency: TicketHistoryDependency,
         ticketHistoryVC: TicketHistoryVC) {
        self.ticketHistoryVC = ticketHistoryVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketHistoryBuildable: Buildable {
    func build(withListener listener: TicketHistoryListener) -> TicketHistoryRouting
}

final class TicketHistoryBuilder: Builder<TicketHistoryDependency>, TicketHistoryBuildable {
    /// Class's constructor.
    override init(dependency: TicketHistoryDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketHistoryBuildable's members
    func build(withListener listener: TicketHistoryListener) -> TicketHistoryRouting {
        guard let vc = UIStoryboard(name: "TicketHistory", bundle: nil).instantiateViewController(withIdentifier: TicketHistoryVC.identifier) as? TicketHistoryVC else {
            fatalError("Please Implement")
        }
        let component = TicketHistoryComponent(dependency: dependency, ticketHistoryVC: vc)

        let interactor = TicketHistoryInteractor(presenter: component.ticketHistoryVC, authStream: component.dependency.authStream, mutableProfileStream: component.dependency.mutableProfile)
        interactor.listener = listener

        let changeTicketBuilder = ChangeTicketBuilder(dependency: component)
        let cancelTicketBuilder = CancelTicketBuilder(dependency: component)
        let ticketHistoryDetailBuilder = TicketHistoryDetailBuilder(dependency: component)
        let ticketRouteDetail = TicketDetailRouteBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return TicketHistoryRouter(interactor: interactor,
                                   viewController: component.ticketHistoryVC,
                                   cancelTicketBuildable: cancelTicketBuilder,
                                   ticketHistoryDetailBuildable: ticketHistoryDetailBuilder,
                                   changeTicketBuildable: changeTicketBuilder,
                                   ticketDetailRouteBuildable: ticketRouteDetail)
    }
}
