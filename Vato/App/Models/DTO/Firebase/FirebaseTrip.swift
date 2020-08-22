//  File name   : FirebaseTrip.swift
//
//  Author      : Futa Corp
//  Created date: 1/8/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore

enum TripDetailStatus: Int, Codable, Comparable {
    case clientCreateBook = 11
    case driverAccepted = 12
    case clientAgreed = 13
    case started = 14                   // chuyến đi bắt đầu
    case receivePackageSuccess = 15
    case completed = 21                 // hoàn thành
    case deliveryFail = 22
    case clientTimeout = 31
    case clientCancelInBook = 32
    case clientCancelIntrip = 33
    case driverCancelInBook = 41
    case driverDontEnoughMoney = 42
    case driverMissing = 43
    case driverBusyInAnotherTrip = 44   // driver in a another trip
    case driverCancelIntrip = 45
    case adminCancel = 51
    case otherDriverAccept = 61
    case other = 111
    
    static func <(lhs: TripDetailStatus, rhs: TripDetailStatus) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var prefix: String {
        switch self {
        case .clientCreateBook, .clientTimeout, .clientCancelIntrip, .clientCancelInBook, .clientAgreed:
            return "C-"
        default:
            return "D-"
        }
    }
    
    var key: String {
        let p = self.prefix
        let v = self.rawValue
        return "\(p)\(v)"
    }
}

final class SupplyTripInfo: Codable {
    var productDescription: String?
    var estimatedPrice: Double?
}

struct BasicVehicle: Codable {
    var id: UInt64?
    var plate: String?
    var color: String?
    var brand: String?
    var marketName: String?
    var taxiBrand: Int?
    var taxiBrandName: String?
}

struct BasicUserInfo: Codable {
    var id: UInt64?
    var fullName: String?
    var phone: String?
    var avatarUrl: String?
    var appVersion: String?
}

final class FirebaseTrip: Codable, ModelFromFireBaseProtocol {
    var command: [String: BookCommand] = [:]
    var estimate: Estimate?
    var extra: Extra?
    var info: Info = Info()
    var tracking: [String: Tracking] = [:]
    var last_command: String?
    
    var start_place_id: String?
    var end_place_id: String?
    
    var currentOrderId: String?
    var originalP: UInt32?
    
    var lastCommand: BookCommand? {
        let list = command.reduce(into: [BookCommand]()) { (values, item) in
            values.append(item.value)
        }.sorted(by: <)
        let result = list.last
        return result
    }
    
    var tripStarted: Bool {
        guard let last = lastCommand else {
            return true
        }
        return last.status >= TripDetailStatus.started
    }
    
    enum CodingKeys: String, CodingKey {
        case command
        case estimate
        case extra
        case info
        case tracking
        case last_command
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        command = try values.decode([String: BookCommand].self, forKey: .command)
        info = try values.decode(Info.self, forKey: .info)
        estimate = try values.decodeIfPresent(Estimate.self, forKey: .estimate)
        extra = try values.decodeIfPresent(Extra.self, forKey: .extra)
        if let t = try values.decodeIfPresent([String: Tracking].self, forKey: .tracking) {
            tracking = t
        }
        last_command = try values.decodeIfPresent(String.self, forKey: .last_command)
    }
    
    init() {}

    // MARK: Components
    struct BookCommand: Codable, Comparable, CustomStringConvertible, ModelFromFireBaseProtocol {
        let status: TripDetailStatus
        let time: TimeInterval

        var description: String {
            let date = Date(timeIntervalSince1970: (time / 1000))
            return "\(status) - \(date.description)"
        }

        static func == (lhs: BookCommand, rhs: BookCommand) -> Bool {
            return lhs.status.rawValue == rhs.status.rawValue
        }
        static func < (lhs: BookCommand, rhs: BookCommand) -> Bool {
            return lhs.status.rawValue < rhs.status.rawValue
        }
    }
    
    struct Duration: Equatable {
        let distance: Int
        let duration: Int
        
        static func ==(lhs: Duration, rhs: Duration) -> Bool {
            return lhs.distance == rhs.distance && lhs.duration == rhs.duration
        }
    }

    class Estimate: Codable, Equatable {
        let intripDistance: Int
        let intripDuration: Int
        let receiveDistance: Int
        let receiveDuration: Int
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            intripDistance = (try values.decodeIfPresent(Int.self, forKey: .intripDistance)).orNil(0)
            intripDuration = (try values.decodeIfPresent(Int.self, forKey: .intripDuration)).orNil(0)
            receiveDistance = (try values.decodeIfPresent(Int.self, forKey: .receiveDistance)).orNil(0)
            receiveDuration = (try values.decodeIfPresent(Int.self, forKey: .receiveDuration)).orNil(0)
        }
        
        var inTripDuration: Duration {
            return Duration(distance: intripDistance, duration: intripDuration)
        }
        
        var takeClientDuration: Duration {
            return Duration(distance: receiveDistance, duration: receiveDuration)
        }
        
        static func ==(lhs: Estimate, rhs: Estimate) -> Bool {
            return  lhs.intripDistance == rhs.intripDistance &&
                lhs.intripDuration == rhs.intripDuration &&
                rhs.receiveDistance == rhs.receiveDistance &&
                rhs.receiveDuration == lhs.receiveDuration
        }
    }

    class Extra: Codable, Equatable {
        var driverCash: Double = 0
        var driverCoin: Double = 0
        var satisfied: Bool = false

        var polylineIntrip: String?
        var polylineReceive: String?
        var clientCreditAmount: Double?
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            if let cash = try? values.decode(Double.self, forKey: .driverCash) {
                driverCash = cash
            }
            
            if let coin = try? values.decode(Double.self, forKey: .driverCoin) {
                driverCoin = coin
            }
            
            satisfied = (try values.decodeIfPresent(Bool.self, forKey: .satisfied)) ?? false
            polylineIntrip = try values.decodeIfPresent(String.self, forKey: .polylineIntrip)
            polylineReceive = try values.decodeIfPresent(String.self, forKey: .polylineReceive)
            clientCreditAmount = try values.decodeIfPresent(Double.self, forKey: .clientCreditAmount)
            
        }
        
        init(with driver: DriverSearch, polylineReceive: String?) {
            driverCash = driver.cash
            driverCoin = driver.coin
            satisfied = driver.satisfied
            self.polylineIntrip = polylineReceive
        }
        
        static func ==(lhs: Extra, rhs: Extra) -> Bool {
            return lhs.driverCash == rhs.driverCash &&
                lhs.driverCoin == rhs.driverCoin &&
                lhs.satisfied == rhs.satisfied &&
                lhs.polylineIntrip == rhs.polylineIntrip &&
                lhs.polylineReceive == rhs.polylineReceive
            
        }
    }

    class Info: Codable {
        // Contact
        var clientFirebaseId: String?
        var clientUserId: Int64? // Optional
        var clientVersion: String?
        var contactPhone: String?
        
        var driverFirebaseId: String?
        var driverUserId: Int? // Optional
        var driverVersion: String?
        var taxiBrand: Int?
        var taxiBrandName: String?
        
        // Time to finish
        var duration: Double = 0
        
        // Trip information
        var distance: Double = 0
       
        // Coordinate start
        var startLat: Double = 0
        var startLon: Double = 0
        
        var coordinateStart: CLLocationCoordinate2D {
           return CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
        }
        
        // Coordinate end
        var endLat: Double = 0
        var endLon: Double = 0
        
        var coordinateEnd: CLLocationCoordinate2D {
           return CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
        }
        
        //Name address
        var startAddress: String?
        var startName: String?
        var endAddress: String?
        var endName: String?
        
        // Adjust price
        var fareClientSupport: UInt32 = 0
        var fareDriverSupport: UInt32 = 0
        var farePrice: UInt32 = 0
        var modifierId: Int = 0
        
        // Payment
        var additionPrice: Double = 0
        
        // method
        var payment: Int = 0
        var price: UInt32 = 0
        var cardId: String?
        
        // Promotion
        var promotionDelta: Double = 0
        var promotionMax: Double = 0
        var promotionMin: Double = 0
        var promotionModifierId: Int = 0
        var promotionRatio: Double = 0
        var promotionValue: UInt32 = 0
        var promotionCode: String?
        var promotionToken: String?
        var promotionDescription: String?
    
        // Service
        var serviceId: Int = -1
        var serviceName: String?
        
        // Time create
        var timestamp: TimeInterval = 0
        
        var tripCode: String = ""
        var tripId: String = ""
        
        // Trip type : one touch ? fixed
        var tripType: Int = BookService.fixed
        var note: String?
        
        
        // Transport type
        var vehicleId: Int = 0
        var zoneId: Int = ZoneConstant.vn
        var requestId: String?
        
        //
        var priority: Int = 0
        var favorite: Coordinate?
        
        var startFavoritePlaceId: Int64 = 0
        var endFavoritePlaceId: Int64 = 0
        
        // Delivery
        var senderName: String?
        var senderPhone: String?
        var receiverPhone: String?
        var receiverName: String?
        
        // Reason
        var end_reason_id: Int = 0
        var end_reason_value: String?
        var statusDetail: Int = 0
        var wayPoints: [TripWayPoint]?
        
        // Suplly
        var supplyInfo: SupplyTripInfo?
        
        var originalPrice: UInt32 {
            return (self.farePrice > 0 && self.price != 0) ? self.farePrice : self.price
        }
        
        var fPrice: UInt32 {
            let promoVal = fareClientSupport + promotionValue
            let total = originalPrice + UInt32(self.additionPrice)
            let result = total > promoVal ? total - promoVal : 0;
            return result
        }
        
        
        init() {}
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            clientFirebaseId = try values.decodeIfPresent(String.self, forKey: .clientFirebaseId)
            if let clientUserId = try? values.decode(String.self, forKey: .clientUserId) {
                self.clientUserId = Int64(clientUserId)
            } else {
                clientUserId = try values.decodeIfPresent(Int64.self, forKey: .clientUserId)
            }
            
            clientVersion = try values.decodeIfPresent(String.self, forKey: .clientVersion)
            contactPhone = try values.decodeIfPresent(String.self, forKey: .contactPhone)
            driverFirebaseId = try values.decodeIfPresent(String.self, forKey: .driverFirebaseId)
            if let driverUserId = try? values.decode(String.self, forKey: .driverUserId) {
                self.driverUserId = Int(driverUserId)
            } else {
                driverUserId = try values.decodeIfPresent(Int.self, forKey: .driverUserId)
            }
            
            driverVersion = try values.decodeIfPresent(String.self, forKey: .driverVersion)
            taxiBrand = try values.decodeIfPresent(Int.self, forKey: .taxiBrand)
            taxiBrandName = try values.decodeIfPresent(String.self, forKey: .taxiBrandName)
            duration = try values.decode(Double.self, forKey: .duration)
            distance = try values.decode(Double.self, forKey: .distance)

            startLat = try values.decode(Double.self, forKey: .startLat)
            startLon = try values.decode(Double.self, forKey: .startLon)
            
            endLat = try values.decode(Double.self, forKey: .endLat)
            endLon = try values.decode(Double.self, forKey: .endLon)
            
            startAddress = try values.decodeIfPresent(String.self, forKey: .startAddress)
            startName = try values.decodeIfPresent(String.self, forKey: .startName)
            endAddress = try values.decodeIfPresent(String.self, forKey: .endAddress)
            endName = try values.decodeIfPresent(String.self, forKey: .endName)
            
            fareClientSupport = (try values.decodeIfPresent(UInt32.self, forKey: .fareClientSupport)).orNil(0)
            fareDriverSupport = (try values.decodeIfPresent(UInt32.self, forKey: .fareDriverSupport)).orNil(0)
            farePrice = (try values.decodeIfPresent(UInt32.self, forKey: .farePrice)).orNil(0)
            modifierId = (try values.decodeIfPresent(Int.self, forKey: .modifierId)).orNil(0)
            additionPrice = (try values.decodeIfPresent(Double.self, forKey: .additionPrice)).orNil(0)
            
            payment = (try values.decodeIfPresent(Int.self, forKey: .payment)).orNil(0)
            price = (try values.decodeIfPresent(UInt32.self, forKey: .price)).orNil(0)
            if let c = try? values.decode(Int.self, forKey: .cardId) {
                cardId = "\(c)"
            } else {
                cardId = try values.decodeIfPresent(String.self, forKey: .cardId)
            }
            promotionDelta = (try values.decodeIfPresent(Double.self, forKey: .promotionDelta)).orNil(0)
            promotionMax = (try values.decodeIfPresent(Double.self, forKey: .promotionMax)).orNil(0)
            promotionMin = (try values.decodeIfPresent(Double.self, forKey: .promotionMin)).orNil(0)
            promotionModifierId = (try values.decodeIfPresent(Int.self, forKey: .promotionModifierId)).orNil(0)
            promotionRatio = (try values.decodeIfPresent(Double.self, forKey: .promotionRatio)).orNil(0)
            promotionValue = (try values.decodeIfPresent(UInt32.self, forKey: .promotionValue)).orNil(0)
            promotionCode = try values.decodeIfPresent(String.self, forKey: .promotionCode)
            promotionToken = try values.decodeIfPresent(String.self, forKey: .promotionToken)
            promotionDescription = try values.decodeIfPresent(String.self, forKey: .promotionDescription)

            serviceId = (try values.decodeIfPresent(Int.self, forKey: .serviceId)).orNil(-1)
            serviceName = try values.decodeIfPresent(String.self, forKey: .serviceName)
            timestamp = (try values.decodeIfPresent(TimeInterval.self, forKey: .timestamp)).orNil(0)
            tripCode = (try values.decodeIfPresent(String.self, forKey: .tripCode)).orNil("")
            tripId = (try values.decodeIfPresent(String.self, forKey: .tripId)).orNil("")
            tripType = (try values.decodeIfPresent(Int.self, forKey: .tripType)).orNil(BookService.fixed)
            note = try values.decodeIfPresent(String.self, forKey: .note)
            
            vehicleId = (try values.decodeIfPresent(Int.self, forKey: .vehicleId)).orNil(0)
            zoneId = (try values.decodeIfPresent(Int.self, forKey: .zoneId)).orNil(ZoneConstant.vn)
            requestId = try values.decodeIfPresent(String.self, forKey: .requestId)
            
            priority = (try values.decodeIfPresent(Int.self, forKey: .priority)).orNil(0)
            favorite = try values.decodeIfPresent(Coordinate.self, forKey: .favorite)
            startFavoritePlaceId = (try values.decodeIfPresent(Int64.self, forKey: .startFavoritePlaceId)).orNil(0)
            endFavoritePlaceId = (try values.decodeIfPresent(Int64.self, forKey: .endFavoritePlaceId)).orNil(0)
            senderName = try values.decodeIfPresent(String.self, forKey: .senderName)
            senderPhone = try values.decodeIfPresent(String.self, forKey: .senderPhone)
            receiverPhone = try values.decodeIfPresent(String.self, forKey: .receiverPhone)
            receiverName = try values.decodeIfPresent(String.self, forKey: .receiverName)
            
            end_reason_id = (try values.decodeIfPresent(Int.self, forKey: .end_reason_id)).orNil(0)
            end_reason_value = try values.decodeIfPresent(String.self, forKey: .end_reason_value)
            statusDetail = (try values.decodeIfPresent(Int.self, forKey: .statusDetail)).orNil(0)
            wayPoints = try values.decodeIfPresent([TripWayPoint].self, forKey: .wayPoints)
            supplyInfo = try values.decodeIfPresent(SupplyTripInfo.self, forKey: .supplyInfo)
        }
    }

    class Tracking: Codable {
        var command: TripDetailStatus?

        var clientLocalTime: String?
        var clientLocation: Coordinate?
        var clientTimestamp: TimeInterval?

        var driverLocalTime: String?
        var driverLocation: Coordinate?
        var driverTimestamp: TimeInterval?

        private enum CodingKeys: String, CodingKey {
            case command

            case clientLocalTime = "c_localTime"
            case clientLocation = "c_location"
            case clientTimestamp = "c_timestamp"

            case driverLocalTime = "d_localTime"
            case driverLocation = "d_location"
            case driverTimestamp = "d_timestamp"
        }
    }
    
    func updateInfor(from bookModel: BookingConfirmInformation) {
        info.clientFirebaseId = bookModel.userInfor?.firebaseId
        info.clientUserId = bookModel.userInfor?.id
        info.contactPhone = bookModel.userInfor?.phone
        info.tripType = bookModel.booking?.destinationAddress1 == nil ? BookService.quickBook : BookService.fixed
        info.duration = (bookModel.service?.fare?.trip?.duration.value).orNil(0)
        info.distance = (bookModel.service?.fare?.trip?.distance.value).orNil(0)
        let coordStart = bookModel.booking?.originAddress.coordinate
        info.startLat = coordStart?.latitude ?? 0
        info.startLon = coordStart?.longitude ?? 0
        let coordEnd = bookModel.booking?.destinationAddress1?.coordinate
        info.endLat = coordEnd?.latitude ?? 0
        info.endLon = coordEnd?.longitude ?? 0
        info.fareClientSupport = bookModel.informationPrice?.clientAmount ?? 0
        let m = bookModel.paymentMethod
        info.payment = (m?.type.method ?? PaymentMethodCash).rawValue
        info.note = bookModel.note
        info.cardId = m?.napas == true ? m?.id : nil
        
        info.startName = bookModel.booking?.originAddress.primaryText
        info.startAddress = bookModel.booking?.originAddress.secondaryText
        info.zoneId = bookModel.zone?.id ?? ZoneConstant.vn
        
        info.endName = bookModel.booking?.destinationAddress1?.primaryText
        info.endAddress = bookModel.booking?.destinationAddress1?.secondaryText
        info.serviceId = bookModel.service?.service.id ?? 0
        info.serviceName = bookModel.service?.service.name
        info.modifierId = bookModel.service?.modifier?.id ?? 0
        info.farePrice = bookModel.informationPrice?.originalPrice ?? 0
        info.timestamp = FireBaseTimeHelper.default.currentTime
        info.price = bookModel.service?.fare?.price ?? 0
        info.additionPrice = bookModel.tip.orNil( 0)
        info.senderName = bookModel.senderName
        info.senderPhone = bookModel.userInfor?.phone
        info.receiverName = bookModel.receiverName
        info.receiverPhone = bookModel.receiverPhone
        info.supplyInfo = bookModel.supplyInfo
        if let pModel = bookModel.promotionModel, pModel.canApply {
            info.promotionDelta = pModel.promotionDelta.orNil( 0)
            info.promotionMax = pModel.promotionMax.orNil(0)
            info.promotionMin = pModel.promotionMin.orNil(0)
            info.promotionRatio = pModel.promotionRatio.orNil(0)
            info.promotionModifierId = pModel.modifierId.orNil(0)
            info.promotionValue = pModel.discount
            info.promotionCode = pModel.code
            info.promotionToken = pModel.data?.data?.promotionToken
            info.promotionDescription = pModel.mainfest?.headline
        }
    }
}
