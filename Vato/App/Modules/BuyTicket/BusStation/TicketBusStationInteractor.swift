//  File name   : TicketBusStationInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

import FwiCoreRX

protocol TicketBusStationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType)
    func routToSeatPosition(chooseSeatParam: ChooseSeatParam, streamType: BuslineStreamType)
}

protocol TicketBusStationPresentable: Presentable {
    var listener: TicketBusStationPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showCheckShowEmtyView()
}

protocol TicketBusStationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func chooseTicketBusStationMoveBack()
    func moveBackRoot()
    func moveManagerTicket()
    func ticketBusDidSelect(ticketRoute: TicketRoutes)
    func ticketBusDidSelect(routeStop: RouteStop)
}

final class TicketBusStationInteractor: PresentableInteractor<TicketBusStationPresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: TicketBusStationRouting?
    weak var listener: TicketBusStationListener?

    /// Class's constructor.
    init(presenter: TicketBusStationPresentable,
         authStream: AuthenticatedStream,
         buyTicketStream: BuyTicketStreamImpl,
         streamType: BuslineStreamType) {
        self.streamType = streamType
        self.buyTicketStream = buyTicketStream
        super.init(presenter: presenter)
        presenter.listener = self
        self.authStream = authStream
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
    private var authStream: AuthenticatedStream?
    private let listData = ReplaySubject<[Any]>.create(bufferSize: 1)
    private lazy var disposeBag = DisposeBag()
    private var buyTicketStream: BuyTicketStreamImpl
    private lazy var errorSubject: PublishSubject<BuyTicketPaymenState> = PublishSubject()
    private lazy var mProgress = PublishSubject<Double>()
    private let streamType: BuslineStreamType
}

// MARK: TicketBusStationInteractable's members
extension TicketBusStationInteractor: TicketBusStationInteractable {
    
    func moveManagerTicket() {
        listener?.moveManagerTicket()
    }
    
    func moveBackRoot() {
        listener?.moveBackRoot()
    }
    
    func seatPositionSaveSuccess(with seats: [SeatModel], totalPrice: Double) {}
    
    func didSelectModel(model: TicketSchedules) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseSeatPositionMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketTimeMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: TicketBusStationPresentableListener's members
extension TicketBusStationInteractor: TicketBusStationPresentableListener {
    var error: Observable<BuyTicketPaymenState> {
        return errorSubject.asObserver()
    }
    
    func getListBus(with originCode: String?, destinationCode: String?) {
        guard let oriCode = originCode,
            let destCode = destinationCode,
            let departureDate = buyTicketStream.ticketModel.date?.string(from: "dd-MM-yyyy") else { return }
        
        self.authStream?.firebaseAuthToken.take(1).map {
            VatoTicketApi.getRouteBetweenTwoPoint(authToken: $0, orginCode: oriCode, desCode: destCode, departureDate: departureDate)
            }.flatMap {
                Requester.responseDTO(decodeTo: OptionalMessageDTO<[TicketRoutes]>.self, using: $0, progress: { [weak self] value in
                    self?.mProgress.onNext(value ?? 0)
                })
            }.trackActivity(self.indicator)
            .subscribe(onNext: { [weak self] (r) in

                let result: [TicketRoutes] = r.response.data.orNil(default: [])

                self?.listData.onNext(result)
                if r.response.fail == true {
                    let errType = BuyTicketPaymenState.generateError(status: r.response.status, message: r.response.message)
                    self?.errorSubject.onNext(errType)
                }
                self?.presenter.showCheckShowEmtyView()
            }, onError: {[weak self] (e) in
                    self?.errorSubject.onNext(.errorSystem(err: e))
                    self?.presenter.showCheckShowEmtyView()
            }).disposed(by: self.disposeBag)
    }
    
    func getListStop(with routeStopParam: ChooseRouteStopParam?) {
        guard let routeId = routeStopParam?.routeId,
            let departureDate = routeStopParam?.departureDate,
            let departureTime = routeStopParam?.departureTime,
            let wayId = routeStopParam?.wayId else { return }
        
        self.authStream?.firebaseAuthToken.take(1).map {
            VatoTicketApi.listStop(authToken: $0, routeId: routeId, departureDate: departureDate, departureTime: departureTime, wayId: wayId)
            }.flatMap {
                Requester.responseDTO(decodeTo: OptionalMessageDTO<[RouteStop]>.self, using: $0, progress: { [weak self] value in
                    self?.mProgress.onNext(value ?? 0)
                })
            }.trackActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (r) in
                
                let result: [RouteStop] = r.response.data.orNil(default: [])
                self?.listData.onNext(result)
                
                if r.response.fail == true {
                    let errType = BuyTicketPaymenState.generateError(status: r.response.status, message: r.response.message)
                    self?.errorSubject.onNext(errType)
                }
                self?.presenter.showCheckShowEmtyView()
            }, onError: {[weak self] (e) in
                    self?.errorSubject.onNext(.errorSystem(err: e))
                    self?.presenter.showCheckShowEmtyView()
            }).disposed(by: self.disposeBag)
    }
    
    var listDataObservable: Observable<[Any]> {
        return listData.asObserver()
    }
    
    func moveNext(with busStation: TicketRoutes) {
        switch self.streamType {
        case .changeTicket(model: _):
            self.listener?.ticketBusDidSelect(ticketRoute: busStation)
        default:
            buyTicketStream.update(ticketRoute: busStation, type: .startTicket)
            if let routeId = buyTicketStream.ticketModel.routeId,
                let departureDate = buyTicketStream.ticketModel.date?.string(from: "dd-MM-yyyy") {
                let ticketTimeInputModel = TicketTimeInputModel(routeId: Int32(routeId), departureDate: departureDate)
                router?.routeToTime(ticketTimeInputModel: ticketTimeInputModel, streamType: self.streamType)
            }
        }
    }
    
    func moveNext(with routeStop: RouteStop) {
        switch self.streamType {
        case .changeTicket(model: _):
            self.listener?.ticketBusDidSelect(routeStop: routeStop)
        default:
            buyTicketStream.update(routeStop: routeStop, type: .startTicket)
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
        }
    }
    
    func moveBack() {
        listener?.chooseTicketBusStationMoveBack()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return Observable<(Bool, Double)>.combineLatest(self.indicator.asObservable(), mProgress) {
            return ($0, $1)
            }.observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: Class's private methods
private extension TicketBusStationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
