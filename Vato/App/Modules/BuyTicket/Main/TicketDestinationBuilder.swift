//  File name   : TicketDestinationBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

enum TicketDestinationAction {
    case history
    case select(item: BusLineHomeItem)
}

// MARK: Dependency tree
protocol TicketDestinationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authStream: AuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class TicketDestinationComponent: Component<TicketDestinationDependency> {
    /// Class's public properties.
    let ticketDestinationVC: TicketDestinationVC
    
    /// Class's constructor.
    init(dependency: TicketDestinationDependency, ticketDestinationVC: TicketDestinationVC) {
        self.ticketDestinationVC = ticketDestinationVC
        super.init(dependency: dependency)
    }
    
    var buyTicketStream: BuyTicketStreamImpl {
        return shared({
            let model = TicketInformation()
            return BuyTicketStreamImpl(with: model)
        })
    }
    
//    var mutablePaymentStream: MutablePaymentStream {
//        return shared { PaymentStreamImpl() }
//    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketDestinationBuildable: Buildable {
    func build(withListener listener: TicketDestinationListener, action: TicketDestinationAction?) -> TicketDestinationRouting
}

final class TicketDestinationBuilder: Builder<TicketDestinationDependency>, TicketDestinationBuildable {
    /// Class's constructor.
    override init(dependency: TicketDestinationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketDestinationBuildable's members
    func build(withListener listener: TicketDestinationListener, action: TicketDestinationAction?) -> TicketDestinationRouting {
        let storyboard = UIStoryboard(name: "MainBuyTicket", bundle: nil)
        var ticketDestinationVC = TicketDestinationVC()
        if let vc = storyboard.instantiateViewController(withIdentifier: "TicketDestinationVC") as? TicketDestinationVC {
            ticketDestinationVC = vc
        }

        let component = TicketDestinationComponent(dependency: dependency, ticketDestinationVC: ticketDestinationVC)

        let interactor = TicketDestinationInteractor(presenter: component.ticketDestinationVC, component: component, action: action)
        interactor.listener = listener

        let ticketChooseDestinationBuilder = TicketChooseDestinationBuilder(dependency: component)
        let ticketCalendarBuilder = TicketCalendarBuilder(dependency: component)
        let ticketUserInfomationBuilder = TicketUserInfomationBuilder(dependency: component)
        let ticketHistoryBuilder = TicketHistoryBuilder(dependency: component)
        let ticketHistoryDetailBuilder = TicketHistoryDetailBuilder(dependency: component)
        let ticketFillInformationBuilder = TicketFillInformationBuilder(dependency: component)
        let ticketMainFillInformationBuilder = TicketMainFillInformationBuilder(dependency: component)
        let ticketDetailRouteBuilder = TicketDetailRouteBuilder(dependency: component)
        return TicketDestinationRouter(interactor: interactor,
                                       viewController: component.ticketDestinationVC ,
                                       ticketChooseDestinationBuildable: ticketChooseDestinationBuilder,
                                       ticketCalendarBuildable: ticketCalendarBuilder,
                                       ticketUserInfomationBuildable: ticketUserInfomationBuilder,
                                       ticketHistoryBuildable: ticketHistoryBuilder,
                                       ticketHistoryDetailBuildable: ticketHistoryDetailBuilder,
                                       ticketFillInformationBuildable: ticketFillInformationBuilder,
                                       ticketMainFillInformationBuildable: ticketMainFillInformationBuilder,
                                       ticketDetailRouteBuildable: ticketDetailRouteBuilder)
    }
}
