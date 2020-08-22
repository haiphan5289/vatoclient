//  File name   : EcomPromotionModel.swift
//
//  Author      : Dung Vu
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct EcomPromotion: Codable, PromotionEcomProtocol, Equatable {
    var campaignImages: [String]?
    var alias_name: String?
    var ruleId: Int?
    var fromDate: TimeInterval
    var toDate: TimeInterval?
    var name: String?
    var description: String?
    var isVatoPromotion: Bool = false
    var canApply: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case ruleId
        case fromDate
        case toDate
        case name
        case description
        case campaignImages
    }
    
    static func ==(lhs: EcomPromotion, rhs: EcomPromotion) -> Bool {
        return lhs.ruleId == rhs.ruleId
    }
}

struct EcomPromotionResponse: Codable, ResponsePagingProtocol, InitializeValueProtocol {
    var next: Bool { return false }
    var items: [EcomPromotion]? {
        let vato = vato_campaign?.map({ (item) -> EcomPromotion in
            var new = item
            new.canApply = true
            new.isVatoPromotion = true
            return new
        })
        
        let m = merchant_campaign?.map({ (item) -> EcomPromotion in
            var new = item
            new.canApply = true
            return new
        })
        
        return vato?.addSequenceOptional(rhs: m)
    }
    
    private var vato_campaign: [EcomPromotion]?
    private var merchant_campaign: [EcomPromotion]?
    
    enum CodingKeys: String, CodingKey {
        case vato_campaign
        case merchant_campaign
    }
}
