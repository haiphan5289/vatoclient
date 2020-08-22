//  File name   : BookingConfirmInteractor.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import RIBs
import RxSwift
import Alamofire

import VatoNetwork
import Firebase
import FwiCoreRX
import KeyPathKit

protocol BookingConfirmRouting: Routing, BookingConfirmIntripProtocol {
    var bookingConfirmView: BookingConfirmView { get }
    var viewControllable: ViewControllable { get }
    
    func cleanupViews()
    func detactCurrentChild()
    func routeToNote()
    func routeToWallet(vatoServiceType: VatoServiceType)
    func routeToTip()
    func routeToTransport()
    func routeToChooseMethod()
    func routeToTopupWallet()
    func routeToDetailPrice()
    func routeToPromotion(coordinate: CLLocationCoordinate2D?)
    func routeToBookingRequest()
    func routeToSwitchMethod(vatoServiceType: VatoServiceType)
    func routeToDetailPromotion(with code: String, maifest: PromotionList.Manifest?)
    func update(from type: BookingConfirmUpdateType)
    func updateBookingUI(from fixedBook: Bool)
    func drawMarker(from booking: Booking)
    func drawRoutes(using routes: String)
    func updateDiscount()
    func updateMapViewCamera()
    func valid(promotion model: PromotionModel?) -> Observable<PromotionCheckType>
    func moveToIntrip(by tripId: String)
    func checkPaymentError(from e: Error)
    func presentMessage(message: String)
    func showAlertIntrip(tripId: String)
    func routeToConfirmBookServiceMore(listService: [AdditionalServices], listCurrentSelectedService: [AdditionalServices])
    func routeToIntrip(tripId: String)
    func routeToAddCard()
}

protocol BookingConfirmListener: class {
    func booking(use json: [String: Any])
    func cancel(promotion: PromotionModel)
    func bookChangeToInTrip(by tripId: String)
    func onTripCompleted()
    func refeshLocation()
}

final class BookingConfirmInteractor: Interactor, BookingConfirmInteractable, UsePromotionProtocol, BookingDependencyProtocol, ActivityTrackingProgressProtocol {
    weak var router: BookingConfirmRouting?
    weak var listener: BookingConfirmListener?
    let component: BookingConfirmServicesType
    var currentMethod: PaymentMethod {
        return self.component.priceUpdate.methodPayment
    }
    
    var mComponent: BookingConfirmComponentProtocol & BookingConfirmSecurityProtocol {
        return component
    }

    var eMethod: Observable<PaymentCardDetail> {
        return self.component.priceUpdate.eMethod
    }
    
    var eApplyPromotion: Observable<Void> {
        guard let component = self.component as? ConfirmDetailDependency else {
            return Observable.empty()
        }
        return component.mPromotionStream.eUsePromotion
    }

    var profileStream: ProfileStream {
        return component.profileStream
    }

    var onlineDrivers: Observable<[SearchDriver]> {
        return self.component.mutableBooking.onlineDrivers
    }

    private var keyGoogle: Observable<String> {
        return self.component.authenticated.googleAPI
    }

    private var booking: Observable<Booking> {
        return self.component.bookingPoints.booking
    }

    var errorStream: ErrorBookingStream {
        return component.errorStream
    }
    
    var authenticatedStream: AuthenticatedStream {
        return component.authenticated
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return component.mutablePaymentStream
    }
    
    private (set) lazy var directionFares: ReplaySubject<BookingConfirmDirectionFares> = ReplaySubject.create(bufferSize: 1)
    private let subjectRoute: ReplaySubject<RouteTrip?> = ReplaySubject.create(bufferSize: 1)
    private let subjectZone: ReplaySubject<Zone> = ReplaySubject.create(bufferSize: 1)
    private (set)lazy var listFare: PublishSubject<[FareDisplay]> = PublishSubject()
    private var canListen: Bool = true
    var currentBook: Booking?
    private var onlineWaitingDisposable: Disposable?
    private var currentCoordinate: CLLocationCoordinate2D?
    private var timerGetListDriverOnline: SafeTimer?
    private var cacheRouteInfo: [MapAPI.Transport : MapModel.Router] = [:]
    var groupServiceName: String {
        return ""
    }
    
    var segment: String? {
        return self.mComponent.confirmStream.model.booking?.defaultSelect.service?.segment
    }
    
    private var currentListServiceMore: [AdditionalServices] = []
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(component: BookingConfirmComponent) {
        self.component = component
        super.init()
    }

    deinit {
        component.mutableBooking.updatePromotion(promotion: nil);
        removeTimerRequestOnlineDrivers()
    }
    
    override func didBecomeActive() {
        FireBaseTimeHelper.default.startUpdate()
        super.didBecomeActive()
        setupRX()
        updateZoneAddress()
        prepareData()
    }

    override func willResignActive() {
        FireBaseTimeHelper.default.stopUpdate()
        canListen = false
        super.willResignActive()
        router?.cleanupViews()
        component.confirmStream.cleanUp()
    }
    
    func editBooking(for marker: MarkerViewType) {
        self.checkCancelPromotion()
        component.bookingPoints.booking.bind { [weak self] booking in
            switch marker {
            case .end:
                self?.component.mutableBookingState.changeMode(mode: .editSearchLocation(suggestMode: .destination1))

            default:
                if booking.tripType == BookService.quickBook {
                    self?.component.mutableBookingState.changeMode(mode: .editQuickBookingSearchLocation)
                } else {
                    self?.component.mutableBookingState.changeMode(mode: .editSearchLocation(suggestMode: .origin))
                }
            }
        }
        .dispose()
    }

    func updateSelect(service: ServiceCanUseProtocol) {
        self.component.transportStream.setStatusAutoApplyPromotionCode(isAutoApply: true)
        self.component.mutableBooking.updateDefaultService(service: service)
        self.component.transportStream.update(select: service)
        
    }

    func update(tip: Double) {
        component.tipStream.update(tip: tip)
    }

    func updateSelectFavorite(use: Bool) {
        component.transportStream.updateSelectFavorite(use: use)
    }
    
    func update(routes: String) {
        component.transportStream.update(routes: routes)
    }

    func update(model: PromotionModel?) {
        component.promotionStream.update(promotion: model)
    }

    func update(payment method: PaymentCardDetail) {
        component.priceUpdate.update(paymentMethod: method)

        // Only save cash || vatopay
        guard let m = method.type.method, m == PaymentMethodCash || m == PaymentMethodVATOPay else {
            return
        }
        
        // firebase update
        if let id = Auth.auth().currentUser?.uid {
            component.firebaseDatabase.updatePaymentMethod(method: m, firebaseId: id)
            component.profileStream.client.take(1).subscribe(onNext: { [weak self] client in
                var nextClient = client
                nextClient.paymentMethod = m
                self?.component.profileStream.updateClient(client: nextClient)
            }, onError: { error in
                printDebug(error.localizedDescription)
            }).disposeOnDeactivate(interactor: self)
        }
    }

    func closeDetailPrice() {
        router?.detactCurrentChild()
    }

    func detailBook() {
        router?.detactCurrentChild()
        self.move(to: .booking)
    }

    func closeInputPromotion() {
        router?.detactCurrentChild()
    }
    
    func dismissDetail() {
        router?.detactCurrentChild()
    }
    
    func promotionMoveBack() {
        router?.detactCurrentChild()
        
        //add timer get driver online again
        addTimerRequestOnlineDrivers()
    }
    
    func dimissServiceMore() {
        router?.detactCurrentChild()
    }
    
    func confirmBookingService(arrayServiceMore: [AdditionalServices]) {
        self.component.mutableBooking.updateDefaultServiceMore(list: arrayServiceMore)
        self.component.priceUpdate.price.filterNil().take(1).subscribe(onNext: { (price) in
            self.currentListServiceMore = arrayServiceMore
            
            var tip: Double = 0
            for service in arrayServiceMore {
                tip += service.caculateAdditionalAmount(currentAmount: Double(price.originalPrice))
            }
            
            tip = Double(tip.roundPrice())
            self.component.tipStream.update(tip: tip)
        }).disposeOnDeactivate(interactor: self)
        
        router?.detactCurrentChild()
    }

    private func checkSelect(payment: PaymentMethod?) -> PaymentMethod? {
        guard let payment = payment else {
            return nil
        }
        
        switch payment {
        case PaymentMethodAll:
            return PaymentMethodCash
        default:
            return payment
        }
    }
   
    private func updateListServiceBookingView() {
        let findGroupObser = self.component.transportStream.findGroup().take(1)
        let selectedServiceObser = self.component.transportStream.selectedService
        
        Observable.combineLatest(findGroupObser, selectedServiceObser) { (transportGroup, selectedService) -> [ServiceCanUseProtocol] in
            let _listService = transportGroup.flatMap(\.services)
            var listService = FireStoreConfigDataManager.shared.getSuggestServices(from: selectedService.service.id).compactMap({ (v) -> ServiceCanUseProtocol? in
                return _listService.filter({ $0.service.id == v }).first
            })
            
            listService.removeAll(where: { $0.service.id == selectedService.service.id })
            listService.insert(selectedService, at: 0)
            return Array(listService.prefix(2))
            }.bind { [weak self](listService) in
                self?.router?.update(from: .updateListService(listService: listService))
            }.disposeOnDeactivate(interactor: self)
    }
    
    private func checkTip() {
        booking.take(1).bind { [weak self](b) in
            guard let wSelf = self else { return }
            guard let listServiceMore = b.defaultSelect.arrayServiceMore, !listServiceMore.isEmpty else {
                return
            }
            wSelf.confirmBookingService(arrayServiceMore: listServiceMore)
        }.disposeOnDeactivate(interactor: self)
    }
    
    // MARK: -- Config handler payment
    var disposeTrackMethod: Disposable?

    private func registerEventPayment() {
        func listenChange() {
            disposeTrackMethod?.dispose()
            disposeTrackMethod = self.router?.bookingConfirmView.selectPaymentView?.selected.distinctUntilChanged().bind(onNext: weakify({ (card, wSelf) in
                if card.addCard {
                    wSelf.routeToAddCard()
                } else {
                    wSelf.component.priceUpdate.update(paymentMethod: card)
                }
            }))
        }
        
        func registerEvent() {
            self.component.transportStream.selectedService.bind(onNext: weakify({ (_, wSelf) in
                listenChange()
            })).disposeOnDeactivate(interactor: self)
        }
        
        router?.bookingConfirmView.readySetupPayment.bind(onNext: weakify({ (wSelf) in
            registerEvent()
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func configHandlerPayment() {
        registerEventPayment()
        self.component.transportStream.selectedService.bind(onNext: weakify({ (s, wSelf) in
            guard let vatoService = s.fare?.setting.serviceType else { return }
            wSelf.router?.bookingConfirmView
                .updatePaymentStream(use: wSelf.mutablePaymentStream,
                                     controller: wSelf.router?.viewControllable.uiviewController,
                                     type: .service(service: vatoService))
        })).disposeOnDeactivate(interactor: self)
    }
    
    // MARK: -- Setup update event
    private func setupRX() {
        registerHandlerFares()
        configHandlerPayment()
        eMethod.subscribe(onNext: { [weak self] card in
            self?.mutablePaymentStream.update(select: card)
        }).disposeOnDeactivate(interactor: self)
        
        component
            .bookingPoints
            .promotion.filter { model -> Bool in
                let p = model?.data?.data?.promotionPredicates.first
                return p?.service != VatoServiceType.delivery.rawValue
            }
            .take(1)
            .filterNil()
        .bind { [weak self] (promotionModel) in
            self?.component.transportStream.setStatusAutoApplyPromotionCode(isAutoApply: false)
            self?.update(model: promotionModel)
        }
        .disposeOnDeactivate(interactor: self)
        
        self.component.bookingPoints.shouldReloadPromotion.filter { $0 }.bind { [weak self](_) in
            self?.reUsePromotion()
        }.disposeOnDeactivate(interactor: self)
        
        self.component.transportStream.booking
            .map { $0.tripType == BookService.fixed }.bind { [weak self] v in
                self?.router?.updateBookingUI(from: v)
            }.disposeOnDeactivate(interactor: self)

        // Find Select
        self.component.transportStream.listService.flatMap { [weak self] (services) -> Observable<([Service], [FareDisplay])> in
            guard let wSelf = self else {
                return Observable.empty()
            }
            return wSelf.component.transportStream.listFare.map({ (services, $0) })
            }.take(1)
            .bind { [weak self] in
                self?.findSelectDefault(from: $0)
            }.disposeOnDeactivate(interactor: self)
        
        booking.bind { [weak self] b in
            guard let wSelf = self else { return }
            wSelf.currentBook = b
            wSelf.component.transportStream.update(book: b)
            if let defaultSelect = wSelf.loadDefault(by: b.defaultSelect.paymentMethod) {
                self?.update(payment: defaultSelect)
            }
            
            if let defaultNote = b.defaultSelect.note {
                self?.component.noteStream.update(note: defaultNote)
            }
            
            }.disposeOnDeactivate(interactor: self)
        
        var defautDistance = defautDistanceDriver
        if let appConfigure = FirebaseHelper.shareInstance()?.appConfigure,
            appConfigure.request_driver_config != nil,
            let distance = appConfigure.request_driver_config?.distance,
            distance > minDistanceRequest {
            defautDistance = Double(distance)
        }
        booking
            .map { $0.originAddress.coordinate }
            .distinctUntilChanged { $0.distance(to: $1) <= defautDistance }
            .subscribe(onNext: { [weak self] coordinate in
                self?.currentCoordinate = coordinate
                self?.requestOnlineDrivers(coordinate: coordinate)
            })
            .disposeOnDeactivate(interactor: self)
        
        booking.take(1).subscribe(onNext: {[weak self] (booking) in
            self?.router?.update(from: .updateBooking(booking: booking))
        }).disposeOnDeactivate(interactor: self)
        
        addTimerRequestOnlineDrivers()
        
        self.component.priceUpdate.price.filterNil().map({ BookingConfirmUpdateType.updatePrice(infor: $0) }).bind { [weak self] update in
            self?.router?.update(from: update)
        }.disposeOnDeactivate(interactor: self)

        profileStream.user.bind { [weak self] user in
            self?.component.priceUpdate.update(userInfor: user)
        }.disposeOnDeactivate(interactor: self)

        self.findBookAddPrice()
        self.updateListServiceBookingView()
        
        component.noteStream.valueNote.bind { [weak self] in
            self?.component.mutableBooking.updateDefaultNote(note: $0)
            self?.router?.update(from: BookingConfirmUpdateType.note(string: $0))
        }.disposeOnDeactivate(interactor: self)

        // Find Zone
        findZone()

        // Find Price
        subjectZone.bind(onNext: { [weak self] z in
            guard let wSelf = self else { return }
            wSelf.component.transportStream.update(zone: z)
            wSelf.preparePrice()
        }).disposeOnDeactivate(interactor: self)

        // Find Service
        subjectZone.flatMap { [weak self] (z) -> Observable<[Service]> in
            guard let wSelf = self else {
                return Observable.empty()
            }
            return wSelf.findServices(by: z)
        }.subscribe(onNext: { [weak self] services in
            self?.component.transportStream.updateListService(list: services)
        }, onError: { e in
            let error = e as NSError
            printDebug(error.userInfo)
        }).disposeOnDeactivate(interactor: self)

        // Update list fare
        self.listFare.map { $0.filter { $0.setting.serviceType != .delivery }}.subscribe(onNext: { [weak self] in
            self?.component.transportStream.updateList(listFare: $0)
        }, onError: { e in
            printDebug(e.localizedDescription)
        }).disposeOnDeactivate(interactor: self)

        self.component.transportStream.selectedService.map({ BookingConfirmUpdateType.service(type: $0) }).bind { [weak self] in
            self?.router?.update(from: $0)
            
            if let coordinate = self?.currentCoordinate {
                self?.requestOnlineDrivers(coordinate: coordinate)
            }
        }.disposeOnDeactivate(interactor: self)

        self.component.tipStream.currentTip.map({ BookingConfirmUpdateType.updateTip(tip: $0) }).bind { [weak self] in
            self?.router?.update(from: $0)
        }.disposeOnDeactivate(interactor: self)

        // Promotion
        self.component.promotionStream.ePromotion.bind { [weak self] in
            self?.router?.update(from: BookingConfirmUpdateType.updatePromotion(model: $0))
        }.disposeOnDeactivate(interactor: self)
        
        // Service more - apply
        let listAdditionalServicesObserable = self.component.confirmStream.listAdditionalServicesObserable.map { $0.filter({ $0.changeable == false }) }.take(1)
        let priceStream = self.component.priceUpdate.price.filterNil().distinctUntilChanged()
        let service = self.component.transportStream.selectedService.distinctUntilChanged { (s1, s2) -> Bool in
            s1.service.id == s2.service.id
        }
        
        Observable.combineLatest(listAdditionalServicesObserable, priceStream, service).map({ (list, price, service) -> Double in
            let changableList = list.filter { $0.canAppy(serviceId: service.service.id) }
            let t1 = changableList.reduce(0, { $0 + $1.caculateAdditionalAmount(currentAmount: Double(price.originalPrice)) })
            let tip = Double(t1.roundPrice())
            return tip
        }).bind { [weak self] tip in
            guard let me = self else { return }
            me.currentListServiceMore.removeAll()
            me.component.tipStream.update(tip: tip)
            me.checkTip()
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func loadDefaultMethod(from m: PaymentMethod) -> PaymentCardDetail {
        if let defaultSelect = self.checkSelect(payment: self.currentBook?.defaultSelect.paymentMethod) {
            return loadMethod(by: defaultSelect)
        } else {
            guard let current = component.mutablePaymentStream.currentSelect else {
                return loadMethod(by: m)
            }
            return current
        }
    }
    
    private func loadDefault(by method: PaymentMethod?) -> PaymentCardDetail? {
        guard let method = method else { return nil }
        return loadMethod(by: method)
    }
    
    private func loadMethod(by m: PaymentMethod) -> PaymentCardDetail {
        switch m {
        case PaymentMethodVATOPay:
            return PaymentCardDetail.vatoPay()
        default:
            return PaymentCardDetail.cash()
        }
    }

    private func findBookAddPrice() {
        self.firebaseDatabase.findBookAddPrice().take(1).subscribe(onNext: { [weak self] tip in
            self?.component.tipStream.update(config: tip)
        }, onError: { e in
            let error = e as NSError
            printDebug(error)
        }).disposeOnDeactivate(interactor: self)
    }

    func findSelectDefault(from values: ([Service], [FareDisplay])) {
        guard let s = values.0.first(where: { $0.choose }), let defaultChooseService = s.cartypes.first(where: { $0.choose }) else {
            return
        }
        
        // Check if ready set default
        var nextService = defaultChooseService
        if let customSelect = self.currentBook?.defaultSelect {
            /// Need to check all
            findNextChoose: for temp in values.0 {
                if let n = temp.cartypes.first(where: { $0.serviceType == customSelect.service }) {
                    nextService = n
                    break findNextChoose
                }
            }
        }
        
        let customSelect = nextService.id
        
        let fare = values.1.first(where: { customSelect == $0.setting.service && $0.setting.listTripType.contains(1) })
        // let select = ServiceUse(idService: s.id, service: nextService, fare: fare, predicate: nil, modifier: nil, isFixedPrice: isFixedPrice, priceTotal: 0, priceDiscount: 0)
        let select = ServiceChooseGroup(idService: nextService.id, service: nextService, fare: fare)
        self.component.transportStream.update(select: select)
    }

    func detachMe() {
        router?.dismissCurrentRoute(completion: nil)
        self.listener?.refeshLocation()
//        DispatchQueue.main.async {
//            self.component.mutableBookingState.changeMode(mode: .home)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                self.listener?.refeshLocation()
//            }
//        }
    }
    
    func checkCancelPromotion() {
        if let promotionModel = component.currentPromotion {
            listener?.cancel(promotion: promotionModel)
        }
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    private func findServices(by zone: Zone) -> Observable<[Service]> {
        return self.firebaseDatabase.findServices(by: zone.id).flatMap { [weak self] (s) -> Observable<[Service]> in
            guard s.count > 0 else {
                if let wSelf = self {
                    return wSelf.firebaseDatabase.findServices(by: ZoneConstant.vn)
                }
                return Observable.empty()
            }
            return Observable.just(s)
        }
    }

    private func prepareData() {
        booking.take(1).bind { [weak self] b in
            switch b.tripType {
            case BookService.fixed:
                if b.destinationAddress1 != nil {
                    self?.findRoute()
                }
            case BookService.quickBook:
                self?.subjectRoute.onNext(nil)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)

        booking.take(1).observeOn(MainScheduler.asyncInstance).bind { [weak self] booking in
            guard let wSelf = self, wSelf.canListen else {
                return
            }
            wSelf.router?.drawMarker(from: booking)
        }.disposeOnDeactivate(interactor: self)
    }

    private func findRoute() {
        // Finding
        directionFares.map { $0.direction_info }.take(1).bind(onNext: { [weak self] in
            self?.subjectRoute.onNext($0.route)
            self?.router?.drawRoutes(using: $0.overviewPolyline)
        }).disposeOnDeactivate(interactor: self)
    }

    private func findZone() {
        booking.map({ $0.originAddress.coordinate }).take(1).flatMap { [weak self] (coordinate) -> Observable<Zone> in
            guard let wSelf = self else {
                return Observable.empty()
            }
            return wSelf.findZone(from: coordinate)
        }.subscribe(self.subjectZone)
        .disposeOnDeactivate(interactor: self)
    }
    
    func cancelNote() {
        router?.detactCurrentChild()
    }

    func closeTip() {
        router?.detactCurrentChild()
    }

    func closeTransPortService() {
        router?.detactCurrentChild()
    }

    func change(method: ChangeMethod) {
        router?.detactCurrentChild()
        switch method {
        case .cash:
            forceUseCash()
        case .inputMoney:
            self.router?.routeToTopupWallet()
        }
    }

    func closeChangeMethod() {
        router?.detactCurrentChild()
    }
    
    func cancelPromotion() {
        router?.detactCurrentChild()
        revert()
        component.promotionStream.update(promotion: nil)
    }
    
    private func revert() {
        guard let promotion = self.component.currentPromotion,
            let promotionToken = promotion.data?.data?.promotionToken
        else {
            return
        }
        
        self.revertPromotion(from: promotionToken).subscribe(onNext: { (_) in
            printDebug("Success to cancel promotion token.")
        }, onError: { (e) in
            printDebug(e.localizedDescription)
        }).disposeOnDeactivate(interactor: self)
        
    }
    
    func reRequestSearchDriver() {
        addTimerRequestOnlineDrivers()
    }
    
    func reUsePromotion() {
        guard let promotion = self.component.currentPromotion else {
            return
        }
        
        let payment = promotion.paymentMethod
        let manifest = promotion.mainfest
        let code = promotion.code
        
        self.requestPromotionData(from: code).map { data -> PromotionModel in
            let model = PromotionModel(with: code)
            model.data = data
            model.paymentMethod = payment
            model.mainfest = manifest
            return model
        }
        .trackProgressActivity(self.indicator)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] in
            self?.component.promotionStream.update(promotion: $0)
        }, onError: { [weak self](e) in
            self?.component.errorStream.update(from: PromotionError.applyCode(e: e))
            self?.component.confirmStream.resetPromotion()
        }).disposeOnDeactivate(interactor: self)
    }
    
    
    private func checkMethod() -> Observable<Void>{
        guard let currentBook = currentBook,
            let method = self.component.currentModelBook.paymentMethod else {
            fatalError("Check!!!!!")
        }
        
        let priceInformation = self.component.currentModelBook.informationPrice
        guard method.napas else {
            return Observable.just(())
        }
        
        if currentBook.tripType == BookService.fixed {
            let max = component.tipConfig?.client_card_config?.max_trip_price ?? 0
            var discount: UInt32 = 0
            if self.component.currentModelBook.promotionModel?.canApply == true {
                discount = self.component.currentModelBook.promotionModel?.discount ?? 0
            }
            let lastPrice = priceInformation?.lastPrice ?? 0
            let tip = UInt32(priceInformation?.tip ?? 0)
            let value = (lastPrice >= discount ? lastPrice - discount : 0) + tip
            guard Double(value) <= max else {
                return Observable.error(PaymentError.napasExceedAllow(defaultMoney: max))
            }
            return Observable.just(())
        } else {
            return Observable.error(PaymentError.napsNotApplyOneTouch)
        }
    }
    
    private func activeBook() {
        self.checkLastTrip()
            .take(1)
            .observeOn(MainScheduler.instance)
            .timeout(.seconds(10), scheduler: MainScheduler.asyncInstance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: {[weak self] (tripId) in
                if tripId.isEmpty == true {
                    self?.checkPromotion()
                } else {
                    self?.router?.showAlertIntrip(tripId: tripId)
                }
                }, onError: {[weak self] (e) in
                    if (e as NSError).code == NSURLErrorResourceUnavailable {
                        self?.checkPromotion()
                    } else {
                        self?.router?.presentMessage(message: Text.networkDownDescription.localizedText)
                    }
            }).disposeOnDeactivate(interactor: self)
        /*
         checkPromotion()
         */
    }
    
    private func checkPromotion() {
        self.router?.valid(promotion: self.component.currentPromotion).subscribe(onNext: { [weak self](p) in
            guard let wSelf = self else {
                return
            }
            switch p {
            case .next:
                wSelf.moveToBook()
                wSelf.removeTimerRequestOnlineDrivers()
            case .review:
                wSelf.move(to: .coupon)
            }
        }).disposeOnDeactivate(interactor: self)
    }
    
    private func moveToBook() {
        self.checkMethod().subscribe(onNext: { [weak self](_) in
            guard let wSelf = self else { return }
            let json = wSelf.component.json
            wSelf.listener?.booking(use: json)
            wSelf.router?.routeToBookingRequest()
        }, onError: { [weak self](e) in
            self?.router?.checkPaymentError(from: e)
        }).disposeOnDeactivate(interactor: self)
    }

    func move(to type: BookingConfirmType) {
        switch type {
        case .note:
            router?.routeToNote()
        case .wallet:
            self.component.transportStream.selectedService.take(1).bind {[weak self] (s) in
                self?.router?.routeToWallet(vatoServiceType: s.service.serviceType)
            }.disposeOnDeactivate(interactor: self)
        case .addTip:
            self.routeToConfirmBookingServiceMore()
        case .chooseInformation:
            router?.routeToTransport()
        case .booking:
            Observable.just("Payment").map { [weak self] _ -> Bool in
                guard let wSelf = self else {
                    return false
                }

                return try wSelf.component.priceUpdate.canPayment()
            }.subscribe(onNext: { [weak self] canBook in
                guard let wSelf = self else {
                    return
                }

                guard canBook else {
                    wSelf.router?.routeToChooseMethod()
                    return
                }
                wSelf.activeBook()
            }, onError: { [weak self] e in
                printDebug(e.localizedDescription)
                guard let wSelf = self else {
                    return
                }
                wSelf.router?.presentMessage(message: Text.cannotLoadUserInfo.localizedText)
            }).disposeOnDeactivate(interactor: self)

        case .moveToCurrent:
            router?.updateMapViewCamera()
        case .detailPrice:
            router?.routeToDetailPrice()
        case .coupon:
            removeTimerRequestOnlineDrivers()
            
            guard let promotion = self.component.currentPromotion else {
                self.booking.map { $0.originAddress.coordinate }.take(1).bind(onNext: { [weak self] coord in
                    self?.router?.routeToPromotion(coordinate: coord)
                }).disposeOnDeactivate(interactor: self)
                return
            }
            router?.routeToDetailPromotion(with: promotion.code, maifest: promotion.mainfest)
            
        default:
            break
        }
    }
    
    func forceUseCash() {
        let cash = PaymentCardDetail.cash()
        self.router?.bookingConfirmView.selectPaymentView?.select(card: cash)
    }
    
    func switchPaymentMoveBack() {
        self.router?.dismissCurrentRoute(completion: {
            UIApplication.setStatusBar(using: .default)
        })
    }
    
    func switchPaymentChoose(by card: PaymentCardDetail) {
        guard let method = card.type.method else {
            return
        }
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            if !(method == PaymentMethodCash || method == PaymentMethodVATOPay) {
                wSelf.mutablePaymentStream.update(select: card)
            }
            wSelf.update(payment: card)
        })
    }
    
    func tripCompleted() {
        self.listener?.onTripCompleted()
    }
    
    func routeToConfirmBookingServiceMore() {
        
        let selectedServiceObser = self.component.transportStream.selectedService.take(1)
        let listAdditionalServicesObserable = self.component.confirmStream.listAdditionalServicesObserable.take(1)
        
        Observable.combineLatest(selectedServiceObser, listAdditionalServicesObserable).bind { [weak self] (currentService, listAdditionalServices) in
            guard let me = self else { return }
            
            let listService = listAdditionalServices.filter({ $0.canAppy(serviceId: currentService.service.id) })
            if !listService.isEmpty {
                me.router?.routeToConfirmBookServiceMore(listService: listService, listCurrentSelectedService: me.currentListServiceMore)
            }
            
        }.disposeOnDeactivate(interactor: self)
    }
}

extension BookingConfirmInteractor: SafeTimerDelegate {
    private func addTimerRequestOnlineDrivers() {
        var defautTime = defautTimeDriver
        if let appConfigure = FirebaseHelper.shareInstance()?.appConfigure,
            appConfigure.request_driver_config != nil,
            let time = appConfigure.request_driver_config?.duration,
            time > minDurationRequest {
            defautTime = Double(time)
        }
        
        timerGetListDriverOnline = SafeTimer()
        timerGetListDriverOnline?.schedule(timeInterval: defautTime, repeats: true, userInfo: nil)
        timerGetListDriverOnline?.delegate = self
    }
    
    private func removeTimerRequestOnlineDrivers() {
        timerGetListDriverOnline?.invalidate()
        timerGetListDriverOnline = nil
    }
    
    private func requestOnlineDrivers(coordinate: CLLocationCoordinate2D) {
        onlineWaitingDisposable?.dispose()
        onlineWaitingDisposable = nil
        
        onlineWaitingDisposable = self.authenticatedStream.firebaseAuthToken
            .take(1)
            .flatMap({ [weak self](authToken) -> Observable<(HTTPURLResponse, Message<[SearchDriver]>)> in
                
                guard let idService = self?.component.confirmStream.model.service?.service.id else {
                    return Observable.empty()
                }
                
                return Requester.requestDTO(using: VatoAPIRouter.searchDriver(authToken: authToken, coordinate: coordinate, service: idService),
                                            method: .post,
                                            encoding: JSONEncoding.default)
            })
            .timeout(.seconds(30), scheduler: SerialDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { [weak self](_, message) in
                self?.component.mutableBooking.updateBooking(onlineDrivers: message.data)
            })
    }
    
    
    func safeTimerDidTrigger(_ safeTimer: SafeTimer) {
        booking
            .take(1)
            .subscribe(onNext: { [weak self] booking in
                self?.requestOnlineDrivers(coordinate: booking.originAddress.coordinate)
            })
        .disposeOnDeactivate(interactor: self)
    }
    
    func presentMessage(message: String) {
        router?.presentMessage(message: message)
    }
}

// MARK: InTripHandler
extension BookingConfirmInteractor: Weakifiable {
    func inTripMoveBack() {
        router?.handlerIntrip.state.onNext(.cancel)
    }
    
    func inTripCancel() {
        router?.handlerIntrip.state.onNext(.clientCancel)
    }
    
    func inTripNewBook() {
        router?.handlerIntrip.state.onNext(.newTrip)
    }
    
    func inTripComplete() {
        router?.handlerIntrip.state.onNext(.completed)
    }
}

// MARK: Wallet
extension BookingConfirmInteractor {
    func wallet(handle action: WalletAction) {
        switch action {
        case .moveBack:
            router?.dismissCurrentRoute(completion: router?.bookingConfirmView.selectPaymentView?.resetListenAddCard)
        }
    }
    
    func getBalance() {}
    func updateUserBalance(cash: Double, coin: Double) {}
    func showTopUp() {}
    
    private func routeToAddCard() {
        router?.routeToAddCard()
    }
}

