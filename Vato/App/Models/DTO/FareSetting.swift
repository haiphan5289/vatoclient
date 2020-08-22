//  File name   : FareSetting.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import UIKit

enum VatoServiceType: Int, Codable, CaseIterable {
    case none = 0
    case car = 1
    case carPlus = 2
    case car7 = 4
    case moto = 8
    case motoPlus = 16
    case taxi = 32
    case taxi7 = 64
    case delivery = 128
    case buyTicket = 256
    case food = 512
    case shopping = 1024
    
    var segment: String? {
        #if DEBUG
        switch self {
        case .car, .carPlus, .car7, .moto, .motoPlus, .taxi, .taxi7:
            return "a"
        case .delivery:
            return "b"
        case .shopping:
            return "d"
        default:
            return nil
        }
        #else
        switch self {
        case .car, .carPlus, .car7, .moto, .motoPlus, .taxi, .taxi7:
            return "RIDING"
        case .delivery:
            return "DELIVERY"
        case .shopping:
            return "DELIVERY"
        default:
            return nil
        }
        #endif
    }

    func image() -> UIImage? {
        if self == .delivery {
            return UIImage(named: "ic_delivery_new")
        } else if self == .none {
            return nil
        } else {
            return UIImage(named: "vato_service_\(self.rawValue)")
        }
    }

    func mapIcon() -> UIImage? {
        if let image = self.loadImageFromTheme() {
            return image
        }
        
        if self == .none {
            return nil
        } else {
            return UIImage(named: "m-car-\(self.rawValue)-15")
        }
    }

    func mapImageName() -> String {
        if self == .none {
            return ""
        } else {
            return "m-car-\(self.rawValue)-15"
        }
    }
    
    static func canUseService(by id: Int) -> Bool {
       let canUse = self.allCases.map{ $0.rawValue }.contains(id)
       return canUse
    }
    
    func loadImageFromTheme() -> UIImage? {
        let name = "ic_car_marker_\(self.rawValue)"
        return ThemeManager.instance.loadPDFImage(name: name)
    }
}


protocol FareSettingProtocol: GroupServiceProtocol {
    var priority: Int { get }
    var active: Bool? { get }
    var zoneId: Int { get }
    var service: Int { get }
    var firstKm: Double { get }
    var min: Int { get }
    var perKm: Double { get }
    var perMin: Double { get } // price each minute
    var name: String? { get }
    var groupName: String? { get }
    var tripType: Int { get }
    var serviceType: VatoServiceType { get }
    var listTripType: [Int] { get }
    var originalPrice: UInt32? { get }
    var totalPrice: UInt32? { get }
    func price(trip: RouteTrip?) -> UInt32
}

// MARK: - FareCalculatedSetting
struct FareCalculatedSetting: FareSettingProtocol {
    var rangePrice: (min: UInt32, max: UInt32)? {
        let prices = self.groupsService?.compactMap { $0.total_fare }
        let min = self.round(value: prices?.min())
        let max = self.round(value: prices?.max())
        return (min, max)
    }
    
    private func round(value: Double?) -> UInt32 {
        guard let value = value else { return 0 }
        let average: UInt32
        let min = UInt32(value) / 1000
        if Int(value) % 1000 > 0 {
            average = min * 1000 + 1000
        } else {
            average = min * 1000
        }
        return average
    }
    
    
    var originalPrice: UInt32? {
        guard let groupsService = self.groupsService, !groupsService.isEmpty else {
            return nil
        }
        let total = groupsService.compactMap { $0.origin_fare }.max() ?? 0
        return self.round(value: total)
    }
    
    var totalPrice: UInt32? {
        guard let groupsService = self.groupsService, !groupsService.isEmpty else {
            return nil
        }
        let total = groupsService.compactMap { $0.total_fare }.max() ?? 0
        return self.round(value: total)
    }
    
    var name: String?
    var groupName: String?
    
    var priority: Int {
        return 0
    }
    
    var active: Bool?
    var zoneId: Int
    var service: Int
    var firstKm: Double {
        return 0
    }
    
    var min: Int {
        return 0
    }
    
    var perKm: Double {
        return 0
    }
    
    var perMin: Double {
        return 0
    }
    
    var tripType: Int { return BookService.fixed }
    
    var serviceType: VatoServiceType {
        return VatoServiceType(rawValue: service) ?? .none
    }
    
    var listTripType: [Int] { return [1] }
    
    func price(trip: RouteTrip?) -> UInt32 {
        return self.originalPrice ?? 0
    }
    
    var isGroupService: Bool
    
    var groupsService: GroupServiceType?
}

// MARK: - FareSetting
struct FareSetting: Codable, ModelFromFireBaseProtocol, FareSettingProtocol {
    var rangePrice: (min: UInt32, max: UInt32)? { return nil }
    var originalPrice: UInt32? { return nil }
    var totalPrice: UInt32? { return nil }
    
    var name: String? { return nil }
    var groupName: String?
    
    var isGroupService: Bool {
        return false
    }
    
    var groupsService: GroupServiceType? {
        return nil
    }
    
    struct ListTrip {
        static let values = [1, 2, 4]
    }
    let priority: Int
    var active: Bool?
    let zoneId: Int
    let service: Int
    let firstKm: Double
    let min: Int
    let perKm: Double
    let perMin: Double // price each minute
    let tripType: Int
    
    var serviceType: VatoServiceType {
        return VatoServiceType(rawValue: service) ?? .none
    }
    
    var listTripType: [Int] {
        return ListTrip.values.filter { ($0 & tripType) == $0 }
    }

    func price(trip: RouteTrip?) -> UInt32 {
        // distance: meter , duration: seconds
        guard let trip = trip else {
            return 0
        }
        let kms = trip.distance.value / 1000 // Convert to km
        let promotion = firstKm + kms * perKm
        let sum = promotion + (trip.duration.value / 60) * perMin
        // round price
        let result = (UInt32(sum) / 1000) * 1000
        return max(result, self.min.toUInt32)
    }
}

// MARK: - Fare display
struct FareDisplay: Comparable {
    var setting: FareSettingProtocol
    var price: UInt32
    let trip: RouteTrip?

    init(with fare: FareSettingProtocol, trip: RouteTrip?) {
        setting = fare
        self.trip = trip
        price = fare.price(trip: trip)
    }
    
    static func == (lhs: FareDisplay, rhs: FareDisplay) -> Bool {
        return lhs.setting.priority == rhs.setting.priority
    }
    
    static func > (lhs: FareDisplay, rhs: FareDisplay) -> Bool {
        return lhs.setting.priority > rhs.setting.priority
    }
    
    static func < (lhs: FareDisplay, rhs: FareDisplay) -> Bool
    {
        return lhs.setting.priority < rhs.setting.priority
    }
}

extension Array where Element == FareSetting {
    func filter(by zoneId: Int) -> [Element] {
        return self.filter({
            ($0.active != nil ? $0.active == true : true) && $0.zoneId == zoneId && $0.tripType != 4
        })
    }
}

extension Int {
    var toUInt32: UInt32 {
        return UInt32(self)
    }
}
