//  File name   : ConfirmBuyTicketInteractor.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ConfirmBuyTicketRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToBuyTicketPayment(streamType: BuslineStreamType)
    
    func routeSelectDate(dateSelected: Date?)
    func routeToBusStation(originLocation: TicketLocation, destLocation: TicketLocation, streamType: BuslineStreamType)
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType)
    func routeSelectBusStop()
    func routeSelectSeats()
}

protocol ConfirmBuyTicketPresentable: Presentable {
    var listener: ConfirmBuyTicketPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ConfirmBuyTicketListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func confirmBuyMoveBack()
    func moveBackRoot()
    func moveManagerTicket()
}

final class ConfirmBuyTicketInteractor: PresentableInteractor<ConfirmBuyTicketPresentable> {
    /// Class's public properties.
    weak var router: ConfirmBuyTicketRouting?
    weak var listener: ConfirmBuyTicketListener?

    /// Class's constructor.
    init(presenter: ConfirmBuyTicketPresentable,
         buyTicketStream: BuyTicketStreamImpl) {
        self.buyTicketStream = buyTicketStream
        super.init(presenter: presenter)
        presenter.listener = self
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
    private var buyTicketStream: BuyTicketStreamImpl
}

// MARK: ConfirmBuyTicketInteractable's members
extension ConfirmBuyTicketInteractor: ConfirmBuyTicketInteractable {
    
    func buyTicketPaymenMoveBack() {
        listener?.moveBackRoot()
    }
    
    func moveBackBuyNewTicket() {
        listener?.moveBackRoot()
    }
    
    func moveManagerTicket() {
        listener?.moveManagerTicket()
    }
    
    func moveBackRoot() {
        listener?.moveBackRoot()
    }
    
    func chooseTicketBusStationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: TicketSchedules) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketTimeMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketCalendarMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketCalendarSelectedDate(date: Date, type: TicketRoundTripType) {
        buyTicketStream.update(date: date, type: type)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func buyTicketPaymentMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    
    func ticketBusDidSelect(ticketRoute: TicketRoutes) {
    }
    
    func ticketBusDidSelect(routeStop: RouteStop) {
    }
}

// MARK: ConfirmBuyTicketPresentableListener's members
extension ConfirmBuyTicketInteractor: ConfirmBuyTicketPresentableListener {
    
    var titleButtonContinue: String {
        return Text.buyTicket.localizedText
    }
    
    var ticketModelObser: Observable<TicketInformation> {
        return buyTicketStream.ticketObservable
    }
    
    func routeToBuyTicketPayment() {
        router?.routeToBuyTicketPayment(streamType: .buyNewticket)
    }
    
    func ticketModel() -> TicketInformation? {
        return buyTicketStream.ticketModel
    }
    
    func moveBack() {
        listener?.confirmBuyMoveBack()
    }
    
    func routeSelectDate() {
        router?.routeSelectDate(dateSelected: buyTicketStream.ticketModel.date)
    }
    
    func routeSelectRoute() {
    }
    
    func routeSelectTime() {
        if let routeId = buyTicketStream.ticketModel.routeId,
            let departureDate = buyTicketStream.ticketModel.date?.string(from: "dd-MM-yyyy") {
            let ticketTimeInputModel = TicketTimeInputModel(routeId: Int32(routeId), departureDate: departureDate)
            router?.routeToTime(ticketTimeInputModel: ticketTimeInputModel, streamType: .buyNewticket)
        }
    }
    
    func routeSelectBusStop() {
        router?.routeSelectBusStop()
    }
    
    func routeSelectSeats() {
        router?.routeSelectSeats()
    }
    
}

// MARK: Class's private methods
private extension ConfirmBuyTicketInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
