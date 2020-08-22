//
//  AddDestinationNotification.swift
//  Vato
//
//  Created by khoi tran on 4/1/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
enum AddDestinationNotificationType: String, Codable {
    case changeDestination = "CHANGE_TRIP_DESTINATION"
}
enum AddDestinationActionType: String, Codable {
    case create = "CREATE"
    case accept = "ACCEPT"
    case reject = "REJECT"
}


struct AddDestinationNotification: Codable, Comparable {
    struct PayLoad: Codable {
        let tripId: String?
        let orderId: Int?
        let status: AddDestinationActionType?
        let reason: String?
    }
    var type: AddDestinationNotificationType?
    var action: String?
    var expired_at: Double?
    var created_at: Double?
    var payload: PayLoad?
    
    static func == (lhs: AddDestinationNotification, rhs: AddDestinationNotification) -> Bool {
        let c1 = lhs.payload?.tripId == rhs.payload?.tripId
        let c2 = lhs.payload?.orderId == rhs.payload?.orderId
        let c3 = lhs.created_at == rhs.created_at
        return c1 && c2 && c3
    }
    
    static func < (lhs: AddDestinationNotification, rhs: AddDestinationNotification) -> Bool {
        let c1 = lhs.payload?.tripId == rhs.payload?.tripId
        let c2 = lhs.payload?.orderId == rhs.payload?.orderId
        let c3 = (lhs.created_at ?? 0) < (rhs.created_at ?? 0)
        return c1 && c2 && c3
    }
    
}

