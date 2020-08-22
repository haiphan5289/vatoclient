//  File name   : PromotionList.swift
//
//  Author      : Dung Vu
//  Created date: 10/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Kingfisher

enum ManifestAction: Int, Codable {
    case manifest = 100
    case web = 110
//    case screen = 120
    case ecom = 130
}

struct PromotionList: Codable {
    struct MasterCode: Codable, PromotionStateProtocol {
        let createdBy: Double
        let updatedBy: Double
        let createdAt: Date
        let updatedAt: Date
        let id: Int
        var active: Bool
        var expired: Bool
        var code: String
        let total: Int
        let perDay: Int
        let perUser: Int
        let perDayUser: Int
        let counterId: Int
        var promotionPredicateId: Int
        var manifestId: Int
        let priority: Int
        var startDate: Date
        var endDate: Date
        let startTime: Double
        let endTime: Double
    }
    
    struct UserCode: Codable, PromotionStateProtocol {
        let createdBy: Double
        let updatedBy: Double
        let createdAt: Date
        let updatedAt: Date
        let id: Int
        var active: Bool
        var expired: Bool
        let userId: Int
        let masterId: Int
        var promotionPredicateId: Int
        var code: String
        let total: Int
        let perDay: Int
        var current: Int?
        var today: Double? //TODO: Specify the type to conforms Codable protocol
        var currentToday: Double?
        var manifestId: Int
        var startDate: Date
        var endDate: Date
        let startTime: Double
        let endTime: Double
        let priority: Int
    }
    
    struct PromotionPredicate: Codable, PredicateServiceProtocol {
        let createdBy: Double
        let updatedBy: Double
        let createdAt: Date
        let updatedAt: Date
        let id: Int
        let active: Bool
        let expired: Bool
        let paymentType: Int
        let tripType: Int
        var service: Int
        let startLat: Double
        let startLon: Double
        let startDistance: Double
        let endLat: Double
        let endLon: Double
        let endDistance: Double
        let distanceMin: Double
        let distanceMax: Double
        let fareMin: Double
        let fareMax: Double
        let priority: Int
        let promotionModifierId: Int
        let startDate: Date
        let endDate: Date
        let startTime: Double
        let endTime: Double
    }
    
    struct Manifest: Codable, ImageDisplayProtocol {
        var imageURL: String? {
            return icon
        }
        var cacheLocal: Bool { return true }
        let createdBy: Double
        let updatedBy: Double
        let createdAt: Date
        let updatedAt: Date
        let id: Int
        let active: Bool
        let type: Int
        var icon: String?
        var banner: String?
        var image: String?
        var title: String?
        let headline: String?
        let description: String?
        var code: String?
    }
    struct ManifestPredicate: Codable {
        let createdBy: Double
        let updatedBy: Double
        let createdAt: Date
        let updatedAt: Date
        let id: Int
        let manifestId: Int
        let type: Int // ManifestAction?
        let extra: String
        let active: Bool
        let priority: Int
        let zoneId: Int
        let startDate: TimeInterval
        let endDate: TimeInterval
        let startTime: Double
        let endTime: Double
        let times: Double
        let timesPerDay: Int
    }
    
    let masterCodes: [MasterCode]
    let userCodes: [UserCode]
    let promotionPredicates: [PromotionPredicate]
    let manifests: [Manifest]
    
    subscript(manifestId: Int) -> Manifest? {
        return manifests.lazy.first(where: { $0.id == manifestId })
    }
    
    subscript(predicate idx: Int) -> PromotionPredicate? {
        return promotionPredicates.lazy.first(where: { $0.id == idx })
    }
    
    func listDisplay() -> [PromotionDisplayProtocol] {
        var list: [PromotionStateProtocol] = masterCodes
        list.append(contentsOf: userCodes)
        list = list.filter(~\.active)
        
        list = list.sorted(by: { $0.priority > $1.priority })
        
        let result = list.map({ item -> PromotionDisplayProtocol in
            let mId = item.manifestId
            let pId = item.promotionPredicateId
            let manifest = self[mId]
            let predicate = self[predicate: pId]
            return PromotionDisplayInfor(predicate: predicate, state: item, manifest: manifest)
        })
        
        return result
    }
}

protocol PromotionDisplayProtocol {
    var state: PromotionStateProtocol { get }
    var predicate: PromotionList.PromotionPredicate? { get }
    var manifest: PromotionList.Manifest? { get }
}

protocol PromotionStateProtocol {
    var active: Bool { get }
    var expired: Bool { get }
    var code: String { get }
    var manifestId: Int { get }
    var promotionPredicateId: Int { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var priority: Int { get }
}

struct PromotionDisplayInfor: PromotionDisplayProtocol {
    var predicate: PromotionList.PromotionPredicate?
    var state: PromotionStateProtocol
    var manifest: PromotionList.Manifest?
}
