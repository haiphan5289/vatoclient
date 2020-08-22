//  File name   : SeatPositionBuilder.swift
//
//  Author      : vato.
//  Created date: 10/8/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

struct ChooseSeatParam {
    var routeId: Int
    var carBookingId: Int
    var kind: String
    var departureDate: String
    var departureTime: String
    var pricePerTicket: Double
    var promotion: PromotionTicket?
    var finalPrice: Double?
}

// MARK: Dependency tree
protocol SeatPositionDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var buyTicketStream: BuyTicketStreamImpl { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class SeatPositionComponent: Component<SeatPositionDependency> {
    /// Class's public properties.
    let SeatPositionVC: SeatPositionVC
    
    /// Class's constructor.
    init(dependency: SeatPositionDependency, SeatPositionVC: SeatPositionVC) {
        self.SeatPositionVC = SeatPositionVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol SeatPositionBuildable: Buildable {
    func build(withListener listener: SeatPositionListener, seatParam: ChooseSeatParam, streamType: BuslineStreamType, type: TicketRoundTripType) -> SeatPositionRouting
}

final class SeatPositionBuilder: Builder<SeatPositionDependency>, SeatPositionBuildable {
    /// Class's constructor.
    override init(dependency: SeatPositionDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: SeatPositionBuildable's members
    func build(withListener listener: SeatPositionListener,
               seatParam: ChooseSeatParam,
               streamType: BuslineStreamType, type: TicketRoundTripType) -> SeatPositionRouting {
        let storyboard = UIStoryboard(name: "SeatPosition", bundle: nil)
        var ticketSeatVC = SeatPositionVC()
        if let vc = storyboard.instantiateViewController(withIdentifier: "SeatPositionVC") as? SeatPositionVC {
            ticketSeatVC = vc
        }
        
        ticketSeatVC.seatParam = seatParam
        
        let component = SeatPositionComponent(dependency: dependency, SeatPositionVC: ticketSeatVC)
        let interactor = SeatPositionInteractor(presenter: component.SeatPositionVC,
                                                authStream: component.dependency.authenticatedStream,
                                                buyTicketStream: dependency.buyTicketStream,
                                                mutableProfile: dependency.mutableProfile,
                                                streamType: streamType, type: type)
        interactor.listener = listener

        let confirmBuyTicketBuilder = ConfirmBuyTicketBuilder(dependency: component)
        let buyTicketPaymentBuilder = BuyTicketPaymentBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return SeatPositionRouter(interactor: interactor,
                                  viewController: component.SeatPositionVC,
                                  confirmBuyTicketBuildable: confirmBuyTicketBuilder, buyTicketPaymentBuildable: buyTicketPaymentBuilder)
    }
}
