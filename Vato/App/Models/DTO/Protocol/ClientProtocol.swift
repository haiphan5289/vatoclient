//  File name   : ClientProtocol.swift
//
//  Author      : Vato
//  Created date: 11/14/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FirebaseAuth

protocol ClientProtocol {
    var isActive: Bool { get }
    var version: String { get }
    var created: TimeInterval { get }

    var apnsToken: String { get }
    var deviceInfo: [String:String] { get }

    var zoneID: Int { get }
    var avatarURL: URL? { get }
    var paymentMethod: PaymentMethod { get set }
}

extension ClientProtocol {
    var deviceInfo: [String:String] {
        let current = UIDevice.current

        return [
            "id":current.identifierForVendor?.uuidString ?? "",
            "version":current.systemVersion,
            "model":current.model,
            "name":current.name
        ]
    }

    var version: String {
        return AppConfig.default.appInfor?.version ?? ""
    }

    var updateFirebaseClient: [String:Any] {
        var info: [String:Any] = [
            "active":NSNumber(value: isActive),
            "created":NSNumber(value: created),
            "deviceInfo":deviceInfo,
            "deviceToken":apnsToken,
            "paymentMethod":NSNumber(value: paymentMethod.rawValue),
            "version":version,
            "zoneId":NSNumber(value: zoneID)
        ]

        if let photoURL = avatarURL?.absoluteString {
            info["photo"] = photoURL
        } else {
            info["photo"] = Auth.auth().currentUser?.providerData.compactMap { $0.photoURL?.absoluteString }.first
        }
        return info
    }
}
