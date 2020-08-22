//  File name   : FirebasePersonalDriver.swift
//
//  Author      : Futa Corp
//  Created date: 12/7/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct FirebasePersonalDriver: Codable, Equatable, ModelFromFireBaseProtocol {
    let isFavorite: Bool
    let reporterFirebaseid: String
    let userAvatar: String
    let userFirebaseId: String
    let userId: Int64
    let userName: String
    let userPhone: String
}

// MARK: PersonalDriverProtocol
extension FirebasePersonalDriver: PersonalDriverProtocol {
    var firebaseID: String {
        return userFirebaseId
    }

    var userID: Int64 {
        return userId
    }

    var fullname: String {
        return userName
    }

    var phone: String {
        return userPhone
    }

    var avatarURL: URL? {
        return URL(string: userAvatar)
    }
}
