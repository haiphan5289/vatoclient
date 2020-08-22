//  File name   : TicketHistoryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import FwiCoreRX
import Alamofire
let historyDidChangeNotify = "historyDidChangeNotify"

protocol HistoryDetailDisplay {
    var ticketsCode: String? { get }
    var userName: String? { get }
    var phone: String? { get }
    var routName: String? { get }
    var time: String? { get }
    var pickup: String? { get }
    var pickupAddress: String? { get }
    var numberSeats: String? { get }
    var seatsName: String? { get }
    var priceStr: String? { get }
    var cardFee: String? { get }
    var totalPriceStr: String? { get }
    var status: TicketStatus? { get }
    var timeExpiredPaymentStr: String? { get }
    var paymentCardType: PaymentCardType? { get }
    var seatDiscountsHistory: [Double]? { get }
    var seatIdsHistory: [Int32]? { get }
    var originPriceHistory: Int64? { get }
}



protocol TicketHistoryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToDetail(item: TicketHistoryType)
    func routeToCancel(item: TicketHistoryType)
    func routeToChangeTicket(item: TicketHistoryType)
    func routeToTicketRouteDetail(_ info: DetailRouteInfo)
}

protocol TicketHistoryPresentable: Presentable {
    var listener: TicketHistoryPresentableListener? { get set }
    func option(item: TicketHistoryType, type: TicketHistory)
    func removeItem(item: TicketHistoryType, type: TicketHistory)
    func refresh()
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TicketHistoryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketHistoryMoveBack()
}

final class TicketHistoryInteractor: PresentableInteractor<TicketHistoryPresentable> {
    /// Class's public properties.
    weak var router: TicketHistoryRouting?
    weak var listener: TicketHistoryListener?
    private (set) var userId: Int = 0
    /// Class's constructor.
    init(presenter: TicketHistoryPresentable,
         authStream: AuthenticatedStream,
         mutableProfileStream: MutableProfileStream)
    {
        self.authStream = authStream
        self.profileStream = mutableProfileStream
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
    private let authStream: AuthenticatedStream
    private let profileStream: ProfileStream
    private var currentItemSelectAction: TicketHistoryType?
    private var currentSelectTicketHistory: TicketHistory?
}

// MARK: TicketHistoryInteractable's members
extension TicketHistoryInteractor: TicketHistoryInteractable {
    func moveManagerTicket() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackRoot() {
        router?.dismissCurrentRoute(completion: nil)
    }

    func moveBackBuyNewTicket() {
        listener?.ticketHistoryMoveBack()
    }
    
    func changeTicketMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketHistoryDetailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func paymentSuccess() {
        presenter.refresh()
    }
    
    func cancelTicketMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func didCancelTicket() {
        presenter.refresh()
    }
    
    func cancelTicketSuccess(item: TicketHistoryType) {
        router?.dismissCurrentRoute(completion: {[weak self] in
            if let currentSelectTicketHistory = self?.currentSelectTicketHistory {
                if currentSelectTicketHistory == .future {
                    self?.presenter.removeItem(item: item, type: currentSelectTicketHistory)
                } else {
                    self?.presenter.refresh()
                }
            }
        })
    }
    
    func getRouteInfo(routeId: Int, route: PopularRoute) {
//        struct Configs {
//            static let url: (String) -> String = { p in
//                let rootURL: String = {
//                    #if DEBUG
//                        return "https://api-busline-dev.vato.vn/api"
//                    #else
//                        return "https://api-busline.vato.vn/api"
//                    #endif
//                }()
//                return "\(rootURL)\(p)"
//            }
//        }
//
//        let url = Configs.url("/buslines/futa/routes/\(routeId)/roadmap")
//        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: nil, params: nil, useFullPath: true)
//        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
//        network.request(using: router,
//                        decodeTo: OptionalMessageDTO<[DetailRoute]>.self,
//                        method: .get)
//            .trackProgressActivity(self.indicator)
//            .bind { [weak self](result) in
//                guard let wSelf = self else { return }
//                switch result {
//                case .success(let d):
//                    if d.fail == false {
//                        var info = DetailRouteInfo()
//                        info.listDetailRoute = d.data
//                        info.nameFrom = route.originName
//                        info.nameTo = route.destName
//                        info.departureDate = wSelf.component.buyTicketStream.ticketModel.date?.string(from: "dd-MM-yyyy")
//                        info.departureTime = wSelf.component.buyTicketStream.ticketModel.time
//                        wSelf.eDetailRoute = info
//                    } else {
//                        wSelf.presenter.showAlertFail(message: d.message)
//                  }
//                case .failure(let e):
//                    wSelf.presenter.showAlertFail(message: e.localizedDescription)
//                }
//        }.disposeOnDeactivate(interactor: self)
    }
}

extension TicketHistoryType: TicketDisplayProtocol {
    var timeStart: String? {
        return self.departureTime
    }
    var dateStart: String? {
        return self.departureDate
    }
    
    var from: String? {
        return self.originName
    }
    var to: String? {
        return self.destName
    }
    
    var timeEnd: String? {
        if let timeEstimation = self.timeEstimation {
            
            let date = Date(timeIntervalSince1970: timeEstimation/1000)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let hourString = formatter.string(from: date)
            
            return hourString
        }
        return ""
    }
    var seat: String? {
        return self.seatNames?.joined(separator: ", ")
    }
}

// MARK: TicketHistoryPresentableListener's members
extension TicketHistoryInteractor: TicketHistoryPresentableListener, ActivityTrackingProgressProtocol {
    func detailRoute(item: TicketHistoryType) {
        self.requestDetailTicketRoute(item: item)
    }
    
    func ticketDetailRouteMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    private func requestDetailTicketRoute(item: TicketHistoryType?) {
        guard let value = item else {
            return
        }
        
        guard let routeId = value.routeId,
            let wayID = value.wayId else
        {
            return
        }
        
        let url = "\(VatoTicketApi.host)/buslines/futa/routes/\(routeId)/roadmap?wayId=\(wayID)"
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[DetailRoute]>.self,
                        method: .get,
                        encoding: JSONEncoding.default)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail == false {
                        var item = DetailRouteInfo()
                        item.listDetailRoute = d.data ?? []
                        item.nameFrom = value.originName
                        item.nameTo = value.destName
                        item.departureTime = value.departureTime
                        item.departureDate = value.departureDate
                        wSelf.showTicketRouteDetail(item)
                    } else {
                        print(d.message ?? "")
                  }
                case .failure(let e):
                    print(e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func showTicketRouteDetail(_ info: DetailRouteInfo) {
        router?.routeToTicketRouteDetail(info)
    }
    
    func processAction(type: ActionSelectTicket) {
        switch type {
        case .changeTicket:
            guard let item  = self.currentItemSelectAction else { return }
            router?.routeToChangeTicket(item: item)
            break
        case .cancelTicket:
            guard let item  = self.currentItemSelectAction else { return }
            router?.routeToCancel(item: item)
        case .routeInfo:
            self.requestDetailTicketRoute(item: self.currentItemSelectAction)
        case .rebookTicket:
            break
        case .supportTicket:
            break
        case .shareTicket:
            break
        }
    }
    
    func requestList(params: [String: Any]) -> Observable<ResponsePaging<TicketHistoryType>> {
       return self.authStream.firebaseAuthToken.take(1).map {
            VatoTicketApi.listTicket(authToken: $0, params: params)
            }.flatMap { Requester.responseDTO(decodeTo: MessageDTO<ResponsePaging<TicketHistoryType>>.self, using: $0)
            }.map { (r) -> ResponsePaging<TicketHistoryType> in
                return r.response.data
        }
    }
    
    func option(item: TicketHistoryType, type: TicketHistory) {
        presenter.option(item: item, type: type)
        self.currentItemSelectAction = item
        self.currentSelectTicketHistory = type
    }
    
    func select(item: TicketHistoryType) {
        router?.routeToDetail(item: item)
    }
    
    func moveBack() {
        listener?.ticketHistoryMoveBack()
    }
}

// MARK: Class's private methods
private extension TicketHistoryInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        self.profileStream.user.take(1).map ({ Int($0.id) }).bind { [weak self](userId) in
            self?.userId = userId
            }.disposeOnDeactivate(interactor: self)
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: historyDidChangeNotify)).observeOn(MainScheduler.asyncInstance).bind { [weak self](_) in
            // Refesh
            self?.presenter.refresh()
            }.disposeOnDeactivate(interactor: self)
    }
}

