//
//  BlockDriverModel.swift
//  Vato
//
//  Created by an.nguyen on 7/2/20.
//  Copyright © 2020 Vato. All rights reserved.
//

struct BlockDriverInfo: Codable {
    var avatarUrl: String?
    var fullName: String?
    let id: Int64
    var phone: String
    var appVersion: String?
    var type: TypeBlock?
}

struct DDriverInfo: Codable {
    var avatar: String?
    var fullName: String?
    let id: Int64
    var firebaseId: String?
}

enum TypeBlock: Int, Codable {
    case add
    case remove
}
