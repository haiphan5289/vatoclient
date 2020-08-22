//  File name   : TicketCalendarInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol TicketCalendarRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TicketCalendarPresentable: Presentable {
    var listener: TicketCalendarPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TicketCalendarListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketCalendarMoveBack()
    func ticketCalendarSelectedDate(date: Date, type: TicketRoundTripType)
}

final class TicketCalendarInteractor: PresentableInteractor<TicketCalendarPresentable> {
    /// Class's public properties.
    weak var router: TicketCalendarRouting?
    weak var listener: TicketCalendarListener?

    private var ticketType: TicketRoundTripType = .startTicket
    /// Class's constructor.
     init(presenter: TicketCalendarPresentable,
          dateSelected: Date?, ticketType: TicketRoundTripType) {
        self.ticketType = ticketType
        super.init(presenter: presenter)
        presenter.listener = self
        if let date = dateSelected {
            dateSelectedSubject.onNext(date)
        }
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

    /// Class's private properties
    private let dateSelectedSubject = ReplaySubject<Date>.create(bufferSize: 1)
    
}

// MARK: TicketCalendarInteractable's members
extension TicketCalendarInteractor: TicketCalendarInteractable {
}

// MARK: TicketCalendarPresentableListener's members
extension TicketCalendarInteractor: TicketCalendarPresentableListener {
    
    var dateSelectedObser: Observable<Date> {
        return dateSelectedSubject.asObserver()
    }
    
    func ticketCalendarSelectedDate(date: Date) {
        self.listener?.ticketCalendarSelectedDate(date: date, type: self.ticketType)
    }
    
    func ticketCalendarMoveBack() {
        self.listener?.ticketCalendarMoveBack()
    }
}

// MARK: Class's private methods
private extension TicketCalendarInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
