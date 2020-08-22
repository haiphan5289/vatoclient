//  File name   : TicketHistoryDetailBuilder.swift
//
//  Author      : vato.
//  Created date: 10/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TicketHistoryDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authStream: AuthenticatedStream { get }
    var profileStream: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class TicketHistoryDetailComponent: Component<TicketHistoryDetailDependency> {
    /// Class's public properties.
    let TicketHistoryDetailVC: TicketHistoryDetailVC
    
    /// Class's constructor.
    init(dependency: TicketHistoryDetailDependency, TicketHistoryDetailVC: TicketHistoryDetailVC) {
        self.TicketHistoryDetailVC = TicketHistoryDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketHistoryDetailBuildable: Buildable {
    func build(withListener listener: TicketHistoryDetailListener, ticketHistoryType: TicketHistoryType?) -> TicketHistoryDetailRouting
}

final class TicketHistoryDetailBuilder: Builder<TicketHistoryDetailDependency>, TicketHistoryDetailBuildable {
    /// Class's constructor.
    override init(dependency: TicketHistoryDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketHistoryDetailBuildable's members
    func build(withListener listener: TicketHistoryDetailListener, ticketHistoryType: TicketHistoryType?) -> TicketHistoryDetailRouting {
        guard let vc = UIStoryboard(name: "TicketHistory", bundle: nil).instantiateViewController(withIdentifier: TicketHistoryDetailVC.identifier) as? TicketHistoryDetailVC else {
            fatalError("Please Implement")
        }
        let component = TicketHistoryDetailComponent(dependency: dependency, TicketHistoryDetailVC: vc)

        let interactor = TicketHistoryDetailInteractor(presenter: component.TicketHistoryDetailVC,
                                                       ticketHistoryType: ticketHistoryType,
                                                       authStream: dependency.authStream,
                                                       profileStream: dependency.profileStream)
        interactor.listener = listener

        let cancelTicketBuilder = CancelTicketBuilder(dependency: component)
        let changeTicketBuilder = ChangeTicketBuilder(dependency: component)
        let ticketRouteDetail = TicketDetailRouteBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        return TicketHistoryDetailRouter(interactor: interactor,
                                         viewController: component.TicketHistoryDetailVC,
                                         cancelTicketBuildable: cancelTicketBuilder,
                                         changeTicketBuildable: changeTicketBuilder,
                                         ticketDetailRouteBuildable: ticketRouteDetail)
    }
}
