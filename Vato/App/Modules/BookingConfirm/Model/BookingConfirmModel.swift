//
//  BookingConfirmModel.swift
//  FaceCar
//
//  Created by Dung Vu on 9/18/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import CoreLocation
import Foundation

// MARK: Class use for hold price information
final class BookingConfirmPrice: Equatable {
    var lastPrice: UInt32 = 0
    var originalPrice: UInt32 = 0
    var driverAmount: UInt32 = 0
    var clientAmount: UInt32 = 0
    var tip: Double = 0
    var useFixed = false
    var service: ServiceCanUseProtocol?
    
    static func ==(lhs: BookingConfirmPrice, rhs: BookingConfirmPrice) -> Bool {
        return lhs.service?.service.id == rhs.service?.service.id
    }

    func calculateLastPrice(from service: ServiceCanUseProtocol?, tip: Double) {
        guard let service = service else {
            return
        }
        self.service = service
        self.tip = tip
        
        self.originalPrice = service.priceTotal
        self.lastPrice = service.priceTotal
        if !service.isGroupService,
            let price = service.groupsService?.first{
            self.driverAmount = price.driver_support_fare?.roundPrice() ?? 0
        }
    }
    
    private func calculateDiscount(from modifier: FareModifier?, with newFare: Double) -> (driverAmount: Double, clientAmount: Double) {
        useFixed = false
        guard let fareModifier = modifier else {
            return (0, 0)
        }
        
        var driverAmount: Double = 0
        var clientAmount: Double = 0
        // Same Price
        if let clientFixed = fareModifier.clientFixed , 0.1...max(0.1, newFare) ~= clientFixed  {
            useFixed = true
            clientAmount = newFare - clientFixed
        } else {
            if fareModifier.clientRatio > 0.0 || fareModifier.clientDelta > 0.0 {
                clientAmount = newFare * fareModifier.clientRatio + fareModifier.clientDelta
                clientAmount = max(clientAmount, fareModifier.clientMin)
                clientAmount = min(clientAmount, fareModifier.clientMax)
            }
        }
        
        // Use for driver
        if newFare <= fareModifier.driverActiveAmount {
            driverAmount = fareModifier.driverActiveAmount - newFare
            driverAmount = min(driverAmount, fareModifier.driverMax)
            driverAmount = max(driverAmount, fareModifier.driverMin)
        } else if fareModifier.driverRatio > 0.0 {
            driverAmount = newFare * fareModifier.driverRatio
            driverAmount = min(driverAmount, fareModifier.driverMax)
            driverAmount = max(driverAmount, fareModifier.driverMin)
        }
        
        return (driverAmount, clientAmount)
    }
}

// MARK: Class use for book
final class BookingConfirmInformation {
    var note: String?
    var tip: Double?
    var booking: Booking?
    var service: ServiceCanUseProtocol?
    var informationPrice: BookingConfirmPrice?
    var zone: Zone?
    var polyline: String?
    var addPrice: [PriceAddition]?
    var paymentMethod: PaymentCardDetail?
    var userInfor: UserInfo?
    var useFavoriteService: Bool = false
    var supplyInfo: SupplyTripInfo?
    var _promotionModel: PromotionModel?
    var promotionModel: PromotionModel? {
        set {
            _promotionModel = newValue
        }
        
        get {
            return _promotionModel
        }
    }
    // Delivery
    var senderName: String?
    var receiverPhone: String?
    var receiverName: String?
    

    func exportJson() -> [String: Any]? {
        var result: [String: Any] = [:]
        result["price"] = self.service?.fare?.price
        result["additionPrice"] = tip
        
        // Promotion
        if promotionModel?.canApply == true {
            result["promotionValue"] = promotionModel?.discount
            result["promotionCode"] = promotionModel?.code
            result["promotionModifierId"] = promotionModel?.modifierId
            result["promotionDelta"] = promotionModel?.promotionDelta
            result["promotionRatio"] = promotionModel?.promotionRatio
            result["promotionMin"] = promotionModel?.promotionMin
            result["promotionMax"] = promotionModel?.promotionMax
            result["promotionToken"] = promotionModel?.data?.data?.promotionToken
            result["promotionDescription"] = promotionModel?.mainfest?.headline
        }
        
        result["clientFirebaseId"] = userInfor?.firebaseId
        result["clientUserId"] = userInfor?.id

        result["driverFirebaseId"] = nil
        result["driverUserId"] = nil

        result["contactPhone"] = userInfor?.phone

        result["tripType"] = self.booking?.destinationAddress1 == nil ? BookService.quickBook : BookService.fixed

        result["distance"] = self.service?.fare?.trip?.distance.value
        result["duration"] = self.service?.fare?.trip?.duration.value

        let m = self.paymentMethod
        result["payment"] = (m?.type.method ?? PaymentMethodCash).rawValue // 0: cash
        result["cardId"] = m?.napas == true ? m?.id : nil
        result["note"] = note
        result["startName"] = self.booking?.originAddress.primaryText
        result["startAddress"] = self.booking?.originAddress.secondaryText
        result["startLat"] = self.booking?.originAddress.coordinate.latitude
        result["startLon"] = self.booking?.originAddress.coordinate.longitude
        result["zoneId"] = self.zone?.id
        result["startFavoritePlaceId"] = self.booking?.originAddress.favoritePlaceID

        result["endFavoritePlaceId"] = self.booking?.destinationAddress1?.favoritePlaceID
        result["endName"] = self.booking?.destinationAddress1?.primaryText
        result["endAddress"] = self.booking?.destinationAddress1?.secondaryText
        result["endLat"] = self.booking?.destinationAddress1?.coordinate.latitude
        result["endLon"] = self.booking?.destinationAddress1?.coordinate.longitude
        result["serviceId"] = self.service?.service.id
        result["serviceName"] = self.service?.service.name
        result["modifierId"] = self.service?.modifier?.id
        result["farePrice"] = self.informationPrice?.originalPrice
        result["fareClientSupport"] = self.informationPrice?.clientAmount
        result["fareDriverSupport"] = self.informationPrice?.driverAmount
        result["polyline"] = self.polyline
        result["favDriver"] = self.useFavoriteService

        return result
    }

    func canPayment() throws -> Bool {
        guard let userInfor = self.userInfor,
            let method = self.paymentMethod?.type.method
        else {
            throw PaymentError.notHaveInformationUser
        }

        switch method {
        case PaymentMethodVATOPay:
            let cash = userInfor.cash
            let tip = informationPrice?.tip ?? 0
            let price = informationPrice?.lastPrice ?? 0 + UInt32(tip)
            let next = self.booking?.tripType == BookService.quickBook ? max(price, 30000) : price
            return Double(next) <= cash
        default:
            return true
        }
    }

    deinit {
        printDebug("\(self) \(#function)")
    }
}

enum PaymentError: Error {
    case notHaveInformationUser
    case napasExceedAllow(defaultMoney: Double)
    case napsNotApplyOneTouch
}

