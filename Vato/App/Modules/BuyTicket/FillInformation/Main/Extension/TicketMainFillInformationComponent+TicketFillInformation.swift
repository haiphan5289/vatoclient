//  File name   : TicketMainFillInformationComponent+TicketFillInformation.swift
//
//  Author      : khoi tran
//  Created date: 5/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketMainFillInformation to provide for the TicketFillInformation scope.
// todo: Update TicketMainFillInformationDependency protocol to inherit this protocol.
protocol TicketMainFillInformationDependencyTicketFillInformation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketMainFillInformation to provide dependencies
    // for the TicketFillInformation scope.
}

extension TicketMainFillInformationComponent: TicketFillInformationDependency {
    var buyTicketStream: BuyTicketStreamImpl {
        return dependency.buyTicketStream
    }
    
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    var authStream: AuthenticatedStream {
        return dependency.authStream
    }
    

    // todo: Implement properties to provide for TicketFillInformation scope.
}
