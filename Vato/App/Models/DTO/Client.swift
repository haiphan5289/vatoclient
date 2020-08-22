//
//  Client.swift
//  FaceCar
//
//  Created by tony on 10/1/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation

struct DeviceInfo: Codable, ModelFromFireBaseProtocol {
    let id: String?
    let version: String?
    let model: String?
    let name: String?
}

struct Client: Codable, ModelFromFireBaseProtocol {
    var user: UserInfo?
    let version: String?
    let topic: String?
    let created: Double
    let deviceToken: String?
    let deviceInfo: DeviceInfo?
    let zoneId: Int
    var paymentMethod: PaymentMethod?

    mutating func update(user: UserInfo?) {
        self.user = user
    }
}

struct WalletResponse: Codable {
    var cash: Double {
        return credit
    }
    var coin: Double {
        return creditPending
    }
    let credit: Double
    let creditPending: Double
}
