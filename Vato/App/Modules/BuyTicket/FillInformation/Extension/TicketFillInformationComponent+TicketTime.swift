//  File name   : TicketFillInformationComponent+TicketTime.swift
//
//  Author      : khoi tran
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketFillInformation to provide for the TicketTime scope.
// todo: Update TicketFillInformationDependency protocol to inherit this protocol.
protocol TicketFillInformationDependencyTicketTime: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketFillInformation to provide dependencies
    // for the TicketTime scope.
}

extension TicketFillInformationComponent: TicketTimeDependency {
    var authStream: AuthenticatedStream {
        return dependency.authStream
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
    

    // todo: Implement properties to provide for TicketTime scope.
}
