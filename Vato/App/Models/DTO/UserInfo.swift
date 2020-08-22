//
//  User.swift
//  FaceCar
//
//  Created by tony on 10/1/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation
import Kingfisher

struct UserInfo: Codable, ModelFromFireBaseProtocol, ImageDisplayProtocol, Equatable {
    var avatarUrl: String?
    var email: String?
    var fullName: String?
    var nickName: String?
    let id: Int64
    let firebaseId: String
    var phone: String
    var cash: Double
    var coin: Double
    var cacheLocal: Bool { return true }
    var imageURL: String? {
        return avatarUrl
    }
    var appVersion: String?

    var displayName: String? {
        return self.nickName ?? self.fullName
    }
    
    mutating func update(phone: String) {
        self.phone = phone
    }
    
    mutating func update(email: String?) {
        self.email = email
    }
    
    static func ==(lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.id == rhs.id
    }
}
