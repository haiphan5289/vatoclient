//
//  BookingHistoryModel.swift
//  Vato
//
//  Created by vato. on 12/26/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

/*
 Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar
 
 */

import Foundation
class BookingHistoryModel: Codable {
    var command: [String: BookCommand] = [:]
    
    var createdBy : Double?
    var updatedBy : Double?
    var createdAt : Double?
    var updatedAt : Double?
    var id : String?
    var additionPrice : Double?
    var type : Int?
    var clientFirebaseId : String?
    var clientId : Int?
    var contactPhone : String?
    var distance : Double?
    var driverFirebaseId : String?
    var driverId : Int?
    var duration : Double?
    var endAddress : String?
    var endLat : Double?
    var endLon : Double?
    var endName : String?
    var price : Double?
    var promotionValue : Double?
    var serviceId : Int?
    var serviceName : String?
    var startAddress : String?
    var startLat : Double?
    var startLon : Double?
    var startName : String?
    var timestamp : Double?
    var zoneId : Int?
    var tripCode : String?
    var status : Int?
    var statusDetail : Int?
    var stage : Int?
    var fee : Double?
    var tax : Double?
    var modifierId : Int?
    var payment : Int?
    var paymentCardId : Int?
    var paymentStatus : Int?
    var farePrice : Double?
    var fareDriverSupport : Double?
    var fareClientSupport : Double?
    var confirmEvaluate : Bool?
    var promotionModifierId : Int?
    var process : Bool?
    var vehicleId : Double?
    var promotionCode : String?
    var promotionToken : String?
    var requestId : String?
    var receivedAt : Double?
    var startedAt : Double?
    var finishedAt : Double?
    var driverFinishLocationLat : Double?
    var driverFinishLocationLon : Double?
    var driverStartLocationLat : Double?
    var driverStartLocationLon : Double?
    var driverAcceptLocationLat : Double?
    var driverAcceptLocationLon : Double?
    var estimatedReceiveDuration : Int?
    var estimatedReceiveDistance : Double?
    var estimatedIntripDuration : Int?
    var estimatedIntripDistance : Double?
    var actualReceiveDuration : Int?
    var actualReceiveDistance : Double?
    var actualIntripDuration : Int?
    var actualIntripDistance : Double?
    var endReasonId : Int?
    
    var wayPoints: [WayPoint]?
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
    
    struct WayPoint: Codable {
        let lat: Double?
        let lon: Double?
        let address: String?        
        let name: String?
        
        var displayName: String? {
            return name ?? address
        }
    }
    
}

extension BookingHistoryModel: BookingHistoryProtocol {
    var waypoints: [PointViewType]? {
        var result: [PointViewType] = []
        let origin = PointViewType.origin(name: originLocation ?? "")
        result.append(origin)
        
        if let wps = self.wayPoints, !wps.isEmpty {
            let e = wps.enumerated().map { (index, p) in
                return PointViewType.destination(index: index+1, name: p.displayName ?? "")
            }
            result.append(contentsOf: e)
            
            let destination = PointViewType.destination(index: wps.count+1, name: destLocation ?? "")
            result.append(destination)
        } else {
            let destination = PointViewType.destination(index: nil, name: destLocation ?? "")
            result.append(destination)

        }
        
        return result
    }
    
    var dateCreate: Date? {
        if let createAt = self.createdAt {
            return Date(timeIntervalSince1970: TimeInterval(createAt/1000))
        }
        return nil
    }
    
    var code: String? {
        return self.tripCode
    }
    
    var originLocation: String? {
        return self.startName ?? self.startAddress
    }
    
    var destLocation: String? {
        return self.endAddress?.orEmpty(self.endName ?? "")
    }
    
    var statusColor: UIColor? {
        var color = UIColor.black
        switch self.statusDetail  {
        case TripDetailStatus.clientCreateBook.rawValue,
             TripDetailStatus.driverAccepted.rawValue,
             TripDetailStatus.clientAgreed.rawValue,
             TripDetailStatus.started.rawValue,
             TripDetailStatus.receivePackageSuccess.rawValue:
            color = #colorLiteral(red: 0.262745098, green: 0.6274509804, blue: 0.2784313725, alpha: 1)
            
        case TripDetailStatus.completed.rawValue:
            color = #colorLiteral(red: 0.262745098, green: 0.6274509804, blue: 0.2784313725, alpha: 1)
            
        case TripDetailStatus.clientTimeout.rawValue,
             TripDetailStatus.clientCancelInBook.rawValue,
             TripDetailStatus.clientCancelIntrip.rawValue:
            color = .orange
            
        case TripDetailStatus.adminCancel.rawValue:
            color = .orange
            
        case TripDetailStatus.driverCancelInBook.rawValue,
             TripDetailStatus.driverCancelIntrip.rawValue:
            color = .orange
            
        case TripDetailStatus.driverMissing.rawValue:
            color = .orange
            
        case TripDetailStatus.deliveryFail.rawValue:
            color = .orange
        default:
            break
        }
        
        return color
    }
        
    var statusStr: String? {
        var status = ""
        switch self.statusDetail {
        case TripDetailStatus.clientCreateBook.rawValue,
             TripDetailStatus.driverAccepted.rawValue,
             TripDetailStatus.clientAgreed.rawValue,
             TripDetailStatus.started.rawValue,
             TripDetailStatus.receivePackageSuccess.rawValue:
            status = Text.inTrip.localizedText
            
        case TripDetailStatus.completed.rawValue:
            status = Text.complete.localizedText
            
        case TripDetailStatus.clientTimeout.rawValue,
             TripDetailStatus.clientCancelInBook.rawValue,
             TripDetailStatus.clientCancelIntrip.rawValue:
            status = Text.clientCancel.localizedText
            
        case TripDetailStatus.adminCancel.rawValue:
            status = Text.adminCancel.localizedText
            
        case TripDetailStatus.driverCancelInBook.rawValue,
             TripDetailStatus.driverCancelIntrip.rawValue:
            status = Text.driverCancelled.localizedText
            
        case TripDetailStatus.driverMissing.rawValue:
            status = Text.driverMissed.localizedText
            
        case TripDetailStatus.deliveryFail.rawValue:
            status = Text.failure.localizedText
        default:
            break
        }
        return status
    }
    
    var priceStr: String? {
        let price = max((self.farePrice ?? 0) - (self.promotionValue ?? 0) + (self.additionPrice ?? 0), 0)
        return price.currency
    }
}
