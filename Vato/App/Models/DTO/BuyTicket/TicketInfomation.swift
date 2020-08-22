//
//  TicketInfomation.swift
//  Vato
//
//  Created by vato. on 10/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import VatoNetwork

class TicketUser: Codable {
    var phone: String?
    var name: String?
    var email: String?
    var phoneSecond: String?
    var identifyCard: String?
    
    init(phone: String? ,name: String?, email: String?, phoneSecond: String?, identifyCard: String?) {
        self.phone = phone
        self.name = name
        self.email = email
        self.phoneSecond = phoneSecond
        self.identifyCard = identifyCard
    }
}

final class TicketLocation: Codable {
    var code: String
    var name: String
    
    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
    convenience init?(use code: String?, name: String?) {
        guard let c = code , let n = name else { return nil }
        self.init(code: c, name: n)
    }
}

final class TicketInformation {
    var date: Date?
    var originLocation: TicketLocation?
    var destinationLocation: TicketLocation?
    
    var card_fee: Double?
    var routePrice: Double?
    var routeName: String?
    var routeId: Int?
    var routeDistance: Double?
    var routeDuration: Double?
    
    // private var ticketSchedules: TicketSchedules?
    var scheduleTime: String?
    var scheduleKind: String?
    var scheduleId: Int?
    var scheduleWayId: Int?
    
    // var routeStop: RouteStop?
    var routeStopName: String?
    var routeStopAddress: String?
    var routeStopId: Int?
    var officePickupId: Int?
    
    
    var seats: [SeatModel]?
    var totalPrice: Double?
    var user: TicketUser? 
    var ticketsCode: String?
    var detail: TicketHistoryType?
    
    var paymentMethod: PaymentCardDetail?
    
    var ticketPrice: TicketPrice?
    var ticketRoutes: TicketRoutes?
    var promotion: PromotionTicket?
    
    var valid: Bool {
        guard let code = ticketsCode else {
            return false
        }
        return !code.isEmpty
    }
    
    func verifyToChooseBusStatus() -> Bool {
        return (originLocation != nil && destinationLocation != nil )
    }
    
    func getSeatsStr() -> String {
        let seatsStr = seats?.compactMap { $0.chair }
        return seatsStr?.joined(separator: ", ") ?? ""
    }
    
    func generateSaveSeatModel(client: Client, seatsModel: [SeatModel]?, _totalPrice: Double?, discount: String?) -> SaveSeatTicketParamModel? {
        let custName = client.user?.fullName
        let custEmail = user?.email
        let custId = "\(client.user?.id ?? 0)"
        let custMobile = client.user?.phone
        let custCMND = user?.identifyCard ?? ""
        let wayId = Int32(scheduleWayId ?? 0)
        let passengersModel = PassengersTicketModel(CustMobile: user?.phone,
                                                    CustMobile2: user?.phoneSecond,
                                                    CustName: user?.name,
                                                    CustSN: nil,
                                                    CustEmail: user?.email,
                                                    CustCMND: user?.identifyCard)
        let passengersModels = [passengersModel]
        let _seatIds = seatsModel?.compactMap { $0.id }
        let _seatNames = seatsModel?.compactMap { $0.chair }
        let _seatDiscount = seatsModel?.compactMap { $0.discount }
        
        guard let carBookingId = scheduleId,
            let departureDate = self.date?.string(from: "dd-MM-yyyy"),
            let departureTime = self.scheduleTime,
            let numOfTicket = _seatIds?.count,
            numOfTicket > 0,
            let officePickupId = self.officePickupId,
            let pickUpStreet = routeStopAddress,
            let routeId = routeId,
            let routeName = routeName,
            let seatIds = _seatIds,
            let seatNames = _seatNames,
            seatIds.count > 0,
            let seatDiscount = _seatDiscount,
            seatDiscount.count > 0,
            let destCode = destinationLocation?.code,
            let destName = destinationLocation?.name,
            let originCode = originLocation?.code,
            let originName = originLocation?.name,
            let totalPrice = _totalPrice,
            let kind = scheduleKind
            else { return nil }

        
        let pickUpName = routeStopName ?? ""
        let distance = routeDistance ?? 0
        let duration = routeDuration ?? 0
        let price = Int64(totalPrice)
        let carBookingIdStr = "\(carBookingId)"
        
        let type = seats?.filter { ($0.discount ?? 0) > 0  }.first?.promotion?.code ?? ""
        
        return SaveSeatTicketParamModel(CarBookingId: carBookingIdStr, CustAddress: "", CustBirthDay: "", CustCity: "", CustCode: "", CustCountry: "", CustEmail: custEmail, CustId: custId, CustMobile: custMobile, CustMobile2: "", CustName: custName, CustSN: "", DepartureDate: departureDate, DepartureTime: departureTime, EnglishTicket: "", Locale: "", NumOfTicket: numOfTicket, OfficePickupId: officePickupId, Passengers: passengersModels, PickUpStreet: pickUpStreet, RouteId: routeId, RouteName: routeName, SeatDiscounts: seatDiscount, SeatIds: seatIds, SeatNames: seatNames, Version: "", CustState: "", DestCode: destCode, DestName: destName, OriginCode: originCode, OriginName: originName, Price: price, WayId: wayId, PickUpName: pickUpName, Distance: distance, Duration: duration, Kind: kind, code: "", CustCMND: custCMND, PromotionCode: type)
    }
    
    func isReadyChangeTicket() -> Bool {
        let _seatIds = self.seats?.compactMap { $0.id }
        let _seatNames = self.seats?.compactMap { $0.chair }
        
        guard scheduleId != nil,
            self.date != nil,
            self.scheduleTime != nil,
            (_seatIds?.count ?? 0) > 0,
            self.routeStopId != nil,
            routeStopAddress != nil,
            routeId != nil,
            routeName != nil,
            _seatIds != nil,
            _seatNames != nil,
            destinationLocation?.code != nil ,
            destinationLocation?.name != nil ,
            originLocation?.code != nil ,
            originLocation?.name != nil ,
            self.totalPrice != nil ,
            scheduleKind != nil else { return false }
        return true
    }

    func setRoute(ticketRoute: TicketRoutes?) {
        self.ticketRoutes = ticketRoute
        self.routePrice = ticketRoute?.price
        self.routeName = ticketRoute?.name
        self.routeId = ticketRoute?.id
        self.routeDistance = ticketRoute?.distance
        self.routeDuration = ticketRoute?.duration
        self.promotion = ticketRoute?.promotion
    }
    
    func setSchedule(ticketSchedules: TicketSchedules?) {
        self.scheduleTime = ticketSchedules?.time
        self.scheduleKind = ticketSchedules?.kind
        self.scheduleId = ticketSchedules?.id
        self.scheduleWayId = ticketSchedules?.wayId
    }
    
    func setRouteStop(routeStop: RouteStop?) {
       self.routeStopName = routeStop?.name
       self.routeStopAddress = routeStop?.address
//       self.routeStopId = routeStop?.id
        self.officePickupId = routeStop?.officeId
    }
}

extension TicketInformation: HistoryDetailDisplay {
    var originPriceHistory: Int64? {
        return nil
    }
    var seatDiscountsHistory: [Double]? {
        return []
    }
    var seatIdsHistory: [Int32]? {
        return []
    }
    var cardFee: String? {
        return (self.ticketPrice?.fee ?? 0).currency
    }
    
    var paymentCardType: PaymentCardType? {
        return self.paymentMethod?.type
    }
    
    var userName: String? {
        return "\(self.user?.name ?? "")"
    }
    var phone: String? {
        return "\(self.user?.phone ?? "")"
    }
    var routName: String? {
        return "\(routeName ?? "" )"
    }
    var time: String? {
        let dateStr = self.date?.string(from: "dd/MM/yyyy")
        return "\(self.scheduleTime ?? "") \(dateStr)"
    }
    
    var pickupAddress: String? {
        return "\(self.routeStopAddress ?? "")"
    }
    
    var pickup: String? {
        return "\(self.routeStopName ?? "")"
    }
    var numberSeats: String? {
        return "\(self.seats?.count ?? 0)"
    }
    var seatsName: String? {
        return "\(self.getSeatsStr())"
    }
    var priceStr: String? {
        return "\((routePrice ?? 0).currency)"
    }
    var totalPriceStr: String? {
        let lastPrice = self.ticketPrice?.total_amount ?? self.totalPrice
        return "\((lastPrice ?? 0).currency)"
    }
    
    var totalPriceTicket: Double {
        return lastPrice ?? 0
    }
    
    var status: TicketStatus? {
        return nil
    }
    
    var timeExpiredPaymentStr: String? {
        return String(format: Text.formatHours.localizedText, "24")
    }
    
    var totalFeeTicket: Double {
        let r = self.ticketPrice?.fee ?? card_fee
        return r ?? 0
    }
}


extension TicketInformation {
    var lastPrice: Double? {
        return self.ticketPrice?.total_amount ?? self.totalPrice 
    }
}
struct SaveSeatTicketParamModel: Codable {
     let CarBookingId: String?

     let CustAddress: String?

     let CustBirthDay: String?

     let CustCity: String?

     let CustCode: String?

     let CustCountry: String?

     let CustEmail: String?

     let CustId: String?

     let CustMobile: String?

     let CustMobile2: String?

     let CustName: String?

     let CustSN: String?

     let DepartureDate: String?

     let DepartureTime: String?

     let EnglishTicket: String?

     let Locale: String?

     let NumOfTicket: Int?

     let OfficePickupId: Int?

     let Passengers: [PassengersTicketModel]?

     let PickUpStreet: String?

     let RouteId: Int?

     let RouteName: String?

     let SeatDiscounts: [Double]?

     let SeatIds: [Int32]?

     let SeatNames: [String]?

     let Version: String?

     let CustState: String?

     let DestCode: String?

     let DestName: String?

     let OriginCode: String?

     let OriginName: String?

     let Price: Int64?

     let WayId: Int32?

     let PickUpName: String?

     let Distance: Double?

     let Duration: Double?

     let Kind: String?

     let code: String?

     let CustCMND: String?

     var timeExpiredPayment: TimeInterval?
    
    var PromotionCode: String?

//    public init(carBookingId: String?, custAddress: String?, custBirthDay: String?, custCity: String?, custCode: String?, custCountry: String?, custEmail: String?, custId: String?, custMobile: String?, custMobile2: String?, custName: String?, custSN: String?, departureDate: String?, departureTime: String?, englishTicket: Int?, locale: String?, numOfTicket: Int?, officePickupId: Int?, passengers: [VatoNetwork.PassengersModel]?, pickUpStreet: String?, routeId: Int?, routeName: String?, seatDiscounts: [Double]?, seatIds: [Int32]?, seatNames: [String]?, version: Int?, custState: String?, destCode: String?, destName: String?, originCode: String?, originName: String?, price: Int64?, pickUpName: String?, distance: Double?, duration: Double?, wayId: Int32?, kind: String?, custCMND: String?)
//
//    public func toJson() -> [String : Any]

    public enum CodingKeys : String, CodingKey {

        case CarBookingId

        case CustAddress

        case CustBirthDay

        case CustCity

        case CustCode

        case CustCountry

        case CustEmail

        case CustId

        case CustMobile

        case CustMobile2

        case CustName

        case CustSN

        case DepartureDate

        case DepartureTime

        case EnglishTicket

        case Locale

        case NumOfTicket

        case OfficePickupId

        case Passengers

        case PickUpStreet

        case RouteId

        case RouteName

        case SeatDiscounts

        case SeatIds

        case SeatNames

        case Version

        case CustState

        case OriginCode

        case OriginName

        case DestCode

        case DestName

        case Price

        case code

        case PickUpName

        case Distance

        case Duration

        case timeExpiredPayment

        case WayId

        case Kind

        case CustCMND
        
        case PromotionCode
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
//    public init(from decoder: Decoder) throws
}
struct PassengersTicketModel : Codable {

    let CustMobile: String?

    let CustMobile2: String?

    let CustName: String?

    let CustSN: String?

    let CustEmail: String?

    let CustCMND: String?

//    public init(custMobile: String?, custMobile2: String?, custName: String?, custSN: String?, custEmail: String?, custCMND: String?)

//    public func toJson() -> [String : Any]

    public enum CodingKeys : String, CodingKey {

        case CustMobile

        case CustMobile2

        case CustName

        case CustSN

        case CustEmail

        case CustCMND
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
//    public init(from decoder: Decoder) throws
}
