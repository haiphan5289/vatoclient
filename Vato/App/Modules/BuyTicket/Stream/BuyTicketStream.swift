//  File name   : BuyTicketStream.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift

struct TicketPrice: Codable {
    var amount: Double?
    var fee: Double?
    var payment_method: Int?
    var total_amount: Double?
}

enum BuslineStreamType: Equatable {
    case changeTicket(model: ChangeTicketFeeDisplay)
    case buyNewticket
    case roundTrip
    
    func title() -> String {
        switch self {
        case .changeTicket:
            return Text.changeTicket.localizedText
        case .buyNewticket, .roundTrip:
            return Text.informationTicket.localizedText
        }
    }
    
    static func ==(lhs: BuslineStreamType, rhs: BuslineStreamType) -> Bool {
        switch (lhs, rhs) {
        case (.changeTicket(_), .changeTicket(_)):
            return true
        case (.buyNewticket, .buyNewticket):
            return true
        case (.roundTrip, .roundTrip):
            return true
        default:
            return false
        }
    }
}

enum TicketInputInfoStep: Int, CaseIterable{
    case origin = 0
    case destination = 1
    case dateDepparture = 2
    case route = 3
    case time = 4
    case seats = 5
    case locationPickup = 6
    
}

enum TicketRoundTripType: Int {
    case startTicket = 0
    case returnTicket
}

protocol BuyTicketStreamProtocol {
    var countDown: Observable<String> { get }
    var timeOut: Observable<Void> { get }
    var eMethod: Observable<PaymentCardDetail> { get }
    var ticketInputInfoStep: Observable<TicketInputInfoStep> { get }
    var ticketObservable: Observable<TicketInformation> { get }
    var noteDeliveryObser: Observable<NoteDeliveryModel?> { get }
    var ticketModel: TicketInformation { get }
    
    var note: NoteDeliveryModel? { get }
    
    var isRoundTrip: Bool { get }
    var isRoundTripObservable: Observable<Bool> { get }
    
    var returnTicketInputInfoStep: Observable<TicketInputInfoStep> { get }
    var returnTicketModel: TicketInformation { get }
    var returnTicketObservable: Observable<TicketInformation> { get }
    
    func resetTickets()
}

protocol MutableBuyTicketStreamProtocol: BuyTicketStreamProtocol {
    func startCountDown()
    func stopCountDown()
    
    func updateOriginLocation(ticketLocation: TicketLocation?, type: TicketRoundTripType)
    func updateDestinationLocation(ticketLocation: TicketLocation?, type: TicketRoundTripType)
    func update(date: Date?, type: TicketRoundTripType)
    func update(ticketRoute: TicketRoutes?, type: TicketRoundTripType)
    func update(ticketSchedules: TicketSchedules?, type: TicketRoundTripType)
    func update(routeStop: RouteStop?, type: TicketRoundTripType)
    func update(seats: [SeatModel], totalPrice: Double, type: TicketRoundTripType)
    
    func update(user: TicketUser?, type: TicketRoundTripType)
    func update(method: PaymentCardDetail)
    func update(note: NoteDeliveryModel?)
    func update(ticketInformation: TicketInformation)
    func update(ticketPrice: TicketPrice?)
    func update(isRoundTrip: Bool)
    
    //    func reset()
}

final class BuyTicketStreamImpl {
    
    struct Config {
        static let time = 600
    }
    
    init(with model: TicketInformation) {
        self.ticketModel = model
        setupRX()
    }
    
    func setupRX() {
        mCountdown.map { $0 <= 0}.distinctUntilChanged().filter { $0 }.bind { [weak self](_) in
            self?.mTimeout.onNext(())
        }.disposed(by: disposeBag)
        
        self.mTimeout.bind { [weak self](_) in
            self?.stopCountDown()
        }.disposed(by: disposeBag)
        
        subjectPaymentMethod.bind { [weak self] payment in
            self?.ticketModel.paymentMethod = payment
        }.disposed(by: disposeBag)
    }
    
    // private property
    internal var note: NoteDeliveryModel? {
        didSet {
            subjectNote.onNext(note)
        }
    }
    
    internal var ticketModel = TicketInformation() {
        didSet {
            ticketSubject = ticketModel
        }
    }
    
    internal var returnTicketModel: TicketInformation = TicketInformation() {
        didSet {
            returnTicketSubject = returnTicketModel
        }
    }
    internal var isRoundTrip: Bool = false {
        didSet {
            isRoundTripSubject = isRoundTrip
        }
    }
        
    // subject
    private let subjectPaymentMethod = ReplaySubject<PaymentCardDetail>.create(bufferSize: 1)
    private var subjectNote = ReplaySubject<NoteDeliveryModel?>.create(bufferSize: 1)
    
    @Replay(queue: MainScheduler.asyncInstance) internal var ticketInputInfoStepSubject: TicketInputInfoStep
    @Replay(queue: MainScheduler.asyncInstance) internal var returnTicketInputInfoStepSubject: TicketInputInfoStep

    @Replay(queue: MainScheduler.asyncInstance) internal var ticketSubject: TicketInformation
    @Replay(queue: MainScheduler.asyncInstance) internal var returnTicketSubject: TicketInformation
    @Replay(queue: MainScheduler.asyncInstance) internal var isRoundTripSubject: Bool
    
    private lazy var mTimeout = PublishSubject<Void>()
    private lazy var mCountdown = PublishSubject<Int>()
    var ticketPrice: TicketPrice?
    
    // disposeBag
    private var disposeCountdown: Disposable?
    private lazy var disposeBag = DisposeBag()
    
    func setInputInfoStepFinish(step: TicketInputInfoStep, type: TicketRoundTripType) {
                
        updatTicketInfoStepSubject(type: type, model: step)
        let model = self.getCurrentTicketModel(type: type)
        for value in TicketInputInfoStep.allCases.reversed() {
            switch value {
            case .origin:
                updateDestinationLocation(ticketLocation: nil, type: type)
                model.destinationLocation = nil
            case .destination:
//                update(date: nil)
                break
            case .dateDepparture:
                update(ticketRoute: nil, type: type)
                model.setRoute(ticketRoute: nil)
            case .route:
//                update(ticketSchedules: nil)
                model.setSchedule(ticketSchedules: nil)
                model.totalPrice = 0
                model.seats = []
                model.setRouteStop(routeStop: nil)
                
            case .time:
//                update(seats: [], totalPrice: 0)
                model.totalPrice = 0
                model.seats = []
                model.setRouteStop(routeStop: nil)
                break
                
            case .locationPickup:
                break
            case .seats:
//                update(routeStop: nil)
//                model.setRouteStop(routeStop: nil)
                break
            }
            
            self.updateTicketSubject(type: type, model: model)
            if value == step {
                return
            }
        }
    }
    
    private func getCurrentTicketModel(type: TicketRoundTripType) -> TicketInformation {
        switch type {
        case .startTicket:
            return ticketModel
        case .returnTicket:
            return returnTicketModel
        }
    }
        
    private func updateTicketSubject(type: TicketRoundTripType, model: TicketInformation) {
        if !isRoundTrip {
            ticketSubject = model
        } else {
            switch type {
            case .startTicket:
                ticketSubject = model
            case .returnTicket:
                returnTicketSubject = model
            }
        }
    }
    
    private func updatTicketInfoStepSubject(type: TicketRoundTripType, model: TicketInputInfoStep) {
        if !isRoundTrip {
            ticketInputInfoStepSubject = model
        } else {
            switch type {
            case .startTicket:
                ticketInputInfoStepSubject = model
            case .returnTicket:
                returnTicketInputInfoStepSubject = model
            }
        }
    }
    
}

extension BuyTicketStreamImpl: MutableBuyTicketStreamProtocol {
    var isRoundTripObservable: Observable<Bool> {
        return $isRoundTripSubject
    }
    
    var returnTicketObservable: Observable<TicketInformation> {
        return $returnTicketSubject
    }
    
    
    func updateOriginLocation(ticketLocation: TicketLocation?, type: TicketRoundTripType) {
        let model = self.getCurrentTicketModel(type: type)
        model.originLocation = ticketLocation
        
        self.setInputInfoStepFinish(step: .origin, type: type)
        self.updateTicketSubject(type: type, model: model)
    }
    
    func updateDestinationLocation(ticketLocation: TicketLocation?, type: TicketRoundTripType) {
        let model = self.getCurrentTicketModel(type: type)
        model.destinationLocation = ticketLocation
        
        self.setInputInfoStepFinish(step: .destination, type: type)
        self.updateTicketSubject(type: type, model: model)
    }
    
    func update(date: Date?, type: TicketRoundTripType) {
        let model = self.getCurrentTicketModel(type: type)
        model.date = date
                
        self.setInputInfoStepFinish(step: .dateDepparture, type: type)
        self.updateTicketSubject(type: type, model: model)
       
        // check update start date >  return date
        if self.isRoundTrip {
            guard let startDate = self.ticketModel.date else {
                return
            }
            
            guard let returnDate = self.returnTicketModel.date else {
                self.update(date: startDate, type: .returnTicket)
                return
            }
                               
            if startDate > returnDate {
                let newDate = type == .startTicket ? max(startDate, returnDate) : min(startDate, returnDate)
                let newType: TicketRoundTripType = type == .startTicket ? .returnTicket : .startTicket
                
                
                self.update(date: newDate, type: newType)
            }
        }
    }
    
    func update(ticketRoute: TicketRoutes?, type: TicketRoundTripType) {
        let model = self.getCurrentTicketModel(type: type)
        let current = model.ticketRoutes
        var needUpdate = true
        if let c = current, let new = ticketRoute {
            needUpdate = !(c == new)
        }
    
        guard needUpdate else { return }
        
        model.setRoute(ticketRoute: ticketRoute)
        self.setInputInfoStepFinish(step: .route, type: type)
        self.updateTicketSubject(type: type, model: model)
    }
    
    func update(ticketSchedules: TicketSchedules?, type: TicketRoundTripType) {
        let model = self.getCurrentTicketModel(type: type)

        model.setSchedule(ticketSchedules: ticketSchedules)
        self.setInputInfoStepFinish(step: .time, type: type)
        self.updateTicketSubject(type: type, model: model)
    }
    
    func update(routeStop: RouteStop?, type: TicketRoundTripType) {
        let model = self.getCurrentTicketModel(type: type)

        model.setRouteStop(routeStop: routeStop)
        self.setInputInfoStepFinish(step: .locationPickup, type: type)
        self.updateTicketSubject(type: type, model: model)
    }
    
    func update(seats: [SeatModel], totalPrice: Double, type: TicketRoundTripType) {
        let model = self.getCurrentTicketModel(type: type)

        model.totalPrice = totalPrice
        model.seats = seats
        self.setInputInfoStepFinish(step: .seats, type: type)
        self.updateTicketSubject(type: type, model: model)
    }
    
    func update(note: NoteDeliveryModel?) {
        self.note = note
    }
    
    func update(method: PaymentCardDetail) {
        subjectPaymentMethod.onNext(method)
    }
    
    func update(user: TicketUser?, type: TicketRoundTripType) {
        guard let user = user else { return }
        self.ticketModel.user = user
        self.returnTicketModel.user = user
//        switch type {
//        case .startTicket:
//            self.ticketModel.user = user
//            if self.isRoundTrip {
//                self.returnTicketModel.user = user
//            }
//        default:
//            self.returnTicketModel.user = user
//        }
    }
    
    func update(code: String, type: TicketRoundTripType) {
        if type == .startTicket {
            self.ticketModel.ticketsCode = code
        } else {
            self.returnTicketModel.ticketsCode = code
        }
    }
    
    func update(ticketInformation: TicketInformation) {
        self.ticketModel = ticketInformation
        ticketSubject = self.ticketModel
    }
    
    func update(ticketPrice: TicketPrice?) {
        self.ticketPrice = ticketPrice
        self.ticketModel.ticketPrice = ticketPrice
        self.returnTicketModel.ticketPrice = ticketPrice
        
        ticketSubject = self.ticketModel
        returnTicketSubject = returnTicketModel
    }
    
    func startCountDown() {
        disposeCountdown?.dispose()
        disposeCountdown = Observable<Int>.timer(1, scheduler: MainScheduler.instance).startWith(0).bind { [weak self](times) in
            self?.mCountdown.onNext(Config.time - times)
        }
    }
    
    func stopCountDown() {
        disposeCountdown?.dispose()
    }
    
    func update(isRoundTrip: Bool) {
        self.isRoundTrip = isRoundTrip
        
        if isRoundTrip {
            guard let beforeDate = ticketModel.date else { return }
            let next = Calendar.current.date(byAdding: .day, value: 1, to: beforeDate)
            self.update(date: next, type: .returnTicket)
        }
    }
}

extension BuyTicketStreamImpl {
    var countDown: Observable<String> {
        return mCountdown.filter { $0 >= 0 }.map {
            let minutes = $0 / 60
            let seconds = $0 - (minutes * 60)
            return String(format: "%02d: %02d", minutes, seconds)
        }.observeOn(MainScheduler.asyncInstance)
    }
    
    var timeOut: Observable<Void> {
        return mTimeout.observeOn(MainScheduler.instance)
    }
    
    var eMethod: Observable<PaymentCardDetail> {
        return subjectPaymentMethod.asObserver().distinctUntilChanged()
    }
    
    var noteDeliveryObser: Observable<NoteDeliveryModel?> {
        return subjectNote.asObserver()
    }
    
    var ticketObservable: Observable<TicketInformation> {
        return $ticketSubject
    }
    
    var ticketInputInfoStep: Observable<TicketInputInfoStep> {
        return $ticketInputInfoStepSubject
    }
    
    var returnTicketInputInfoStep: Observable<TicketInputInfoStep> {
        return $returnTicketInputInfoStepSubject
    }
    
    func resetTickets() {
        let newTicket = TicketInformation()
        newTicket.date = ticketModel.date
        newTicket.originLocation = ticketModel.originLocation
        newTicket.destinationLocation = ticketModel.destinationLocation

        newTicket.routeDistance = ticketModel.routeDistance
        newTicket.routeDuration = ticketModel.routeDuration
        newTicket.paymentMethod = ticketModel.paymentMethod
        self.ticketModel = newTicket
        
        let newReturnTicket = TicketInformation()
        newReturnTicket.date = returnTicketModel.date
        self.returnTicketModel = newReturnTicket
        
    }
}
