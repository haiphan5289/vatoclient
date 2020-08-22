//  File name   : ChangeTicketBuilder.swift
//
//  Author      : MacbookPro
//  Created date: 11/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ChangeTicketDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authStream: AuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class ChangeTicketComponent: Component<ChangeTicketDependency> {
    /// Class's public properties.
    let changeTicketVC: ChangeTicketVC
    
    /// Class's constructor.
    init(dependency: ChangeTicketDependency, changeTicketVC: ChangeTicketVC) {
        self.changeTicketVC = changeTicketVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
    var buyTicketStream: BuyTicketStreamImpl {
        return shared({
            let model = TicketInformation()
            return BuyTicketStreamImpl(with: model)
        })
    }
}

// MARK: Builder
protocol ChangeTicketBuildable: Buildable {
    func build(withListener listener: ChangeTicketListener, model: TicketHistoryType) -> ChangeTicketRouting
}

final class ChangeTicketBuilder: Builder<ChangeTicketDependency>, ChangeTicketBuildable {
    /// Class's constructor.
    override init(dependency: ChangeTicketDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ChangeTicketBuildable's members
    func build(withListener listener: ChangeTicketListener, model: TicketHistoryType) -> ChangeTicketRouting {
        let vc = UIStoryboard(name: "ChangeTicket", bundle: nil).instantiateViewController(withIdentifier: "ChangeTicket") as! ChangeTicketVC
        let component = ChangeTicketComponent(dependency: dependency, changeTicketVC: vc)

        let interactor = ChangeTicketInteractor(presenter: component.changeTicketVC,
                                                buyTicketStream: component.buyTicketStream, model: model)
        interactor.listener = listener

        let ticketTimeBuilder = TicketTimeBuilder(dependency: component)
        let ticketCalendarBuilder = TicketCalendarBuilder(dependency: component)
        let ticketBusStationBuilder = TicketBusStationBuilder(dependency: component)
        let seatPositionBuilder = SeatPositionBuilder(dependency: component)
        let ticketChooseDestinationBuilder = TicketChooseDestinationBuilder(dependency: component)
        let buyTicketPaymentBuilder = BuyTicketPaymentBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return ChangeTicketRouter(interactor: interactor,
                                  viewController: component.changeTicketVC,
                                  ticketTimeBuildable: ticketTimeBuilder,
                                  ticketCalendarBuildable: ticketCalendarBuilder,
                                  ticketChooseDestinationBuildable: ticketChooseDestinationBuilder,
                                  ticketBusStationBuildable: ticketBusStationBuilder,
                                  seatPositionBuildable: seatPositionBuilder,
                                  buyTicketPaymentBuildable: buyTicketPaymentBuilder)
    }
}
