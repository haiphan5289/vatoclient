//  File name   : Service.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import UIKit
import VatoNetwork

struct Car: Codable {
    let id: Int
    let choose: Bool
    let name: String
    var description: String?
    
    var serviceType: VatoServiceType {
        return VatoServiceType(rawValue: id) ?? .none
    }
    
    var mode: MapAPI.Transport {
        let type = serviceType
        switch type {
        case .car, .car7, .carPlus, .delivery, .buyTicket:
            return .car
        default:
            return .bike
        }
    }
}

// Car -> Fare
struct Service: Codable, ModelFromFireBaseProtocol {
    let id: Int // Use for compare
    let choose: Bool
    let name: String
    let cartypes: [Car]
}

typealias GroupServiceType = [FareCalculated]
protocol GroupServiceProtocol {
    var isGroupService: Bool { get }
    var groupsService: GroupServiceType? { get }
    var rangePrice: (min: UInt32, max: UInt32)? { get }
}

protocol ServiceCanUseProtocol: GroupServiceProtocol {
    var idService: Int { get }
    var service: Car { get }
    var fare: FareDisplay? { get }
    var predicate: FarePredicate? { get }
    var modifier: FareModifier? { get }
    var isFixedPrice: Bool { get }
    var priceTotal: UInt32  { get }
    var priceDiscount: UInt32  { get }
    var name: String { get }
    var priceOriginal: UInt32?  { get }
    var img: UIImage? { get}
    var isHighRate: Bool { get }
    
    mutating func update(from predicates: [FarePredicate]?, with modifiers: [FareModifier]?)
}

extension ServiceCanUseProtocol {
    var isGroupService: Bool {
        return fare?.setting.isGroupService ?? false
    }
    
    var groupsService: GroupServiceType? {
        return fare?.setting.groupsService
    }
    
    var img: UIImage? {
        return service.serviceType.image()
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        let l = lhs.service
        let r = rhs.service
        return l.id == r.id && l.name == r.name
    }
}

struct ServiceChooseGroup: ServiceCanUseProtocol  {
    var rangePrice: (min: UInt32, max: UInt32)? {
        return fare?.setting.rangePrice
    }
    var idService: Int
    var service: Car
    var fare: FareDisplay?
    var predicate: FarePredicate? { return nil }
    var modifier: FareModifier? { return nil }
    var isFixedPrice: Bool { return true }
    var priceDiscount: UInt32 { return 0 }
    var name: String { return fare?.setting.name ?? "" }
    
    var priceOriginal: UInt32? {
        return fare?.setting.originalPrice
    }
    var priceTotal: UInt32 {
        return fare?.setting.totalPrice ?? 0
    }
    
    var isHighRate: Bool {
        let increase = self.fare?.setting.groupsService?.reduce(false, { $0 || (($1.origin_fare ?? 0) < ($1.total_fare ?? 0))})
       return increase ?? false
    }
    
    func update(from predicates: [FarePredicate]?, with modifiers: [FareModifier]?) {}
    
    
}


struct ServiceUse: Equatable, ServiceCanUseProtocol {
    var rangePrice: (min: UInt32, max: UInt32)? {
        return nil
    }
    var idService: Int
    var service: Car
    var fare: FareDisplay?
    var predicate: FarePredicate?
    var modifier: FareModifier?
    var isFixedPrice: Bool
    var priceTotal: UInt32 = 0
    var priceDiscount: UInt32 = 0
    
    var name: String {
        return service.name
    }

    var priceOriginal: UInt32? {
        return fare?.price
    }

    var isHighRate: Bool {
        let ratio = self.modifier?.additionRatio ?? 0
        return ratio >= 0.5
    }

    mutating func update(from predicates: [FarePredicate]?, with modifiers: [FareModifier]?) {
        guard self.predicate == nil && self.modifier == nil else {
            return
        }

        defer {
            self.calculatePrice()
        }

        let price = self.fare?.price ?? 0
        var new = predicates?.filter({ $0.active && $0.serviceCanUse().contains(self.service.serviceType) && (isFixedPrice ? $0.fareMin...$0.fareMax ~= price : true) })
        new?.sort(by: <)
        self.predicate = new?.last

        guard let predicate = self.predicate else {
            return
        }

        let modifier = modifiers?.first(where: { $0.id == predicate.modifierId })
        self.modifier = modifier
    }

    private mutating func calculatePrice() {
        priceTotal = priceOriginal ?? 0

        guard let fareModifier = self.modifier else {
            return
        }

        var newFare = Double(priceTotal)
        if fareModifier.additionRatio > 0.0 || fareModifier.additionAmount > 0.0 {
            var add = newFare * fareModifier.additionRatio + fareModifier.additionAmount
            add = min(add, fareModifier.additionMax)
            add = max(add, fareModifier.additionMin)
            newFare += add
        }

        priceTotal = (UInt32(newFare) / 1000) * 1000
    }
}
