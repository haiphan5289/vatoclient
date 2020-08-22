//
//  NotificationModel.swift
//  Vato
//
//  Created by khoi tran on 1/13/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

enum NotifyType : Int, Codable {
    case _default = 10
    case referal = 20
    case link = 30
    case promotion = 40
    case balance = 50
    case transfer_money = 60
    case app = 70
    case chatting = 90
    case new_booking = 91
    case manifest = 100
    case web = 110
    case not_enough_vato_pay = 10000
    case none = 0
}
struct NotificationModel: Codable {
    let title: String?
    let body: String?
    let id: String?
    let url: String?
    let status: Int?
    var type: NotifyType?
    let referId: String?
    let extra: String?
    let createdAt: Double?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try values.decodeIfPresent(String.self, forKey: CodingKeys.title)
        body = try values.decodeIfPresent(String.self, forKey: CodingKeys.body)
        id = try values.decodeIfPresent(String.self, forKey: CodingKeys.id)
        url = try values.decodeIfPresent(String.self, forKey: CodingKeys.url)
        status = try values.decodeIfPresent(Int.self, forKey: CodingKeys.status)
        type = try values.decodeIfPresent(NotifyType.self, forKey: CodingKeys.type)
        if type == nil {
            type = NotifyType.none
        }
        referId = try values.decodeIfPresent(String.self, forKey: CodingKeys.referId)
        extra = try values.decodeIfPresent(String.self, forKey: CodingKeys.extra)

        createdAt = try values.decodeIfPresent(Double.self, forKey: CodingKeys.createdAt)
    }
}


extension NotificationModel {
    var dateCreate: Date? {
        if let createAt = self.createdAt {
            return Date(timeIntervalSince1970: TimeInterval(createAt/1000))
        }
        return nil
    }
}
