//  File name   : SeatPositionInteractor.swift
//
//  Author      : vato.
//  Created date: 10/8/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

import FwiCoreRX
import Alamofire

protocol SeatPositionRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToConfirmScreen()
    func routeToPayment(streamType: BuslineStreamType)
}

protocol SeatPositionPresentable: Presentable {
    var listener: SeatPositionPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showAlertErrorReChooseSeat(with message: String)
    func showCheckShowEmtyView()
}

protocol SeatPositionListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func seatPositionSaveSuccess(with seats: [SeatModel], totalPrice: Double)
    func chooseSeatPositionMoveBack()
    func moveBackRoot()
    func moveManagerTicket()
}

final class SeatPositionInteractor: PresentableInteractor<SeatPositionPresentable>, ActivityTrackingProtocol {
    /// Class's public properties.
    weak var router: SeatPositionRouting?
    weak var listener: SeatPositionListener?

    /// Class's constructor.
    init(presenter: SeatPositionPresentable,
         authStream: AuthenticatedStream,
         buyTicketStream: BuyTicketStreamImpl,
         mutableProfile: MutableProfileStream,
         streamType: BuslineStreamType,
         type: TicketRoundTripType) {
        self.streamType = streamType
        self.mutableProfile = mutableProfile
        self.buyTicketStream = buyTicketStream
        self.type = type
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
    private let listData = ReplaySubject<[[[SeatModel?]]]>.create(bufferSize: 1)
    private let errorSubject = ReplaySubject<BuyTicketPaymenState>.create(bufferSize: 1)
    private lazy var disposeBag = DisposeBag()
    private var buyTicketStream: BuyTicketStreamImpl
    private var mutableProfile: MutableProfileStream
    private lazy var mProgress = PublishSubject<Double>()
    private let isDiscountTicketObs: PublishSubject<Bool> = PublishSubject.init()
    internal let streamType: BuslineStreamType
    private let type: TicketRoundTripType
}

// MARK: SeatPositionInteractable's members
extension SeatPositionInteractor: SeatPositionInteractable {
    
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
    
    func confirmBuyMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func buyTicketPaymentMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

struct Position: Equatable {
    var x: Int
    var y: Int
    
    static func ==(lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// MARK: SeatPositionPresentableListener's members
extension SeatPositionInteractor: SeatPositionPresentableListener {
    var selectedSeats: Observable<[SeatModel]?> {
        
        return self.type == .startTicket ? buyTicketStream.ticketObservable.map { $0.seats } : buyTicketStream.returnTicketObservable.map { $0.seats }
    }
    
    var error: Observable<BuyTicketPaymenState> {
        return errorSubject.asObserver()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return Observable<(Bool, Double)>.combineLatest(self.indicator.asObservable(), mProgress) {
            return ($0, $1)
        }.observeOn(MainScheduler.asyncInstance)
    }
    
    var isDiscountTicket: Observable<Bool>  {
        return self.isDiscountTicketObs.asObserver()
    }
    
    var listDataObservable: Observable<[[[SeatModel?]]]> {
        return listData.asObserver()
    }
    
    var ticketModel: TicketInformation {
        return self.type == .startTicket ? buyTicketStream.ticketModel : buyTicketStream.returnTicketModel
    }
    
    var wayId: Int {
        return self.ticketModel.scheduleWayId ?? 0
    }
    
    typealias ResponseSeat = VatoNetwork.Response<OptionalMessageDTO<[SeatModel]>>
    func checkLoadCacheListSeats(vatoTicketApi: VatoTicketApi) -> Observable<ResponseSeat> {
        if let r = VatoCacheRequest.shared.load(for: ResponseSeat.self, router: vatoTicketApi) {
            return Observable.just(r)
        } else {
            return  Requester.responseDTO(decodeTo: OptionalMessageDTO<[SeatModel]>.self, using: vatoTicketApi, progress: { [weak self] value in
                self?.mProgress.onNext(value ?? 0)
            })
        }
    }
    
    
    func getListSeat(with routeId: Int?,
                     carBookingId: Int?,
                     kind: String?,
                     departureDate: String?,
                     departureTime: String?) {
        guard let routeId = routeId,
            let carBookingId = carBookingId,
            let kind = kind?.folding(options: .diacriticInsensitive, locale: nil),
            let departureDate = departureDate,
            let departureTime = departureTime else { return }
        
        var vatoTicketApi: VatoTicketApi?
        
        self.request { (token) -> Observable<ResponseSeat> in
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
                    let result: [SeatModel] = r.response.data.orNil(default: []).sorted(by: { $0.position.x < $1.position.x && $0.position.y < $1.position.y })
                    
                    let countDiscount = result.filter { (value) -> Bool in
                        return value.promotion != nil
                    }
                    (countDiscount.count > 0) ? self?.isDiscountTicketObs.onNext(true) : self?.isDiscountTicketObs.onNext(false)
                    
                    if !result.isEmpty,
                        let arrayFloor = self?.makeFloor(with: result),
                        let matrix = self?.createMatrix(with: arrayFloor){
                        self?.listData.onNext(matrix)
                        self?.checkCacheResponseListSeat(arrSeats: result, vatoTicketApi: vatoTicketApi, responseSeat: r)
                    }
                }
                self?.presenter.showCheckShowEmtyView()
                }, onError: { [weak self] (e) in
                    self?.errorSubject.onNext(.errorSystem(err: e))
                    self?.presenter.showCheckShowEmtyView()
            }).disposed(by: self.disposeBag)
    }
    
    private func checkCacheResponseListSeat(arrSeats: [SeatModel?], vatoTicketApi: VatoTicketApi?, responseSeat: ResponseSeat) {
        guard let vatoTicketApi = vatoTicketApi,
            VatoCacheRequest.shared.load(for: ResponseSeat.self, router: vatoTicketApi) == nil else { return }
        
        //bookStatus == 0 && lockChair == 0
        if arrSeats.first(where: { ($0?.bookStatus == 0 &&  $0?.lockChair == 0) }) == nil {
            VatoCacheRequest.shared.cache(response: responseSeat, router: vatoTicketApi, timeCache: 60*60) // cach 1h
        }
    }
    
    private func makeFloor(with array: [SeatModel]) -> [[SeatModel]]  {
        var arrayFloor: [[SeatModel]] = []
        
        let numFloor = array.reduce(0, { max($0, $1.floorNo!)})
        var minFloor = array.reduce(100, { min($0, $1.floorNo!)})
        minFloor = min(numFloor, minFloor)
        (minFloor...numFloor).forEach { (floor) in
            let floorItems = array.filter({ $0.floorNo == floor })
            arrayFloor.append(floorItems)
        }
        
        return arrayFloor
    }
    
    private func createMatrix(with array: [[SeatModel]]) -> [[[SeatModel?]]] {
    
        var result: [[[SeatModel?]]] = []
        for floorItems in array {
            var matrix = [[SeatModel?]]()
            
            let totalRow = floorItems.reduce(0, { max($0, $1.position.x)})
            let totalColumn = floorItems.reduce(0, { max($0, $1.position.y)})
            
            let minRow = min(totalRow,floorItems.reduce(100, { min($0, $1.position.x)}))
            let minColumn = min(totalColumn,floorItems.reduce(100, { min($0, $1.position.y)}))
            
            for _ in minRow...totalRow {
                matrix.append([])
            }
            
            (minRow...totalRow).forEach { (row) in
                var seatPerRow: [SeatModel?] = []
                (minColumn...totalColumn).forEach({ (column) in
                    let value = floorItems.first(where: { $0.position == Position(x: row, y: column)})
                    seatPerRow.append(value)
                    
                })
                
                if seatPerRow.contains(where: { $0 != nil }) {
                    matrix.append(seatPerRow)
                }
            }
            
            result.append(matrix)
        }
        
        return result
    }
    
    func moveNext(with seats: [SeatModel], totalPrice: Double) {
        self.listener?.seatPositionSaveSuccess(with: seats, totalPrice: totalPrice)
//        mutableProfile.client.take(1).bind {[weak self] (client) in
//            self?.requestApi(client: client, seats: seats, totalPrice: totalPrice)
//        }.disposeOnDeactivate(interactor: self)
    }
    
    func moveBack() {
        self.listener?.chooseSeatPositionMoveBack()
    }
}

// MARK: Class's private methods
private extension SeatPositionInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    
    }
    
    private func requestApi(client: Client?, seats: [SeatModel], totalPrice: Double, codeDiscount: String?) {
        guard let client = client,
            let saveSeatParamModel = self.ticketModel.generateSaveSeatModel(client: client, seatsModel: seats, _totalPrice: totalPrice, discount: codeDiscount)
            else { return }
            let url = "\(VatoTicketApi.host)/buslines/futa/ticket"
            let p = try? saveSeatParamModel.toJSON()
            let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: p, useFullPath: true)
            let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
            network.request(using: router,
                            decodeTo: OptionalMessageDTO<SaveSeatTicketParamModel>.self,
                            method: .post,
                            encoding: JSONEncoding.default)
                .trackActivity(self.indicator)
        .bind { [weak self](r) in
            guard let wSelf = self else { return }
                switch r {
                case .success(let r):
                    if r.fail == true {
                        let errType = BuyTicketPaymenState.generateError(status: r.status, message: r.message)
                        wSelf.presenter.showAlertErrorReChooseSeat(with: errType.getMsg())
                    } else {
                        wSelf.buyTicketStream.update(code: r.data?.code ?? "", type: wSelf.type)
                        wSelf.buyTicketStream.update(seats: seats, totalPrice: totalPrice, type: wSelf.type)
                        
                        wSelf.router?.routeToPayment(streamType: self?.streamType ?? .buyNewticket)
                        // self?.listener?.seatPositionSaveSuccess(with: seats, totalPrice: totalPrice)
                    }

                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
}


extension SeatPositionInteractor :RequestInteractorProtocol {
    var token: Observable<String> {
        guard let authStream = self.authStream else { return Observable.empty() }
        return authStream.firebaseAuthToken.take(1)
    }
}
//
