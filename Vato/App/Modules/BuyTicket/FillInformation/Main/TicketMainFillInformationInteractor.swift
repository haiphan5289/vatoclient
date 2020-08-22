//  File name   : TicketMainFillInformationInteractor.swift
//
//  Author      : khoi tran
//  Created date: 5/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire


protocol TicketMainFillInformationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func attachFillInformation(isRoundTrip: Bool, type: TicketRoundTripType, busStationParam: ChooseBusStationParam?)
    
    func routeToPayment(streamType: BuslineStreamType)
    func initChildScreens(isRoundTrip: Bool, startTripBusStationParam: ChooseBusStationParam?, returnTripBusStationParam: ChooseBusStationParam?)
}

protocol TicketMainFillInformationPresentable: Presentable {
    var listener: TicketMainFillInformationPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showAlertError(e: BuyTicketPaymenState)
    func addChildPageController(_ childVC: UIViewController)
}

protocol TicketMainFillInformationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketMainFillInformationMoveBack()
    func moveBackBuyNewTicket()
    func moveBackRoot()
    func moveManagerTicket()
}

final class TicketMainFillInformationInteractor: PresentableInteractor<TicketMainFillInformationPresentable>, ActivityTrackingProgressProtocol, Weakifiable {
    /// Class's public properties.
    weak var router: TicketMainFillInformationRouting?
    weak var listener: TicketMainFillInformationListener?
    var eventsForm: [Observable<Bool>] = []
    /// Class's constructor.
    init(presenter: TicketMainFillInformationPresentable, streamType: BuslineStreamType, profileStream: ProfileStream, buyTicketStream: BuyTicketStreamImpl, authStream: AuthenticatedStream) {
        self.streamType = streamType
        self.profileStream = profileStream
        self.buyTicketStream = buyTicketStream
        self.authStream = authStream
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
    private let streamType: BuslineStreamType
    private let profileStream: ProfileStream
    private var buyTicketStream: BuyTicketStreamImpl
    private let authStream: AuthenticatedStream
    
    
}

// MARK: TicketMainFillInformationInteractable's members
extension TicketMainFillInformationInteractor: TicketMainFillInformationInteractable {
    func buyTicketPaymenMoveBack() {
        listener?.moveBackRoot()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func buyTicketPaymentMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackBuyNewTicket() {
        self.listener?.moveBackBuyNewTicket()
    }
    
    func ticketFillInformationMoveBack() {
        
    }
    
    func addChildPageController(_ childVC: UIViewController) {
        presenter.addChildPageController(childVC)
    }
    
    func moveBackRoot() {
        self.listener?.moveBackRoot()
    }
    
    func moveManagerTicket() {
        self.listener?.moveManagerTicket()
    }
    
    struct SeatModelResponse: Codable {
        public var card_fee: Double?
        public let carBookingId: String?
        public let custAddress: String?
        public let custBirthDay: String?
        public let custCity: String?
        public let custCode: String?
        public let custCountry: String?
        public let custEmail: String?
        public let custId: String?
        public let custMobile: String?
        public let custMobile2: String?
        public let custName: String?
        public let custSN: String?
        public let departureDate: String?
        public let departureTime: String?
        public let englishTicket: Int?
        public let locale: String?
        public let numOfTicket: Int?
        public let officePickupId: Int?
        public let passengers: [PassengersTicketModel]?
        public let pickUpStreet: String?
        public let routeId: Int?
        public let routeName: String?
        public let seatDiscounts: [Double]?
        public let seatIds: [Int32]?
        public let seatNames: [String]?
        public let version: Int?

        public let custState: String?

        public let destCode: String?

        public let destName: String?

        public let originCode: String?

        public let originName: String?

        public let price: Int64?

        public let wayId: Int32?

        public let pickUpName: String?

        public let distance: Double?

        public let duration: Double?

        public let kind: String?

        public let code: String?

        public let custCMND: String?

        public var timeExpiredPayment: TimeInterval?
        
        public var discount: Double?
        
        public var promotion: Double?
        
        public var originPrice: Double?
        
        public var total_price: Double?
        
        
    }
    
    typealias ResultBuyTicket = OptionalIgnoreMessageDTO<SeatModelResponse>
    typealias ResponseTicket = Swift.Result<ResultBuyTicket, Error>
    
    private func requestSeatApi(saveSeatParamModel: SaveSeatTicketParamModel?) -> Observable<ResponseTicket> {
        guard let saveSeatParamModel = saveSeatParamModel else {
            return Observable.empty()
        }
        let url = "\(VatoTicketApi.host)/buslines/futa/ticket"
        let p = try? saveSeatParamModel.toJSON()
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: p, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router,
                        decodeTo: ResultBuyTicket.self,
                        method: .post,
                        encoding: JSONEncoding.default)
    }
    
    private func generateRequestBuyTicketEvent(client: Observable<Client>,
                                        info: Observable<TicketInformation>) -> Observable<ResponseTicket>
    {
       return Observable.zip(client, info) { (c, t) -> SaveSeatTicketParamModel? in
            guard let seats = t.seats,
                let totalPrice = t.totalPrice else
            { return nil }
        let saveSeatParamModel = t.generateSaveSeatModel(client: c, seatsModel: seats, _totalPrice: totalPrice, discount: t.promotion?.code)
            return saveSeatParamModel
            }.filterNil().flatMap { [weak self](p) -> Observable<ResponseTicket> in
                guard let wSelf = self else {
                    return Observable.empty()
                }
                return wSelf.requestSeatApi(saveSeatParamModel: p)
        }
    }
    
    private func requestBuyTicket() -> Observable<(start: ResponseTicket, end: ResponseTicket?)> {
        let e1 = profileStream.client.take(1)
        let e2 = buyTicketStream.ticketObservable.take(1)
        
        if buyTicketStream.isRoundTrip {
            let e3 = buyTicketStream.returnTicketObservable.take(1)
            let b1 = generateRequestBuyTicketEvent(client: e1, info: e2)
            let b2 = generateRequestBuyTicketEvent(client: e1, info: e3)
            return Observable.zip(b1, b2) { return ($0, $1)}
        } else {
            return generateRequestBuyTicketEvent(client: e1, info: e2).map { ($0, nil) }
        }
    }
    
    private func validateResponse(res: ResponseTicket?, roundTripType: TicketRoundTripType) -> BuyTicketPaymenState? {
        guard let res = res else { return nil }
        switch res {
        case .success(let r):
            if r.error != nil {
                return BuyTicketPaymenState.other(message: r.message ?? "")
            }
            self.buyTicketStream.update(code: r.data?.code ?? "", type: roundTripType)
            if roundTripType == .returnTicket {
                self.buyTicketStream.ticketModel.card_fee = r.data?.card_fee
            } else {
                self.buyTicketStream.returnTicketModel.card_fee = r.data?.card_fee
            }
            return nil
        case .failure(let e):
            return BuyTicketPaymenState.other(message: e.localizedDescription)
        }
    }
    
    func routeToTicketPayment() {
        requestBuyTicket().trackProgressActivity(indicator).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                var arrayError = [BuyTicketPaymenState]()
                // Check
                // Start
                if let v1 = wSelf.validateResponse(res: res.start, roundTripType: .startTicket) {
                    arrayError.append(v1)
                }
                
                if let v2 = wSelf.validateResponse(res: res.end, roundTripType: .returnTicket) {
                    arrayError.append(v2)
                }
                
                guard !arrayError.isEmpty else {
                    wSelf.router?.routeToPayment(streamType: wSelf.streamType)
                    return
                }
                
                if arrayError.count == 2 {
                    wSelf.presenter.showAlertError(e: .bookTicketNotSuccess)
                } else {
                    guard let f = arrayError.first else { return }
                    wSelf.presenter.showAlertError(e: f)
                }
                
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    
    private func requestSaveSeatApi(saveSeatParamModel: SaveSeatParamModel?) -> Observable<OptionalMessageDTO<SaveSeatParamModel>> {
        
        guard let saveSeatParamModel = saveSeatParamModel else {
            return Observable.empty()
        }
        return authStream.firebaseAuthToken.take(1).flatMap{ (token ) -> Observable<(HTTPURLResponse, OptionalMessageDTO<SaveSeatParamModel>)> in
            Requester.requestDTO(using: VatoTicketApi.saveSeat(authToken: token, param: saveSeatParamModel), method: .post, encoding: JSONEncoding.default)
        }
        .observeOn(MainScheduler.asyncInstance)
        .trackProgressActivity(self.indicator)
        .map { $0.1 }
    }
    
}

// MARK: TicketMainFillInformationPresentableListener's members
extension TicketMainFillInformationInteractor: TicketMainFillInformationPresentableListener {
    var isRoundTrip: Observable<Bool> {
        return buyTicketStream.isRoundTripObservable
    }
    
    func initChildren() {
        guard let originLocation = self.buyTicketStream.ticketModel.originLocation,
            let destLocation = self.buyTicketStream.ticketModel.destinationLocation else { return }
        
        let startTripModel = ChooseBusStationParam(originCode: originLocation.code, destinationCode: destLocation.code)
        
        if buyTicketStream.isRoundTrip {
            guard let originLocation = self.buyTicketStream.returnTicketModel.originLocation,
                let destLocation = self.buyTicketStream.returnTicketModel.destinationLocation else { return }
            
            let returnTripModel = ChooseBusStationParam(originCode: originLocation.code, destinationCode: destLocation.code)
            self.router?.initChildScreens(isRoundTrip: true, startTripBusStationParam: startTripModel, returnTripBusStationParam: returnTripModel)
        } else {
            self.router?.initChildScreens(isRoundTrip: false, startTripBusStationParam: startTripModel, returnTripBusStationParam: nil)
        }        
    }
    
    func attachFillInformation(type: TicketRoundTripType) {
        if type == .startTicket {
            guard let originLocation = self.buyTicketStream.ticketModel.originLocation,
                let destLocation = self.buyTicketStream.ticketModel.destinationLocation else { return }
            
            let model = ChooseBusStationParam(originCode: originLocation.code, destinationCode: destLocation.code)
            self.router?.attachFillInformation(isRoundTrip: false, type: type, busStationParam: model)
        } else {
            guard let originLocation = self.buyTicketStream.returnTicketModel.originLocation,
                let destLocation = self.buyTicketStream.returnTicketModel.destinationLocation else { return }
            
            let model = ChooseBusStationParam(originCode: originLocation.code, destinationCode: destLocation.code)
            self.router?.attachFillInformation(isRoundTrip: false, type: type, busStationParam: model)
        }
    }
    
    func ticketMainFillInformationMoveBack() {
        self.listener?.ticketMainFillInformationMoveBack()
    }
}

// MARK: Class's private methods
private extension TicketMainFillInformationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
