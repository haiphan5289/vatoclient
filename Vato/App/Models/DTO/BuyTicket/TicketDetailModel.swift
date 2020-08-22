//
//  SaveSeatParamModel.swift
//  VatoNetwork
//
//  Created by THAI LE QUANG on 10/10/19.
//  Copyright © 2019 Dung Vu. All rights reserved.
//

import UIKit
import VatoNetwork
import FwiCore

struct TicketDetailModel: Codable {

    var carBookingId: String?
    var custAddress: String?
    var custBirthDay: String?
    var custCity: String?
    var custCode: String?
    var custCountry: String?
    var custEmail: String?
    var custCMND: String?
    var custId: String?
    var custMobile: String?
    var custMobile2: String?
    var custName: String?
    var custSN: String?
    var departureDate: String?
    var departureTime: String?
    var englishTicket: Int?
    var locale: String?
    var numOfTicket: Int?
    var officePickupId: Int?
    var passengers: [PassengersModel]?
    var pickUpStreet: String?
    var routeId: Int?
    var routeName: String?
    var seatDiscounts: [Double]?
    var seatIds: [Int32]?
    var seatNames: [String]?
    var version: Int?
    var custState: String?
    var destCode: String?
    var destName: String?
    var originCode: String?
    var originName: String?
    var price: Int64?
    var distance: Double?
    var duration: Double?
    var code: String?
    var paymentMethod: Int?
    var statusInt: Int?
    var timeAcceptCancel: TimeInterval?
    var timeAcceptChange: TimeInterval?
    var changeFeeSameRoute: Float?
    var changeFeeDiffRoute: Float?
    var wayId: Int?
    var payment: Bool?
    var feeCancel: Float?
    var timeEstimation: Double?
    var pickUpName: String?
    var kind: String?
    var timeExpiredPayment: TimeInterval?
    var card_fee: Int64?
    var total_price: Int64?
    var originPrice: Int64?
    
    public enum CodingKeys: String, CodingKey {
        
        case carBookingId = "carBookingId"
        case custAddress = "custAddress"
        case custBirthDay = "custBirthDay"
        case custCity = "custCity"
        case custCode = "custCode"
        case custCountry = "custCountry"
        case custEmail = "custEmail"
        case custId = "custId"
        case custMobile = "custMobile"
        case custMobile2 = "custMobile2"
        case custName = "custName"
        case custSN = "custSN"
        case departureDate = "departureDate"
        case departureTime = "departureTime"
        case englishTicket = "englishTicket"
        case locale = "locale"
        case numOfTicket = "numOfTicket"
        case officePickupId = "officePickupId"
        case passengers = "passengers"
        case pickUpStreet = "pickUpStreet"
        case routeId = "routeId"
        case routeName = "routeName"
        case seatDiscounts = "seatDiscounts"
        case seatIds = "seatIds"
        case seatNames = "seatNames"
        case version = "version"
        case custState = "custState"
        case originCode = "originCode"
        case originName = "originName"
        case destCode = "destCode"
        case destName = "destName"
        case price = "price"
        case code = "code"
        case statusInt = "status"
        case timeAcceptCancel = "timeAcceptCancel"
        case payment = "payment"
        case paymentMethod = "paymentMethod"
        case feeCancel = "feeCancel"
        case timeEstimation = "timeEstimation"
        case pickUpName = "pickUpName"
        case timeExpiredPayment = "timeExpiredPayment"
        case timeAcceptChange = "timeAcceptChange"
        case distance = "distance"
        case duration = "duration"
        case wayId = "wayId"
        case kind = "kind"
        case changeFeeSameRoute = "changeFeeSameRoute"
        case changeFeeDiffRoute = "changeFeeDiffRoute"
        case custCMND = "custCMND"
        case card_fee = "card_fee"
        case total_price = "total_price"
        case originPrice = "originPrice"
    }

}

/* -- 2019 - 11 - 11
 // Do
 BOOKING_CANCEL_VATO(1, "CANCEL BY APP VATO", "Khách hàng huỷ vé từ app VATO"),
 BOOKING_CANCEL_FUTA(2, "CANCEL BY FUTA", "Huỷ vé từ FuTa"),
 BOOKING_CANCEL_ADMIN(10, "BOOKING_CANCEL_ADMIN", "Huỷ vé từ Admin"),
 PAYMENT_FAIL(6, "PAYMENT FAIL", "Thanh toán thất bại"),
 CASH_BACK(11, "CASH_BACK", "Hoàn tiền");
 
 // Xanh
 FINISHED(7, "COMPLETE BOOKING", "Xuất vé"),
 PAYMENT_SUCCESS(5, "PAYMENT SUCCESS", "Thanh toán thành công"),
 
 // Cam
 BOOKING(3, "BOOKING", "Đặt giữ vé, chưa thanh toán"),
 PROCESSING_BOOKING(4, "PROCESSING BOOKING", "Giao dịch đang được xử lý"),

 // Xam
 TICKET_UPDATE_FROM_FUTA(8, "UPDATE BY FUTA", "Cập nhật trạng thái từ FUTA"),
 TICKET_WAS_CHANGED(9, "TICKET_WAS_CHANGED", "Vé đã được thay đổi"),
 
*/

enum TicketStatus: Int, Codable {
    case success
    case pending
    case cancel
    case processing
    case unknown
    
    var title: String {
        switch self {
        case .success:
            return Text.success.localizedText
        case .cancel:
            return Text.cancelled.localizedText
        case .pending:
            return Text.pendingPayment.localizedText
        case .processing:
            return Text.processingTransaction.localizedText
        case .unknown:
            return FwiLocale.localized("Không xác định")
        }
    }
    
    var color: UIColor {
        switch self {
        case .success:
            return #colorLiteral(red: 0.2941176471, green: 0.7098039216, blue: 0.03137254902, alpha: 1)
        case .pending:
            return #colorLiteral(red: 0.9333333333, green: 0.5882352941, blue: 0.1568627451, alpha: 1)
        case .cancel:
            return #colorLiteral(red: 0.8784313725, green: 0.1450980392, blue: 0.1450980392, alpha: 1)
        case .processing:
            return #colorLiteral(red: 0.9333333333, green: 0.5882352941, blue: 0.1568627451, alpha: 1)
        case .unknown:
            return #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
        }
    }
    
    static func checkStatus(from type: Int) -> TicketStatus {
        if [1, 2, 6, 10, 11].contains(type) {
            return .cancel
        }
        
        if [5, 7].contains(type) {
            return .success
        }
        
        if [3, 4, 12].contains(type) {
            return .processing
        }
        
        return .unknown
    }
}

extension TicketDetailModel {
    var status: TicketStatus? {
        guard let statusInt = statusInt else { return .unknown }
        return TicketStatus.checkStatus(from: statusInt)
//        if statusInt == 1 || statusInt == 2 {
//            return .cancel
//        }
//        if statusInt == 4 {
//            return .processing
//        }
//        return (payment == true) ? .success : .pending
    }
    
    func feeChangeTicket(newRoute routeId: Int) -> Float {
        if routeId == (self.routeId ?? 0) {
            return self.changeFeeSameRoute ?? 0
        } else {
            return self.changeFeeDiffRoute ?? 0
        }
    }
    
    func valueFeeChangeTicket(newRoute routeId: Int) -> Int64 {
        let feeChange = feeChangeTicket(newRoute: routeId)
        return Int64((Float(self.price ?? 0) * feeChange)/100)
    }
    
    var canChangeTicket: Bool {
        if (self.timeAcceptChange ?? 0) > FireBaseTimeHelper.default.currentTime,
            self.status != .cancel,
            self.payment == true {
            return true
        }
        return false
    }
    
    var canCancelTicket: Bool {
        if (self.timeAcceptCancel ?? 0) > FireBaseTimeHelper.default.currentTime,
            self.status != .cancel {
            return true
        }
        return false
    }
}


extension TicketHistoryType: ActionSelectDisplay {
    var title: String? {
        return String.makeStringWithoutEmpty(from: FwiLocale.localized("Vé"),self.code , seperator: " ")
    }
    
    var isAllowChangeTicket: Bool {
        #warning("tksu - temp hide change ticket in this version")
        return true //self.canChangeTicket
    }
    
    var isAllowCancelTicket: Bool {
        return self.canCancelTicket
    }
    
    var isAllowRebookTicket: Bool {
        return false
    }
    
    var isAllowShareTicket: Bool {
        return false
    }
}

extension TicketDetailModel {
    func convertToTicketInfomationModel() -> TicketInformation {
        let model = TicketInformation()
        model.date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if let dateStr = self.departureDate,
            let date = dateFormatter.date(from:dateStr){
            model.date = date
        }
        model.originLocation = TicketLocation(code: self.originCode ?? "", name: self.originName ?? "")
        model.destinationLocation = TicketLocation(code: self.destCode ?? "", name: self.destName ?? "")
        model.routePrice = Double((self.price ?? 0)/Int64(self.seatIds?.count ?? 1))
        model.routeName = self.routeName
        model.routeId = self.routeId
        model.routeDistance = self.distance
        model.routeDuration = self.duration
        model.scheduleTime = self.departureTime
        model.scheduleKind = self.kind ?? "Giường"
        model.scheduleId = Int(self.carBookingId ?? "0")
        model.scheduleWayId = self.wayId
        model.routeStopName = self.pickUpName
        model.routeStopAddress = self.pickUpStreet
        model.routeStopId = self.officePickupId
        
        var _seats = [SeatModel]()
        self.seatIds?.enumerated().forEach({ (offset, element) in
            var seatModel = SeatModel()
            seatModel.id = element
            seatModel.chair = self.seatNames?[safe: offset] ?? ""
            _seats.append(seatModel)
        })
        model.seats = _seats
        model.totalPrice = Double(self.price ?? 0)
        model.user = TicketUser(phone: self.custMobile, name: self.custName, email: self.custEmail, phoneSecond: "", identifyCard: self.custCMND)
        if let passenger = self.passengers?.first {
            model.user = TicketUser(phone: passenger.custMobile, name: passenger.custName, email: passenger.custEmail, phoneSecond: passenger.custMobile2, identifyCard: self.custCMND)
        }
        model.ticketsCode = self.code
        
        return model
    }
}

extension TicketDetailModel: ChangeTicketFeeDisplay {
    
    var totalStr: String {
        return (self.price ?? 0).currency
    }
    
    var ticketCode: String {
        return self.code ?? ""
    }
    
    func feePercent(newRoute routeId: Int) -> Float {
        return self.feeChangeTicket(newRoute: routeId)
    }
    
    func feeMoney(newRoute routeId: Int) -> Int64 {
        return self.valueFeeChangeTicket(newRoute: routeId)
    }
    
    func totalPrice(newRoute routeId: Int) -> Int64 {
        return self.price ?? 0
    }
    
    var route: String {
        return "\(self.originName ?? "") - \(self.destName ?? "")"
    }
    
    func isSameRoute(newRoute routeId: Int) -> Bool {
        return (self.routeId ?? 0) == routeId
    }
    
    func seatsStr() -> String {
        return seatNames?.joined(separator: ",") ?? ""
    }
}


extension TicketDetailModel: Equatable {
    static func == (lhs: TicketDetailModel, rhs: TicketDetailModel) -> Bool {
        return lhs.code == rhs.code
    }
}
