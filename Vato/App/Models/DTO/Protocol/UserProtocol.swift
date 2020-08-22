//  File name   : UserProtocol.swift
//
//  Author      : Vato
//  Created date: 11/14/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

protocol UserProtocol {
    var firebaseID: String { get }
    var userID: Int64 { get }
    var fullname: String? { get }
    var nickname: String? { get }
    var phone: String { get }
    var cash: Double { get }
    var coin: Double { get }

    var emailAddress: String { get }
    var photoURL: URL? { get }
}

extension UserProtocol {
    var displayName: String {
        guard let nickname = nickname, nickname.count > 0 else {
            return fullname ?? ""
        }
        return nickname
    }

    var updateFirebaseUser: [String:Any] {
        let info: [String:Any] = [
            "firebaseId":firebaseID,
            "id":NSNumber(value: userID),
            "fullName":fullname ?? "",
            "nickname":nickname ?? "",
            "phone":phone,
            "cash":NSNumber(value: cash),
            "coin":NSNumber(value: coin),

            "email":emailAddress
        ]
        return info
    }
}

extension UserInfo: UserProtocol {
    var firebaseID: String {
        return firebaseId
    }
    
    var userID: Int64 {
        return id
    }
    
    var fullname: String? {
        return fullName
    }
    
    var nickname: String? {
        return nickName
    }
    
    var emailAddress: String {
        return email ?? ""
    }
    
    var photoURL: URL? {
        guard let url = URL(string: avatarUrl ?? "") else { return nil }
        return url
    }
    
    
}
