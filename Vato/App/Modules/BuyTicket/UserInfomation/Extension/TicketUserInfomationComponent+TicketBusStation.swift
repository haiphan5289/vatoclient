//  File name   : TicketUserInfomationComponent+TicketBusStation.swift
//
//  Author      : vato.
//  Created date: 10/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketUserInfomation to provide for the TicketBusStation scope.
// todo: Update TicketUserInfomationDependency protocol to inherit this protocol.
protocol TicketUserInfomationDependencyTicketBusStation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketUserInfomation to provide dependencies
    // for the TicketBusStation scope.
}

extension TicketUserInfomationComponent: TicketBusStationDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var buyTicketStream: BuyTicketStreamImpl {
        return dependency.buyTicketStream
    }
    
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
