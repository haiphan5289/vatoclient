//  File name   : ChangeTicketInteractor.swift
//
//  Author      : MacbookPro
//  Created date: 11/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ChangeTicketRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType)
    func routeToChooseDate(dateSelected: Date?)
    func routeToBusStation(originLocation: TicketLocation, destLocation: TicketLocation, streamType: BuslineStreamType)
    func routToBusStop(model: ChooseRouteStopParam, streamType: BuslineStreamType)
    func routToSeatPosition(chooseSeatParam: ChooseSeatParam, streamType: BuslineStreamType)
    func routeToStartLocation(startLocation: TicketLocation?)
    func routeToDestinationLocation(startLocation: TicketLocation?,
                                    destinationLocation: TicketLocation?)
    func routeToConfirmPayment(streamType: BuslineStreamType)
}

protocol ChangeTicketPresentable: Presentable {
    var listener: ChangeTicketPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ChangeTicketListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func changeTicketMoveBack()
    func moveBackBuyNewTicket()
    func moveBackRoot()
    func moveManagerTicket()
}

final class ChangeTicketInteractor: PresentableInteractor<ChangeTicketPresentable> {
    /// Class's public properties.
    weak var router: ChangeTicketRouting?
    weak var listener: ChangeTicketListener?

    /// Class's constructor.
    init(presenter: ChangeTicketPresentable,
         buyTicketStream: BuyTicketStreamImpl,
         model: TicketHistoryType) {
        self.model = model
        self.buyTicketStream = buyTicketStream
        streamType = .changeTicket(model: self.model)
        super.init(presenter: presenter)
        presenter.listener = self
        buyTicketStream.update(ticketInformation: model.convertToTicketInfomationModel())
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    var buyTicketStream: BuyTicketStreamImpl
    let model: TicketHistoryType
    let streamType: BuslineStreamType
}

// MARK: ChangeTicketInteractable's members
extension ChangeTicketInteractor: ChangeTicketInteractable {
    
    func buyTicketPaymenMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackBuyNewTicket() {
        listener?.moveBackBuyNewTicket()
    }
    
    func buyTicketPaymentMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackRoot() {
        listener?.moveBackRoot()
    }
    
    func moveManagerTicket() {
        listener?.moveManagerTicket()
    }
    
    // TicketChooseDestinationListener
    func updatePoint(type: DestinationType, point: TicketLocation) {
        buyTicketStream.update(date: nil, type: .startTicket)
        if type == .origin {
            buyTicketStream.updateOriginLocation(ticketLocation: point, type: .startTicket)
        } else {
            buyTicketStream.updateDestinationLocation(ticketLocation: point, type: .startTicket)
        }
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseDestinationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    // TicketTimeListener
    func ticketTimeMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: TicketSchedules) {
        buyTicketStream.update(ticketSchedules: model, type: .startTicket)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    // ticketCalendar
    func ticketCalendarMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketCalendarSelectedDate(date: Date, type: TicketRoundTripType) {
        buyTicketStream.update(date: date, type: .startTicket)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    // TicketBusStationListener
    func chooseTicketBusStationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketBusDidSelect(ticketRoute: TicketRoutes) {
        buyTicketStream.update(ticketRoute: ticketRoute, type: .startTicket)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketBusDidSelect(routeStop: RouteStop) {
        buyTicketStream.update(routeStop: routeStop, type: .startTicket)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    // SeatPositionListener
    func seatPositionSaveSuccess(with seats: [SeatModel], totalPrice: Double) {
        buyTicketStream.update(seats: seats, totalPrice: totalPrice, type: .startTicket)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseSeatPositionMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
}

// MARK: ChangeTicketPresentableListener's members
extension ChangeTicketInteractor: ChangeTicketPresentableListener {
    
    var ticketInputInfoStep: Observable<TicketInputInfoStep> {
        return buyTicketStream.ticketInputInfoStep
    }

    func routeToConfirmPayment() {
        router?.routeToConfirmPayment(streamType: BuslineStreamType.changeTicket(model: self.model))
    }
    
    var ticketObservable: Observable<TicketInformation> {
        return buyTicketStream.ticketObservable
    }
    
    func changeTicketMoveBack() {
        listener?.changeTicketMoveBack()
    }
    
    func didSelectType(type: TicketInputInfoStep) {
        switch type {
        case .origin:
            let originLocation = buyTicketStream.ticketModel.originLocation
            router?.routeToStartLocation(startLocation: originLocation)
            break
        case .destination:
            let originLocation = buyTicketStream.ticketModel.originLocation
            let destinationLocation = buyTicketStream.ticketModel.destinationLocation
            router?.routeToDestinationLocation(startLocation: originLocation,
                                               destinationLocation: destinationLocation)
            break
        case .dateDepparture:
            guard buyTicketStream.ticketModel.originLocation != nil,
                buyTicketStream.ticketModel.destinationLocation != nil else { return }
            let dateSelected = buyTicketStream.ticketModel.date
            router?.routeToChooseDate(dateSelected: dateSelected)
            break
        case .route:
            guard let originLocation = buyTicketStream.ticketModel.originLocation,
                let destLocation = buyTicketStream.ticketModel.destinationLocation else { return }
            router?.routeToBusStation(originLocation: originLocation, destLocation: destLocation, streamType: self.streamType)
            break
        case .time:
            if let routeId = buyTicketStream.ticketModel.routeId,
                let departureDate = buyTicketStream.ticketModel.date?.string(from: "dd-MM-yyyy") {
                let ticketTimeInputModel = TicketTimeInputModel(routeId: Int32(routeId), departureDate: departureDate)
                router?.routeToTime(ticketTimeInputModel: ticketTimeInputModel, streamType: self.streamType)
            }
            break
        case .locationPickup:
            let ticketModel = buyTicketStream.ticketModel
            if let routesId = ticketModel.routeId,
                let departureTime = ticketModel.scheduleTime,
                let wayId = buyTicketStream.ticketModel.scheduleWayId,
                let departureDate = ticketModel.date?.string(from: "dd-MM-yyyy") {
                let model = ChooseRouteStopParam(routeId: Int(routesId), departureDate: departureDate, departureTime: departureTime, wayId: Int32(wayId))
                router?.routToBusStop(model: model, streamType: self.streamType)
            }
            break
        case .seats:
            let ticketModel = buyTicketStream.ticketModel
            if let routeId = ticketModel.routeId,
                let carBookingId = ticketModel.scheduleId,
                let kind = ticketModel.scheduleKind,
                let time = ticketModel.scheduleTime,
                let price = ticketModel.routePrice,
                let date = ticketModel.date?.string(from: "dd-MM-yyyy") {
                let param = ChooseSeatParam(routeId: routeId,
                                            carBookingId: carBookingId,
                                            kind: kind,
                                            departureDate: date,
                                            departureTime: time,
                                            pricePerTicket: price)
                
                router?.routToSeatPosition(chooseSeatParam: param, streamType: self.streamType)
            }
            break
        }
    }
}

// MARK: Class's private methods
private extension ChangeTicketInteractor {
    private func setupRX() {
        let card = loadMethod(by: PaymentMethodVATOPay)
        buyTicketStream.update(method: card)
        // todo: Bind data stream here.
    }
    
    private func loadMethod(by m: PaymentMethod) -> PaymentCardDetail {
        switch m {
        case PaymentMethodVATOPay:
            return PaymentCardDetail.vatoPay()
        default:
            return PaymentCardDetail.cash()
        }
    }
}
