//  File name   : Fare.swift
//
//  Author      : Dung Vu
//  Created date: 9/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct FareCalculated: Codable {
    let service_id : Int?
    let origin_fare : Double?
    let total_fare : Double?
    let client_support_fare : Double?
    let driver_support_fare : Double?
    let taxi_brand_id : Int?
    let taxi_brand_name : String?
    let additional_services: [AdditionalServices]?

    var displayName: String?
    
    enum CodingKeys: String, CodingKey {
        
        case service_id = "service_id"
        case origin_fare = "origin_fare"
        case total_fare = "total_fare"
        case client_support_fare = "client_support_fare"
        case driver_support_fare = "driver_support_fare"
        case taxi_brand_id = "taxi_brand_id"
        case taxi_brand_name = "taxi_brand_name"
        case additional_services = "additional_services"

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        service_id = try values.decodeIfPresent(Int.self, forKey: .service_id)
        origin_fare = try values.decodeIfPresent(Double.self, forKey: .origin_fare)
        total_fare = try values.decodeIfPresent(Double.self, forKey: .total_fare)
        client_support_fare = try values.decodeIfPresent(Double.self, forKey: .client_support_fare)
        driver_support_fare = try values.decodeIfPresent(Double.self, forKey: .driver_support_fare)
        taxi_brand_id = try values.decodeIfPresent(Int.self, forKey: .taxi_brand_id)
        taxi_brand_name = try values.decodeIfPresent(String.self, forKey: .taxi_brand_name)
        additional_services = try values.decodeIfPresent([AdditionalServices].self, forKey: .additional_services)
    }
}

typealias FareCalculatedGroup = [String: [FareCalculated]]

struct ServiceGroup: Codable {
    let id : Int?
    let name : String?
    let displayName : String?
    let serviceId : Int?
    let force : Bool?
    let active : Bool?
    let transport : String?
    var segment: String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case displayName = "displayName"
        case serviceId = "serviceId"
        case force = "force"
        case active = "active"
        case transport = "transport"
        case segment
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
        serviceId = try values.decodeIfPresent(Int.self, forKey: .serviceId)
        force = try values.decodeIfPresent(Bool.self, forKey: .force)
        active = try values.decodeIfPresent(Bool.self, forKey: .active)
        transport = try values.decodeIfPresent(String.self, forKey: .transport)
        segment = try values.decodeIfPresent(String.self, forKey: .segment)
    }
}

