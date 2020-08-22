//  File name   : PersonalDriver.swift
//
//  Author      : Futa Corp
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct PersonalDriver: Codable {
    let firebaseId: String
    let fullName: String
    let id: Int64
    let avatar: String
    var phoneNumber: String?
}

extension PersonalDriver: PersonalDriverProtocol {
    var firebaseID: String {
        return firebaseId
    }

    var userID: Int64 {
        return id
    }

    var fullname: String {
        return fullName
    }

    var phone: String {
        return phoneNumber ?? ""
    }

    var avatarURL: URL? {
        return URL(string: avatar)
    }
}
