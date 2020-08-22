//  File name   : TicketUserInfomationBuilder.swift
//
//  Author      : vato.
//  Created date: 10/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TicketUserInfomationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
    var buyTicketStream: BuyTicketStreamImpl { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class TicketUserInfomationComponent: Component<TicketUserInfomationDependency> {
    /// Class's public properties.
    let TicketUserInfomationVC: TicketUserInfomationVC
    
    /// Class's constructor.
    init(dependency: TicketUserInfomationDependency, TicketUserInfomationVC: TicketUserInfomationVC) {
        self.TicketUserInfomationVC = TicketUserInfomationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketUserInfomationBuildable: Buildable {
    func build(withListener listener: TicketUserInfomationListener) -> TicketUserInfomationRouting
}

final class TicketUserInfomationBuilder: Builder<TicketUserInfomationDependency>, TicketUserInfomationBuildable {
    /// Class's constructor.
    override init(dependency: TicketUserInfomationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketUserInfomationBuildable's members
    func build(withListener listener: TicketUserInfomationListener) -> TicketUserInfomationRouting {
        let ticketUserInfomationVC = TicketUserInfomationVC()
        
        let component = TicketUserInfomationComponent(dependency: dependency, TicketUserInfomationVC: ticketUserInfomationVC)

        let interactor = TicketUserInfomationInteractor(presenter: component.TicketUserInfomationVC,
                                                        profileStream: dependency.mutableProfile,
                                                        buyTicketStream: dependency.buyTicketStream,
                                                        authenticatedStream: dependency.authenticatedStream)
        interactor.listener = listener

        let ticketBusStationBuilder = TicketBusStationBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return TicketUserInfomationRouter(interactor: interactor,
                                          viewController: component.TicketUserInfomationVC,
                                          ticketBusStationBuildable: ticketBusStationBuilder)
    }
}

