//  File name   : TicketFillInformationInteractor.swift
//
//  Author      : khoi tran
//  Created date: 4/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Alamofire
import VatoNetwork

protocol TicketFillInformationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType, ticketRoundTripType: TicketRoundTripType)
    func routeToRouteStop(routeStopParam: ChooseRouteStopParam?, currentRouteStopId: Int?, listRouteStop: [RouteStop]?)
    func routToSeatPosition(chooseSeatParam: ChooseSeatParam, streamType: BuslineStreamType, type: TicketRoundTripType)
}


protocol TicketFillInformationPresentable: Presentable {
    var listener: TicketFillInformationPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func updateRouteStop(routeStop: String?)
}

protocol TicketFillInformationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketFillInformationMoveBack()
    func moveBackRoot()
    func moveManagerTicket()
}

final class TicketFillInformationInteractor: PresentableInteractor<TicketFillInformationPresentable> , ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: TicketFillInformationRouting?
    weak var listener: TicketFillInformationListener?
    
    /// Class's constructor.
    init(presenter: TicketFillInformationPresentable,
         buyTicketStream: BuyTicketStreamImpl,
         streamType: BuslineStreamType,
         viewType: BusStationType,
         busStationParam: ChooseBusStationParam?,
         profileStream: ProfileStream,
         ticketRoundTripType: TicketRoundTripType) {
        self.streamType = streamType
        self.buyTicketStream = buyTicketStream
        self.mViewType = viewType
        self.busStationParam = busStationParam
        self.profileStream = profileStream
        self.ticketRoundTripType = ticketRoundTripType
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        
        self.getListBus(with: busStationParam?.originCode, destinationCode: busStationParam?.destinationCode)
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    
    @Published private var errorSubject: BuyTicketPaymenState
    @Replay(queue: MainScheduler.asyncInstance) private var eListBusStation: [TicketRoutes]
    @Replay(queue: MainScheduler.asyncInstance) private var eListTime: [TicketSchedules]
    
    
    private let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    private let streamType: BuslineStreamType
    private let profileStream: ProfileStream

    private var buyTicketStream: BuyTicketStreamImpl
    private var mViewType = BusStationType.ticketRoute
    private var busStationParam: ChooseBusStationParam?
    private let ticketRoundTripType: TicketRoundTripType
    
    private var ticketUser: TicketUser? {
        didSet {
            if let model = ticketUser {
                ticketUserSubject.onNext(model)
            }
        }
    }
    private lazy var ticketUserSubject = ReplaySubject<TicketUser>.create(bufferSize: 1)
    private var isBuyForCurrentUser: Bool = true
    private var currentUser: UserInfo?
    
    private var ticketModel: TicketInformation {
        get {
            switch ticketRoundTripType {
            case .startTicket:
                return buyTicketStream.ticketModel
            case .returnTicket:
                return buyTicketStream.returnTicketModel
            }
        }
    }
        
    private var ticketObservable: Observable<TicketInformation> {
        get {
            switch ticketRoundTripType {
            case .startTicket:
                return buyTicketStream.ticketObservable
            case .returnTicket:
                return buyTicketStream.returnTicketObservable
            }
        }
    }
    
}

// MARK: TicketFillInformationInteractable's members
extension TicketFillInformationInteractor: TicketFillInformationInteractable, Weakifiable {
    var ticketType: TicketRoundTripType {
        return self.ticketRoundTripType
    }
    
    var isRoundTrip: Bool {
        return buyTicketStream.isRoundTrip
    }
    
    var error: Observable<BuyTicketPaymenState> {
        return $errorSubject.observeOn(MainScheduler.asyncInstance)
    }
    var listBusStation: Observable<[TicketRoutes]> {
        return $eListBusStation
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var ticketSchedulesTime: Observable<String?> {
        return self.ticketObservable.map { $0.scheduleTime }
    }
    
    var eTicketModel: Observable<TicketInformation> {
        return self.ticketObservable.observeOn(MainScheduler.asyncInstance)
    }
    
    var dateStart: Date {
        return self.ticketModel.date ?? Date()
    }
    
    var originLocation: TicketLocation? {
        return self.ticketModel.originLocation
    }
    
    var destLocation: TicketLocation? {
        return self.ticketModel.destinationLocation
    }
    
    var ticketUserModel: TicketUser? {
        get {
            return ticketUser
        }
        
        set {
            self.ticketUser = newValue
        }
    }
    
    var ticketUserObser: Observable<TicketUser> {
        return ticketUserSubject.asObserver()
    }
    
    var seats: Observable<[SeatModel]?> {
        return self.ticketObservable.map { $0.seats }
    }
    
    var routeStop: Observable<RouteStop?> {
        return self.ticketObservable.map { RouteStop(with: $0) }
    }
    
    func ticketTimeMoveBack() {
        self.router?.dismissCurrentRoute(true, completion: nil)
    }
    
    func didSelectModel(model: TicketSchedules) {
        self.router?.dismissCurrentRoute(true, completion: weakify({ (wSelf) in
            wSelf.buyTicketStream.update(ticketSchedules: model, type: wSelf.ticketRoundTripType)
            wSelf.router?.dismissCurrentRoute(true, completion: nil)
        }))
    }
    
    func moveBackRoot() {
        self.listener?.moveBackRoot()
    }
    
    func moveManagerTicket() {
        self.listener?.moveManagerTicket()
    }
    
    func ticketFillInformationMoveBack() {
        self.listener?.ticketFillInformationMoveBack()
    }
    
    func getListBus(with originCode: String?, destinationCode: String?) {
        guard let oriCode = originCode,
            let destCode = destinationCode,
            let departureDate = self.ticketModel.date?.string(from: "dd-MM-yyyy") else { return }
        let router = VatoTicketApi.getRouteBetweenTwoPoint(authToken: "", orginCode: oriCode, desCode: destCode, departureDate: departureDate)
        
        network.request(using: router, decodeTo: OptionalMessageDTO<[TicketRoutes]>.self)
            .trackProgressActivity(self.indicator)
            .bind {[weak self] (result) in
                guard let wSelf = self else { return }
                
                switch result {
                case .success(let r):
                    if let data = r.data {
                        wSelf.eListBusStation = data
                    } else {
                        let errType = BuyTicketPaymenState.generateError(status: r.status, message: r.message)
                        wSelf.errorSubject = errType
                    }
                case .failure(let e):
                    wSelf.errorSubject = .errorSystem(err: e)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func routeToRouteStop() {
        let ticketModel = self.ticketModel
        if let routesId = ticketModel.routeId,
            let departureTime = ticketModel.scheduleTime,
            let wayId = self.ticketModel.scheduleWayId,
            let departureDate = ticketModel.date?.string(from: "dd-MM-yyyy") {
            let model = ChooseRouteStopParam(routeId: Int(routesId), departureDate: departureDate, departureTime: departureTime, wayId: Int32(wayId))
            
            
            let router = VatoTicketApi.listStop(authToken: "", routeId: model.routeId, departureDate: model.departureDate, departureTime: model.departureTime, wayId: model.wayId)
                        
            network.request(using: router, decodeTo: OptionalMessageDTO<[RouteStop]>.self)
                .trackProgressActivity(self.indicator)
                .bind {[weak self] (r) in
                guard let wSelf = self else { return }
                switch r {
                case .success(let d):
                    wSelf.router?.routeToRouteStop(routeStopParam: model, currentRouteStopId: ticketModel.routeStopId, listRouteStop: d.data)
                case .failure(_):
                    wSelf.router?.routeToRouteStop(routeStopParam: model, currentRouteStopId: ticketModel.routeStopId, listRouteStop: nil)
                }
            }.disposeOnDeactivate(interactor: self)            
        }
    }
    
    func dismissRouteStop() {
        self.router?.dismissCurrentRoute(true, completion: nil)
    }
    
    func didSelectRouteStop(routeStop: RouteStop) {
        buyTicketStream.update(routeStop: routeStop, type: self.ticketRoundTripType)
        self.router?.dismissCurrentRoute(true, completion: nil)
    }
        
    func seatPositionSaveSuccess(with seats: [SeatModel], totalPrice: Double) {
        self.router?.dismissCurrentRoute(true, completion: weakify({ (wSelf) in
            wSelf.buyTicketStream.update(seats: seats, totalPrice: totalPrice, type: wSelf.ticketRoundTripType)
        }))
    }
    
    func chooseSeatPositionMoveBack() {
        self.router?.dismissCurrentRoute(true, completion: nil)
    }
    
    func resetInfoToCurrent() {
        isBuyForCurrentUser = true
        profileStream.user.take(1).bind {[weak self] (user) in
            self?.currentUser = user
            let ticketUser = TicketUser(phone: user.phone, name: user.fullName, email: user.email, phoneSecond: nil, identifyCard: "")
                        
            if let userSaved = TicketLocalStore.shared.loadDefautUser() {
                if (ticketUser.email ?? "").isEmpty == true {
                    ticketUser.email = userSaved.email
                }
                if (ticketUser.identifyCard ?? "").isEmpty == true {
                    ticketUser.identifyCard = userSaved.identifyCard
                }
            }
            self?.ticketUser = ticketUser
            }.disposeOnDeactivate(interactor: self)
    }
    
    func resetInfo() {
        isBuyForCurrentUser = false
        let ticketUser = TicketUser(phone: "", name: "", email: "", phoneSecond: "", identifyCard: "")
        self.ticketUser = ticketUser
    }
    
    func routeToChooseSeats() {
        self.routeToSeatPosition()
    }
}

// MARK: TicketFillInformationPresentableListener's members
extension TicketFillInformationInteractor: TicketFillInformationPresentableListener {
    func routeToTicketTime() {
        if let routeId = self.ticketModel.routeId,
            let departureDate = self.ticketModel.date?.string(from: "dd-MM-yyyy") {
            let ticketTimeInputModel = TicketTimeInputModel(routeId: Int32(routeId), departureDate: departureDate)
            router?.routeToTime(ticketTimeInputModel: ticketTimeInputModel, streamType: self.streamType, ticketRoundTripType: self.ticketRoundTripType)
        }
    }
    
    func didSelectBusStation(with busStation: TicketRoutes) {
        buyTicketStream.update(ticketRoute: busStation, type: self.ticketRoundTripType)
    }
    
    
    func routeToSeatPosition() {
        buyTicketStream.update(user: ticketUser, type: self.ticketRoundTripType)
        let ticketModel = self.ticketModel
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
                                        pricePerTicket: price,
                                        promotion: ticketModel.promotion,
                                        finalPrice: ticketModel.ticketRoutes?.finalPrice)
            router?.routToSeatPosition(chooseSeatParam: param, streamType: self.streamType, type: self.ticketRoundTripType)
        }
    }
}

// MARK: Class's private methods
private extension TicketFillInformationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        ticketUserSubject.bind(onNext: weakify({ (user, wSelf) in
            wSelf.buyTicketStream.update(user: user, type: .startTicket)
        })).disposeOnDeactivate(interactor: self)
        
        routeStop.bind(onNext: weakify({ (r, wSelf) in
            wSelf.presenter.updateRouteStop(routeStop: r?.address)
        })).disposeOnDeactivate(interactor: self)
    }
}
