//  File name   : TicketTimeInteractor.swift
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
import FwiCore
import FwiCoreRX

struct TicketTimeInputModel {
    var routeId: Int32
    var departureDate: String
    
}

protocol TicketTimeRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routToBusStop(model: ChooseRouteStopParam, streamType: BuslineStreamType)
}

protocol TicketTimePresentable: Presentable {
    var listener: TicketTimePresentableListener? { get set }
    func showCheckShowEmtyView()
    func showEmptySeatAlert(message: String)
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TicketTimeListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketTimeMoveBack()
    func didSelectModel(model: TicketSchedules)
    func moveBackRoot()
    func moveManagerTicket()
}

final class TicketTimeInteractor: PresentableInteractor<TicketTimePresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: TicketTimeRouting?
    weak var listener: TicketTimeListener?
    
    /// Class's constructor.
    init(presenter: TicketTimePresentable,
         authStream: AuthenticatedStream,
         buyTicketStream: BuyTicketStreamImpl,
         ticketTimeInputModel: TicketTimeInputModel,
         streamType: BuslineStreamType,
         ticketRoundTripType: TicketRoundTripType) {
        self.streamType = streamType
        self.ticketTimeInputModel = ticketTimeInputModel
        self.authStream = authStream
        self.buyTicketStream = buyTicketStream
        self.ticketRoundTripType = ticketRoundTripType
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        getListTime()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
        disposable?.dispose()
    }
    
    
    
    
    /// Class's private properties.
    private var authStream: AuthenticatedStream?
    private var buyTicketStream: BuyTicketStreamImpl
    private var ticketTimeInputModel: TicketTimeInputModel
    private var ticketRoundTripType: TicketRoundTripType
    
    @Replay(queue: MainScheduler.asyncInstance) private var ticketSchedulesSubject: [TicketSchedules]
    private lazy var isLoading: PublishSubject<Bool> = PublishSubject()
    private let errorSubject = ReplaySubject<BuyTicketPaymenState>.create(bufferSize: 1)
    private lazy var mProgress = PublishSubject<Double>()
    private let streamType: BuslineStreamType
    private var disposable: Disposable?
}

// MARK: TicketTimeInteractable's members
extension TicketTimeInteractor: TicketTimeInteractable {
    
    func moveManagerTicket() {
        listener?.moveManagerTicket()
    }
    
    func moveBackRoot() {
        listener?.moveBackRoot()
    }
    
    func chooseTicketBusStationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseTicketBusStationMoveNext(with routeStop: RouteStop) { }
    
    func ticketBusDidSelect(ticketRoute: TicketRoutes) {}
    
    func ticketBusDidSelect(routeStop: RouteStop) {}
}

// MARK: TicketTimePresentableListener's members
extension TicketTimeInteractor: TicketTimePresentableListener {
    var ticketObservable: Observable<TicketInformation> {
        return ticketRoundTripType == .startTicket ? buyTicketStream.ticketObservable : buyTicketStream.returnTicketObservable
    }
    
    var error: Observable<BuyTicketPaymenState> {
        return errorSubject.asObserver()
    }
    
    func didSelectModel(model: TicketSchedules) {
        switch self.streamType {
        case .changeTicket(_):
            self.listener?.didSelectModel(model: model)
        default:
            self.requestSeatPositions(model: model)
            //            buyTicketStream.update(ticketSchedules: model)
            //            let ticketModel = buyTicketStream.ticketModel
            //            if let routesId = ticketModel.routeId,
            //                let departureTime = model.time,
            //                let wayId = buyTicketStream.ticketModel.scheduleWayId,
            //                let departureDate = ticketModel.date?.string(from: "dd-MM-yyyy") {
            //                let model = ChooseRouteStopParam(routeId: Int(routesId), departureDate: departureDate, departureTime: departureTime, wayId: Int32(wayId))
            //                router?.routToBusStop(model: model, streamType: self.streamType)
            //            }
        }
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return Observable<(Bool, Double)>.combineLatest(self.indicator.asObservable(), mProgress) {
            return ($0, $1)
        }.observeOn(MainScheduler.asyncInstance)
    }
    
    func getListTime() {
        if let authStream = self.authStream {
            authStream.firebaseAuthToken
                .take(1)
                .flatMap({
                    Requester.responseDTO(decodeTo: VatoNetwork.OptionalIgnoreMessageDTO<[TicketSchedules]>.self, using: VatoTicketApi.buslinesSchedules(authToken: $0, routeId: self.ticketTimeInputModel.routeId, departureDate: self.ticketTimeInputModel.departureDate),
                                          method: .get, progress: { [weak self] value in
                                            self?.mProgress.onNext(value ?? 0)
                    })
                })
                .trackActivity(self.indicator)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self](response) in
                    let list = response.response.data.orNil([])
                    self?.ticketSchedulesSubject = list
                    if response.response.fail == true {
                        let errType = BuyTicketPaymenState.generateError(status: response.response.status, message: response.response.message)
                        self?.errorSubject.onNext(errType)
                    }
                    //                    self?.presenter.showCheckShowEmtyView()
                    }, onError: {[weak self] (e) in
                        self?.errorSubject.onNext(.errorSystem(err: e))
                        //                        self?.presenter.showCheckShowEmtyView()
                }).disposeOnDeactivate(interactor: self)
        }
    }
    
    var ticketSchedulesObservable: Observable<[TicketSchedules]> {
        return $ticketSchedulesSubject
    }
    
    func ticketTimeMoveBack() {
        self.listener?.ticketTimeMoveBack()
    }
    
    typealias ResponseSeat = VatoNetwork.Response<OptionalMessageDTO<[SeatModel]>>
    func requestSeatPositions(model: TicketSchedules) {
        disposable?.dispose()
        
        let ticketModel = self.ticketRoundTripType == .startTicket ? buyTicketStream.ticketModel : buyTicketStream.returnTicketModel
        guard let routeId = ticketModel.routeId,
            let carBookingId = model.id,
            let kind = model.kind?.folding(options: .diacriticInsensitive, locale: nil),
            let departureDate = ticketModel.date?.string(from: "dd-MM-yyyy"),
            let departureTime = model.time else { return }
        
        var vatoTicketApi: VatoTicketApi?
        disposable = self.request { (token) -> Observable<ResponseSeat> in
            let api = VatoTicketApi.listSeat(authToken: token, routeId: routeId, carBookingId: carBookingId, kind: kind, departureDate: departureDate, departureTime: departureTime)
            vatoTicketApi = api
            return self.checkLoadCacheListSeats(vatoTicketApi: api)
        }.trackActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (r) in
                if r.response.fail == true {
                    let errType = BuyTicketPaymenState.generateError(status: r.response.status, message: r.response.message)
                    self?.errorSubject.onNext(errType)
                } else {
                    let result: [SeatModel] = r.response.data.orNil([]).sorted(by: { $0.position.x < $1.position.x && $0.position.y < $1.position.y })
                    if !result.isEmpty {
                        self?.checkCacheResponseListSeat(arrSeats: result, vatoTicketApi: vatoTicketApi, responseSeat: r)
                        let filtered = result.filter { $0.isSelectable }
                        
                        if filtered.isEmpty {
                            // cache when no available seats
                            let message = String(format: Text.tripHasNoAvailableSeat.localizedText, departureTime)
                            self?.presenter.showEmptySeatAlert(message: message)
                        } else {
                            self?.listener?.didSelectModel(model: model)
                        }
                    } else  {
                        let message = String(format: Text.tripHasNoAvailableSeat.localizedText, departureTime)
                        self?.presenter.showEmptySeatAlert(message: message)
                    }
                }
                }, onError: { [weak self] (e) in
                    self?.errorSubject.onNext(.errorSystem(err: e))
            })
        
    }
    func checkLoadCacheListSeats(vatoTicketApi: VatoTicketApi) -> Observable<ResponseSeat> {
        if let r = VatoCacheRequest.shared.load(for: ResponseSeat.self, router: vatoTicketApi) {
            return Observable.just(r)
        } else {
            return  Requester.responseDTO(decodeTo: OptionalMessageDTO<[SeatModel]>.self, using: vatoTicketApi, progress: { [weak self] value in
                self?.mProgress.onNext(value ?? 0)
            })
        }
    }
    
    private func checkCacheResponseListSeat(arrSeats: [SeatModel?], vatoTicketApi: VatoTicketApi?, responseSeat: ResponseSeat) {
        guard let vatoTicketApi = vatoTicketApi,
            VatoCacheRequest.shared.load(for: ResponseSeat.self, router: vatoTicketApi) == nil else { return }
        
        //bookStatus == 0 && lockChair == 0
        if arrSeats.first(where: { ($0?.bookStatus == 0 &&  $0?.lockChair == 0) }) == nil {
            VatoCacheRequest.shared.cache(response: responseSeat, router: vatoTicketApi, timeCache: 5*60) // cach 5min
        }
    }
}

// MARK: Class's private methods
private extension TicketTimeInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}

extension TicketTimeInteractor :RequestInteractorProtocol {
    var token: Observable<String> {
        guard let authStream = self.authStream else { return Observable.empty() }
        return authStream.firebaseAuthToken.take(1)
    }
}
