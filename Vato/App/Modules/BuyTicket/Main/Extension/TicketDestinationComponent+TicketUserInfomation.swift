//  File name   : TicketDestinationComponent+TicketUserInfomation.swift
//
//  Author      : vato.
//  Created date: 10/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketUserInfomation scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketUserInfomation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketUserInfomation scope.
}

extension TicketDestinationComponent: TicketUserInfomationDependency {
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    // todo: Implement properties to provide for TicketUserInfomation scope.
}
