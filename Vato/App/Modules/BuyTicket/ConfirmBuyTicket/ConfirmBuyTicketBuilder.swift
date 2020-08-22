//  File name   : ConfirmBuyTicketBuilder.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ConfirmBuyTicketDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var buyTicketStream: BuyTicketStreamImpl { get }
    var authenticatedStream: AuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class ConfirmBuyTicketComponent: Component<ConfirmBuyTicketDependency> {
    /// Class's public properties.
    let confirmBuyTicketVC: ConfirmBuyTicketVC
    
    /// Class's constructor.
    init(dependency: ConfirmBuyTicketDependency, ConfirmBuyTicketVC: ConfirmBuyTicketVC) {
        self.confirmBuyTicketVC = ConfirmBuyTicketVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ConfirmBuyTicketBuildable: Buildable {
    func build(withListener listener: ConfirmBuyTicketListener) -> ConfirmBuyTicketRouting
}

final class ConfirmBuyTicketBuilder: Builder<ConfirmBuyTicketDependency>, ConfirmBuyTicketBuildable {
    /// Class's constructor.
    override init(dependency: ConfirmBuyTicketDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ConfirmBuyTicketBuildable's members
    func build(withListener listener: ConfirmBuyTicketListener) -> ConfirmBuyTicketRouting {
        let storyboard = UIStoryboard(name: "ConfirmBuyTicket", bundle: nil)
        var confirmBuyTicketVC = ConfirmBuyTicketVC()
        if let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmBuyTicketVC") as? ConfirmBuyTicketVC {
            confirmBuyTicketVC = vc
        }
        let component = ConfirmBuyTicketComponent(dependency: dependency, ConfirmBuyTicketVC: confirmBuyTicketVC)

        let interactor = ConfirmBuyTicketInteractor(presenter: component.confirmBuyTicketVC,
                                                    buyTicketStream: dependency.buyTicketStream)
        interactor.listener = listener

        let buyTicketPaymentBuilder = BuyTicketPaymentBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        let ticketCalendarBuilder = TicketCalendarBuilder(dependency: component)
        let ticketTimeBuilder = TicketTimeBuilder(dependency: component)
        let seatPositionBuilder = SeatPositionBuilder(dependency: component)
        let ticketBusStationBuilder = TicketBusStationBuilder(dependency: component)
        
        
        return ConfirmBuyTicketRouter(interactor: interactor,
                                      viewController: component.confirmBuyTicketVC,
                                      buyTicketPaymentBuildable: buyTicketPaymentBuilder,
                                      ticketCalendarBuildable: ticketCalendarBuilder,
                                      ticketTimeBuildable: ticketTimeBuilder,
                                      seatPositionBuildable: seatPositionBuilder,
                                      ticketBusStationBuildable: ticketBusStationBuilder)
    }
}
