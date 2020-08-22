//  File name   : PersonalDriverProtocol.swift
//
//  Author      : Futa Corp
//  Created date: 12/7/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

protocol PersonalDriverProtocol {
    var firebaseID: String { get }
    var userID: Int64 { get }

    var fullname: String { get }
    var phone: String { get }

    var avatarURL: URL? { get }
}

extension PersonalDriverProtocol {
    var maskPhone: String {
        return String(phone.dropLast(3).appending("xxx"))
    }

    var updateFirebase: [String:Any] {
        let info: [String:Any] = [
            "userAvatar":avatarURL?.absoluteString ?? "",
            "userFirebaseId":firebaseID,
            "userId":userID,
            "userName":fullname,
            "userPhone":phone,
            ]
        return info
    }
}
