//  File name   : PromotionData.swift
//
//  Author      : Dung Vu
//  Created date: 10/8/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

protocol ValidPredicateProtocol {
    var active: Bool { get }
    var startDistance: Double { get }
    var endDistance: Double { get }
    var startDate: TimeInterval { get }
    var endDate: TimeInterval { get }
    var startCoordinate: CLLocationCoordinate2D { get }
    var endCoordinate: CLLocationCoordinate2D { get }
    var startTime: Double { get }
    var endTime: Double { get }
}

extension ValidPredicateProtocol {
    func validate(startBook: CLLocationCoordinate2D, endBook: CLLocationCoordinate2D?, adjust: Double = 7, zone: DateIdentifier = .utc) -> Bool {
        if !active {
            return false
        }

        let d1 = startBook.distance(to: startCoordinate)
        if d1 > startDistance {
            return false
        }

        if let endBook = endBook {
            let d2 = endBook.distance(to: endCoordinate)
            if d2 > endDistance {
                return false
            }
        }
//        let date = Date()
//        let offset = TimeZone.current.secondsFromGMT() - (TimeZone(identifier: zone.rawValue)?.secondsFromGMT() ?? 0)
        let timeStamp = FireBaseTimeHelper.default.currentTime
        let date = Date(timeIntervalSince1970: timeStamp / 1000)
        let startT = self.startDate /// 1000 + TimeInterval(offset)
        let endT = self.endDate /// 1000 + TimeInterval(offset)
        let contain = startT...endT ~= timeStamp
        if !contain {
            return false
        }
        
        // Check again
        let start = startTime - adjust
        let end = endTime - adjust
        let hourCurrent = date.to24h()
        guard start <= end else {
            return false
        }

        let result = start...end ~= hourCurrent
        return result
    }
}

struct PromotionData: Codable {
    init(data: Data) {
        self.data = data
        self.message = nil
        self.errorCode = nil
        self.status = 200
        self.time = Date()
    }
    
    struct Data: Codable {
        init(promotionPredicate: PromotionData.Data.PromotionPredicate) {
            self.promotionPredicates = [promotionPredicate]
            self.promotionModifiers = []
            self.promotionToken = ""
        }
        
        struct PromotionModifier: Codable {
            let createdBy: Int
            let updatedBy: Int
            let createdAt: Date
            let updatedAt: Date
            let id: Int
            let active: Bool
            let expired: Bool
            let priority: Int
            let delta: Double
            let ratio: Double
            let min: Double
            let max: Double
            
            // Same price
            let stack: Bool
            let override: Bool
            
            var fixedFare: Double?
        }

        struct PromotionPredicate: Codable, ValidPredicateProtocol, Comparable, PredicateServiceProtocol {
            init(promotionPredicate: PromotionList.PromotionPredicate) {
                self.createdBy = promotionPredicate.createdBy
                self.updatedBy = promotionPredicate.updatedBy
                self.createdAt = promotionPredicate.createdAt
                self.updatedAt = promotionPredicate.updatedAt
                self.id = promotionPredicate.id
                self.active = promotionPredicate.active
                self.expired = promotionPredicate.expired
                self.paymentType = promotionPredicate.paymentType
                self.tripType = promotionPredicate.tripType
                self.service = promotionPredicate.service
                self.startLat = promotionPredicate.startLat
                self.startLon = promotionPredicate.startLon
                self.startDistance = promotionPredicate.startDistance
                self.endLat = promotionPredicate.endLat
                self.endLon = promotionPredicate.endLon
                self.endDistance = promotionPredicate.endDistance
                self.distanceMin = promotionPredicate.distanceMin
                self.distanceMax = promotionPredicate.distanceMax
                self.fareMin = promotionPredicate.fareMin
                self.fareMax = promotionPredicate.fareMax
                self.priority = promotionPredicate.priority
                self.promotionModifierId = promotionPredicate.promotionModifierId
                self.startDate = promotionPredicate.startDate.timeIntervalSince1970 * 1000.0
                self.endDate = promotionPredicate.endDate.timeIntervalSince1970 * 1000.0
                self.startTime = promotionPredicate.startTime
                self.endTime = promotionPredicate.endTime
            }
            
            let createdBy: Double
            let updatedBy: Double
            let createdAt: Date
            let updatedAt: Date
            let id: Int
            var active: Bool
            let expired: Bool
            let paymentType: Int
            let tripType: Int
            var service: Int
            let startLat: Double
            let startLon: Double
            var startDistance: Double
            let endLat: Double
            let endLon: Double
            var endDistance: Double
            let distanceMin: Double
            let distanceMax: Double
            let fareMin: Double
            let fareMax: Double
            let priority: Int
            let promotionModifierId: Int
            var startDate: TimeInterval
            var endDate: TimeInterval
            var startTime: Double
            var endTime: Double

            var startCoordinate: CLLocationCoordinate2D {
                return CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
            }

            var endCoordinate: CLLocationCoordinate2D {
                return CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
            }

            static func < (lhs: PromotionPredicate, rhs: PromotionPredicate) -> Bool {
                return lhs.priority < rhs.priority
            }

            // Check Payment
            func canApply(payment type: PaymentMethod) -> Bool {
                return (self.paymentType & (type.rawValue + 1)) == (type.rawValue + 1)
            }
            
            // Check apply
            func canApplyDistance(for book: Booking) -> Bool {
                guard let end = book.destinationAddress1?.coordinate else {
                    return true
                }
                
                guard distanceMin <= distanceMax else {
                    return false
                }
                
                let distanceTrip = book.originAddress.coordinate.distance(to: end)
                let result = distanceMin...distanceMax ~= distanceTrip
                #if DEBUG
                    printDebug("Promotion Book Apply: \(result)")
                #endif
                return result
            }
        }

        let promotionModifiers: [PromotionModifier]
        let promotionPredicates: [PromotionPredicate]
        let promotionToken: String
    }

    let message: String?
    let errorCode: String?
    let status: Int
    var data: Data?
    let time: Date
}

// MARK: Model
enum PromotionError: Error {
    case notHaveInformation
    case notEnoughInformation
    case notHavePredicate
    case notHaveModifier
    case applyCode(e: Error)
    case notApplyService(s: VatoServiceType)
    case notApplyFixedPrice
    case promotionOutOfrange
    case notFoundPromotionForAutoApply
    var localizedDescription: String {
        return "Khuyến mãi không được áp dụng."
    }
}

enum PromotionFrom {
    case manifest
    case menu
}

struct PromotionCalculateResult {
    let modifier: PromotionData.Data.PromotionModifier
    let discount: UInt32
    let usingFixed: Bool
}

final class PromotionModel: Equatable {
    let code: String
    var data: PromotionData?
    var discount: UInt32 = 0
    var minDiscount: UInt32 = 0
    var modifierId: Int?
    var promotionDelta: Double?
    var promotionRatio: Double?
    var promotionMin: Double?
    var promotionMax: Double?
    var canApply: Bool = false
    var paymentMethod: PaymentMethod = PaymentMethodCash
    
    // Hold to check use promotion
    var usingPromotionFixed: Bool = false
    
    // Capture for display detail
    var mainfest: PromotionList.Manifest?

    var promotionFrom: PromotionFrom?
    
    init(with code: String) {
        self.code = code
    }

    static func == (lhs: PromotionModel, rhs: PromotionModel) -> Bool {
        return lhs.code == rhs.code
    }

    private func reset() {
        self.paymentMethod = PaymentMethodCash
        self.canApply = false
        self.usingPromotionFixed = false
        self.modifierId = nil
        self.discount = 0
        self.promotionDelta = nil
        self.promotionRatio = nil
        self.promotionMin = nil
        self.promotionMax = nil
    }

    func calculateDiscount(from booking: Booking?, paymentType: PaymentMethod, price: BookingConfirmPrice?, serviceType: VatoServiceType) throws {
        reset()
        self.paymentMethod = paymentType
        let result = try usePromotion(from: booking, price: price, serviceType: serviceType)
        self.usingPromotionFixed = result.usingFixed
        self.canApply = true
        self.discount = result.discount
        self.modifierId = result.modifier.id
        self.promotionDelta = result.modifier.delta
        self.promotionRatio = result.modifier.ratio
        self.promotionMin = result.modifier.min
        self.promotionMax = result.modifier.max
    }
    
    func usePromotion(from booking: Booking?, price: BookingConfirmPrice?, serviceType: VatoServiceType) throws -> PromotionCalculateResult {
        guard let data = data,
            let booking = booking,
            let price = price else {
                throw PromotionError.notHaveInformation
        }
        // Predicate
        let tripType = booking.tripType
        var allPredicates = data.data?.promotionPredicates
        allPredicates?.sort(by: >)
        
        guard let predicate = allPredicates?.filter({ $0.active }).first(where: {
            (price.originalPrice > 0 ? $0.fareMin...$0.fareMax ~= Double(price.originalPrice) : true)
                && $0.validate(startBook: booking.originAddress.coordinate, endBook: booking.destinationAddress1?.coordinate, adjust: 0)
                && $0.canApply(payment: self.paymentMethod)
                && ($0.tripType == BookService.applyAll || $0.tripType == tripType)
                && $0.canApplyDistance(for: booking)
        }) else {
            throw PromotionError.notHavePredicate
        }
        
        // Check can use service
        let servicesValid = predicate.serviceCanUse()
        guard servicesValid.contains(serviceType) else {
            throw PromotionError.notApplyService(s: serviceType)
        }
        
        // modifier
        guard let modifier = data.data?.promotionModifiers.first(where: {
            $0.active && $0.id == predicate.promotionModifierId
        }) else {
            throw PromotionError.notHaveModifier
        }
        
        var mdiscount: UInt32 = 0
        var useFixed: Bool = false
        guard price.originalPrice > 0 else {
            return PromotionCalculateResult(modifier: modifier, discount: mdiscount, usingFixed: useFixed)
        }
        var discount: Double = 0
        LogicDiscount: if let f = modifier.fixedFare, f > 0 {
            guard 0.1...max(0.1, Double(price.originalPrice)) ~= f else {
                throw PromotionError.promotionOutOfrange
            }
            
            guard !price.useFixed || (price.clientAmount == 0 && modifier.stack && modifier.override)else {
                throw PromotionError.notApplyFixedPrice
            }
            useFixed = true
            discount = Double(price.originalPrice) - f
            mdiscount = UInt32(discount)
            self.calculateMinDiscount(minPrice: price.service?.rangePrice?.min ?? 0, modifier: modifier)
        } else {
            // Old logic
            discount = Double(price.originalPrice) * modifier.ratio + modifier.delta
            discount = max(discount, modifier.min)
            discount = min(discount, modifier.max)
            
            let last = (UInt32(discount) / 1000) * 1000
            mdiscount = last
            self.calculateMinDiscount(minPrice: price.service?.rangePrice?.min ?? 0, modifier: modifier)
        }
        mdiscount = min(mdiscount, price.originalPrice)
        return PromotionCalculateResult(modifier: modifier, discount: mdiscount, usingFixed: useFixed)
    }
    
    func calculateMinDiscount(minPrice: UInt32, modifier: PromotionData.Data.PromotionModifier) {
        var minDiscount: Double = 0
        if let f = modifier.fixedFare, f > 0 {
            minDiscount = Double(minPrice) - f
            self.minDiscount = UInt32(minDiscount)
        } else {
            minDiscount = Double(minPrice) * modifier.ratio + modifier.delta
            minDiscount = max(minDiscount, modifier.min)
            minDiscount = min(minDiscount, modifier.max)
            let lastMin = (UInt32(minDiscount) / 1000) * 1000
            self.minDiscount = lastMin
        }
        self.minDiscount = min(self.minDiscount, minPrice)
    }
    
    // not check modifier
    func checkPredicatePromotion(from booking: Booking?, price: BookingConfirmPrice?, serviceType: VatoServiceType) throws {
        guard let data = data,
            let booking = booking,
            let price = price else {
                throw PromotionError.notHaveInformation
        }
        // Predicate
        let tripType = booking.tripType
        var allPredicates = data.data?.promotionPredicates
        allPredicates?.sort(by: >)
        
        guard let predicate = allPredicates?.filter({ $0.active }).first(where: {
            (price.originalPrice > 0 ? $0.fareMin...$0.fareMax ~= Double(price.originalPrice) : true)
                && $0.validate(startBook: booking.originAddress.coordinate, endBook: booking.destinationAddress1?.coordinate, adjust: 0)
                && $0.canApply(payment: self.paymentMethod)
                && ($0.tripType == BookService.applyAll || $0.tripType == tripType)
                && $0.canApplyDistance(for: booking)
        }) else {
            throw PromotionError.notHavePredicate
        }
        
        // Check can use service
        let servicesValid = predicate.serviceCanUse()
        guard servicesValid.contains(serviceType) else {
            throw PromotionError.notApplyService(s: serviceType)
        }
    }
    
}
