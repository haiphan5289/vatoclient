//  File name   : TicketDestinationInteractor.swift
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
import FirebaseFirestore

enum TicketDestinationError {
    case notFillFullInfomation
    case dateRoundTripMustLasterDateStart
}

protocol TicketDestinationRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToStartLocation(startLocation: TicketLocation?)
    func routeToDestinationLocation(startLocation: TicketLocation?, destinationLocation: TicketLocation?)
    func routeToChooseDate(dateSelected: Date?, ticketType: TicketRoundTripType)
    func routeToFillInformation()
    func routeToHistory()
    func routeToDepartTicket(ticketHistoryType: TicketHistoryType?)
    func routeToTicketFillInformation(originLocation: TicketLocation, destLocation: TicketLocation, streamType: BuslineStreamType)
    func routeToTicketMainFillInformation()
    
    func detactCurrentChild()
    func moveToDetailRoute(_ info: DetailRouteInfo)
}

protocol TicketDestinationPresentable: Presentable {
    var listener: TicketDestinationPresentableListener? { get set }
    // todo: Declare methods the interactor can invoke the presenter to present data.
    func updateSelectedPopularRoute(type: DestinationType, point: TicketLocation?)
    func selectPopularRouteAtIndex(index: Int)
    func showAlertFail(message: String?)
}

protocol TicketDestinationListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ticketMoveBack()
}

final class TicketDestinationInteractor: PresentableInteractor<TicketDestinationPresentable>, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: TicketDestinationRouting?
    weak var listener: TicketDestinationListener?
    private let component: TicketDestinationComponent
    /// Class's constructor.
    
    init(presenter: TicketDestinationPresentable,
         component: TicketDestinationComponent,
         action: TicketDestinationAction?)
    {
        self.component = component
        super.init(presenter: presenter)
        mAction = action
        presenter.listener = self
        loadDefautInfomation()
        
        let from = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        let to = Calendar.current.date(byAdding: .day, value: 2, to: Date())
        
        component.buyTicketStream.update(date: from, type: .startTicket)
        component.buyTicketStream.update(date: to, type: .returnTicket)
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        FireBaseTimeHelper.default.startUpdate()
        getPopularRoutes()
        // todo: Implement business logic here.
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
        FireBaseTimeHelper.default.stopUpdate()
    }
    
    func updateErrorType(errorType: TicketDestinationError) {
        _error.onNext(errorType)
    }
    /// Class's private properties.
    private let _error = ReplaySubject<TicketDestinationError>.create(bufferSize: 1)
    private (set) var userId: Int = 0
    
    @Replay(queue: MainScheduler.asyncInstance) private var ePopularRoutes: [PopularRoute]
    @Replay(queue: MainScheduler.asyncInstance) private var mTypeRoute: TypeRoute
    @Replay(queue: MainScheduler.asyncInstance) private var mAction: TicketDestinationAction?
    @Replay(queue: MainScheduler.asyncInstance) private var eDetailRoute: DetailRouteInfo
}

// MARK: TicketDestinationInteractable's members
extension TicketDestinationInteractor: TicketDestinationInteractable {
    var returnTicketObservable: Observable<TicketInformation> {
        return component.buyTicketStream.returnTicketObservable
    }
    
    var popularRoutes: Observable<[PopularRoute]> {
        return $ePopularRoutes
    }
    
    var detailRoute: Observable<DetailRouteInfo> {
        return $eDetailRoute
    }
    
    var action: Observable<TicketDestinationAction?> {
        return $mAction
    }
    
    func updateAction(item: BusLineHomeItem) {
        let origin = TicketLocation(use: item.originCode, name: item.originName)
        let destination = TicketLocation(use: item.destCode, name: item.destName)
        component.buyTicketStream.updateOriginLocation(ticketLocation: origin, type: .startTicket)
        component.buyTicketStream.updateDestinationLocation(ticketLocation: destination, type: .startTicket)
        presenter.updateSelectedPopularRoute(type: .origin, point: origin)
        let today = Date()
        if let date = item.date, Calendar.current.isDate(date, inSameDayAs: today) || date > today  {
            component.buyTicketStream.update(date: date, type: .startTicket)
        }
    }
        
    func ticketFillInformationMoveBack() {
        component.buyTicketStream.update(ticketSchedules: nil, type: .startTicket)
        component.buyTicketStream.update(ticketSchedules: nil, type: .returnTicket)
        
        component.buyTicketStream.update(routeStop: nil, type: .startTicket)
        component.buyTicketStream.update(routeStop: nil, type: .returnTicket)
        
        component.buyTicketStream.update(ticketRoute: nil, type: .startTicket)
        component.buyTicketStream.update(ticketRoute: nil, type: .returnTicket)
        
        component.buyTicketStream.update(user: nil, type: .startTicket)
        component.buyTicketStream.update(user: nil, type: .returnTicket)
        
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveBackBuyNewTicket() {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.component.buyTicketStream.resetTickets()
        }))
    }
    
    func ticketHistoryDetailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func paymentSuccess() {}
    func didCancelTicket() {}
    
    func moveManagerTicket() {
        router?.dismissCurrentRoute(completion: {[weak self] in
            self?.routeToHistory()
        })
    }
    
    func moveBackRoot() {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.component.buyTicketStream.resetTickets()
        }))
        loadDefautInfomation()
    }
    
    func ticketHistoryMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketUserInfomationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseTicketBusStationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseTicketBusStationMoveNext(with busStation: TicketRoutes) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func chooseTicketBusStationMoveNext(with routeStop: RouteStop) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketCalendarSelectedDate(date: Date, type: TicketRoundTripType) {
        component.buyTicketStream.update(date: date, type: type)
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketCalendarMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func updatePoint(type: DestinationType, point: TicketLocation) {
        if type == .origin {
            component.buyTicketStream.updateOriginLocation(ticketLocation: point, type: .startTicket)
        } else {
            component.buyTicketStream.updateDestinationLocation(ticketLocation: point, type: .startTicket)
        }
        router?.dismissCurrentRoute(completion: { [weak self] in
            self?.presenter.updateSelectedPopularRoute(type: type, point: point)
        })
    }
    
    func chooseDestinationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func ticketBusDidSelect(ticketRoute: TicketRoutes) {}
    
    func ticketBusDidSelect(routeStop: RouteStop) {}
    
    func ticketMainFillInformationMoveBack() {
        self.router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.component.buyTicketStream.resetTickets()
        }))
    }
    
    func closeMenu() {
        router?.detactCurrentChild()
    }
    
    func updateTicketByMenu(item: TypeRoute) {
        router?.detactCurrentChild()
        mTypeRoute = item
    }
        
    func ticketDetailRouteMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: TicketDestinationPresentableListener's members
extension TicketDestinationInteractor: TicketDestinationPresentableListener, Weakifiable {
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable, T : Encodable {
        return Requester.responseDTO(decodeTo: decodeTo, using: router, block: block).map { $0.response }
    }
    
    func processAction(type: ActionSelectTicket, ticketHistoryType: TicketHistoryType) {}
    
    func swapLocation() {
        let originLocation = component.buyTicketStream.ticketModel.originLocation
        let destLocation = component.buyTicketStream.ticketModel.destinationLocation
        
        component.buyTicketStream.updateOriginLocation(ticketLocation: destLocation, type: .startTicket)
        component.buyTicketStream.updateDestinationLocation(ticketLocation: originLocation, type: .startTicket)
        
        self.presenter.updateSelectedPopularRoute(type: .origin, point: destLocation)
    }
    
    func routeToDepartTicket(item: TicketHistoryType?) {
        router?.routeToDepartTicket(ticketHistoryType: item)
    }
    
    func requestList(params: [String: Any]) -> Observable<ResponsePaging<TicketHistoryType>> {
        return self.component.dependency.authStream.firebaseAuthToken.take(1).map {
            VatoTicketApi.listTicket(authToken: $0, params: params)
        }.flatMap { Requester.responseDTO(decodeTo: MessageDTO<ResponsePaging<TicketHistoryType>>.self, using: $0)
        }.map { (r) -> ResponsePaging<TicketHistoryType> in
            return r.response.data
        }
    }
    
    func routeToHistory() {
        router?.routeToHistory()
    }
    
    func routeToChooseDateReturn() {
        let dateSelected = component.buyTicketStream.returnTicketModel.date
        self.router?.routeToChooseDate(dateSelected: dateSelected, ticketType: .returnTicket)
    }
    
    var isRoundTrip: Observable<Bool> {
        return Observable.just(false)
    }
    
    var error: Observable<TicketDestinationError> {
        return _error.asObserver()
    }
    
    var ticketObservable: Observable<TicketInformation> {
        return component.buyTicketStream.ticketObservable
    }
    
    func routeToFillInformation() {
        if component.buyTicketStream.ticketModel.verifyToChooseBusStatus() == false {
            updateErrorType(errorType: .notFillFullInfomation)
        } else {
            guard let originLocation = self.component.buyTicketStream.ticketModel.originLocation,
                let destLocation = self.component.buyTicketStream.ticketModel.destinationLocation else { return }
//            self.router?.routeToTicketFillInformation(originLocation: originLocation, destLocation: destLocation, streamType: .buyNewticket)
            
            if self.component.buyTicketStream.isRoundTrip {
                self.component.buyTicketStream.updateOriginLocation(ticketLocation: destLocation, type: .returnTicket)
                self.component.buyTicketStream.updateDestinationLocation(ticketLocation: originLocation, type: .returnTicket)
            }
            
            self.router?.routeToTicketMainFillInformation()
        }
    }
    
    func routeToChooseDate() {
        let dateSelected = component.buyTicketStream.ticketModel.date
        self.router?.routeToChooseDate(dateSelected: dateSelected, ticketType: .startTicket)
    }
    
    func ticketMoveBack() {
        self.listener?.ticketMoveBack()
    }
    
    func routeToStartLocation() {
        let originLocation = component.buyTicketStream.ticketModel.originLocation
        self.router?.routeToStartLocation(startLocation: originLocation)
    }
    
    func routeToDestinationLocation() {
        let originLocation = component.buyTicketStream.ticketModel.originLocation
        let destinationLocation = component.buyTicketStream.ticketModel.destinationLocation
        self.router?.routeToDestinationLocation(startLocation: originLocation,
                                                destinationLocation: destinationLocation)
    }
    
    func selectOnOffRoundStrip(isRoudtrip: Bool) {
        component.buyTicketStream.update(isRoundTrip: isRoudtrip)
    }
    
    func didSelectPopularRoute(route: PopularRoute?) {
        guard let destLocation = route?.destLocation, let originLocation = route?.originLocation else  {
            return
        }
        
        component.buyTicketStream.updateOriginLocation(ticketLocation: originLocation, type: .startTicket)
        component.buyTicketStream.updateDestinationLocation(ticketLocation: destLocation, type: .startTicket)
    }
    
    func loadDefaultPopularRoute() {
        let originLocation = self.component.buyTicketStream.ticketModel.originLocation
        let destLocation = self.component.buyTicketStream.ticketModel.destinationLocation
        
        if originLocation == nil && destLocation == nil {
            self.presenter.selectPopularRouteAtIndex(index: 0)
        } else {
            guard let origin = originLocation, let destination = destLocation else {
                return
            }
            let popular = PopularRoute(description: nil, destCode: destination.code, destName: destination.name, originCode: origin.code, originName: origin.name, promotion: nil, distance: nil, duration: nil, name: nil, price: nil, totalSchedule: nil)
            self.didSelectPopularRoute(route: popular)
            self.presenter.updateSelectedPopularRoute(type: .origin, point: origin)
        }
    }
        
    func moveDetailRoute(_ info: DetailRouteInfo) {
        self.router?.moveToDetailRoute(info)
    }

    func getRouteId(route: PopularRoute) {
        guard let oriCode = route.originCode,
              let destCode = route.destCode,
              let departureTime = self.component.buyTicketStream.ticketModel.date else { return }
        
        let departureDate = departureTime.string(from: "dd-MM-yyyy")
        let router = VatoTicketApi.getRouteBetweenTwoPoint(authToken: "", orginCode: oriCode, desCode: destCode, departureDate: departureDate)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<[TicketRoutes]>.self)
            .trackProgressActivity(self.indicator)
            .bind {[weak self] (result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let r):
                    if r.fail {
                        wSelf.presenter.showAlertFail(message: r.message)
                    } else {
                        guard let data = r.data, let firstId = data.first?.id else { return }
                        let date = wSelf.component.buyTicketStream.ticketModel.date?.string(from: "dd-MM-yyyy")
                        let time = "00:00"//wSelf.component.buyTicketStream.ticketModel.time
                        wSelf.getRouteInfo(routeId: firstId, route: route, date: date, time: time, wayId: nil)
                    }
                case .failure(let e):
                    wSelf.presenter.showAlertFail(message: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func getRouteInfo(routeId: Int, route: PopularRoute, date: String?, time: String?, wayId: Int?) {
        let p: String
        if let wayID = wayId {
            p = "/buslines/futa/routes/\(routeId)/roadmap?wayId=\(wayID)"
        } else {
            p = "/buslines/futa/routes/\(routeId)/roadmap"
        }
        
        let url = "\(VatoTicketApi.host)\(p)" // Configs.url(p)
        let router = VatoAPIRouter.customPath(authToken: "", path: url, header: ["token_type":"user"], params: ["token_type":"user"], useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<[DetailRoute]>.self,
                        method: .get)
            .trackProgressActivity(self.indicator)
            .bind { [weak self](result) in
                guard let wSelf = self else { return }
                switch result {
                case .success(let d):
                    if d.fail == false {
                        var info = DetailRouteInfo()
                        info.listDetailRoute = d.data
                        info.nameFrom = route.originName
                        info.nameTo = route.destName
                        info.departureDate = date
                        info.departureTime = time
                        wSelf.eDetailRoute = info
                    } else {
                        wSelf.presenter.showAlertFail(message: d.message)
                  }
                case .failure(let e):
                    wSelf.presenter.showAlertFail(message: e.localizedDescription)
                }
        }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension TicketDestinationInteractor {
    private func setupRX() {
        let card = loadMethod(by: PaymentMethodVATOPay)
        self.component.buyTicketStream.update(method: card)
        
        self.component.profileStream.user.take(1).map ({ Int($0.id) }).bind { [weak self](userId) in
            self?.userId = userId
        }.disposeOnDeactivate(interactor: self)
        
        // todo: Bind data stream here.
    }
    
    private func loadDefaultMethod(from m: PaymentMethod) -> PaymentCardDetail {
        guard let current = component.mutablePaymentStream.currentSelect else {
            return loadMethod(by: m)
        }
        return current
    }
    
    private func loadMethod(by m: PaymentMethod) -> PaymentCardDetail {
        switch m {
        case PaymentMethodVATOPay:
            return PaymentCardDetail.vatoPay()
        default:
            return PaymentCardDetail.cash()
        }
    }
    
    private func loadDefautInfomation() {
        component.buyTicketStream.update(ticketSchedules: nil, type: .startTicket)
        component.buyTicketStream.update(ticketSchedules: nil, type: .returnTicket)
        
        component.buyTicketStream.update(routeStop: nil, type: .startTicket)
        component.buyTicketStream.update(routeStop: nil, type: .returnTicket)
        
        component.buyTicketStream.update(ticketRoute: nil, type: .startTicket)
        component.buyTicketStream.update(ticketRoute: nil, type: .returnTicket)
        
        component.buyTicketStream.update(user: nil, type: .startTicket)
        component.buyTicketStream.update(user: nil, type: .returnTicket)
                
        if let originLocation = TicketLocalStore.shared.loadDefautOriginLocation(){
            component.buyTicketStream.updateOriginLocation(ticketLocation: originLocation, type: .startTicket)
        }
        
        if let destLocation = TicketLocalStore.shared.loadDefautDestLocation() {
            component.buyTicketStream.updateDestinationLocation(ticketLocation: destLocation, type: .startTicket)
        }
    }
    
    private func getPopularRoutes() {
        BuslineConfigDataManager.shared.$listPopular.filterNil().bind(onNext: weakify({ (list, wSelf) in
            wSelf.ePopularRoutes = list.filter(\.valid)
        })).disposeOnDeactivate(interactor: self)
    }
}
