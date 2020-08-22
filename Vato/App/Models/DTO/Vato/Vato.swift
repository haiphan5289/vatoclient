//  File name   : Vato.swift
//
//  Author      : Vato
//  Created date: 10/29/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FirebaseAuth

struct Vato: Codable {
    let user: User
//    let driver: Any?

    /// User.
    struct User: Codable, ClientProtocol, UserProtocol {
//        let createdBy: Int
//        let updatedBy: Int
        let createdAt: TimeInterval
//        let updatedAt: TimeInterval
        let id: Int64
        var fullName: String?
        var nickname: String?
        var avatarUrl: String?
        let firebaseId: String
        let adminZoneId: Int
        let type: Int
        var idcardId: Int?
        let phone: String
//        let originalPhone: Any? //TODO: Specify the type to conforms Codable protocol
        var email: String?
        var birthday: String?
        var deviceToken: String?
//        let appVersion: String
        var zoneId: Int?
        let level: Int
        let active: Bool

        // MARK: ClientProtocol
//        var version: String { return appVersion }
//        var topic: String { return "" }
        var isActive: Bool {
            return active
        }
        var created: TimeInterval { return createdAt }
        var zoneID: Int { return zoneId ?? ZoneConstant.vn }
        var paymentMethod: PaymentMethod {
            get {
                return PaymentMethodCash
            }
            set {

            }
        }
        var apnsToken: String { return deviceToken ?? "" }
        var avatarURL: URL? {
            if let urlString = avatarUrl, let url = URL(string: urlString) {
                return url
            } else if let providerData = Auth.auth().currentUser?.providerData.first(where: { $0.providerID == FacebookAuthProviderID || $0.providerID == GoogleAuthProviderID }), let url = providerData.photoURL {
                return url
            }
            return nil
        }

        // MARK: UserProtocol
        var photoURL: URL? { return URL(string: avatarUrl ?? "") }
        var fullname: String? { return fullName }
//        var nickname: String { return nic ?? "" }
        var emailAddress: String { return email ?? "" }
        var userID: Int64 { return id }
        var firebaseID: String { return firebaseId }
        var cash: Double { return 0 }
        var coin: Double { return 0 }
    }
}
