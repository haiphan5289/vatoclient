//  File name   : FarePredicate.swift
//
//  Author      : Dung Vu
//  Created date: 9/28/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import Foundation
import FwiCore

struct Trip {
    static let ignore = 4
}

struct FarePrdicateDate: Decodable {
    let startDate: Int
    let endDate: Int
}

struct FarePrdicateTime: Decodable {
    let startTime: Double
    let endTime: Double
}

struct BookService {
    static let applyAll = 0
    static let fixed = 10
    static let quickBook = 20
}

protocol PredicateServiceProtocol {
    var service: Int { get }
}

extension PredicateServiceProtocol {
    func serviceCanUse() -> [VatoServiceType] {
        return list.filter({ ($0 & self.service) == $0 }).compactMap({ VatoServiceType(rawValue: $0) })
    }
}

fileprivate let list = [1, 2, 4, 8, 16, 32, 64, 128]
struct FarePredicate: Codable, ModelFromFireBaseProtocol, PriorityComparableProtocol, ValidPredicateProtocol, PredicateServiceProtocol {
    let id: Int
    let manifestId: Int

    var priority: Int
    let fareMax: UInt32
    let fareMin: UInt32
    let startLat: Double
    let startLon: Double
    let endLat: Double
    let endLon: Double

    var active: Bool
    let tripType: Int
    let modifierId: Int

    var service: Int

    var startDistance: Double
    var endDistance: Double

    var startDate: TimeInterval
    var endDate: TimeInterval
    var endTime: Double
    var startTime: Double

    var startCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
    }

    var endCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
    }
}

protocol PriorityComparableProtocol: Comparable {
    var priority: Int { get }
}

extension PriorityComparableProtocol {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.priority < rhs.priority
    }
}

extension CLLocationCoordinate2D {
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }

    func distance(to: CLLocationCoordinate2D) -> Double {
        let result = self.location.distance(from: to.location)
        return result
    }
}


