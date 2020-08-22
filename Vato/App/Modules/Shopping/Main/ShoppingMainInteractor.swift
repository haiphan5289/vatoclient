//  File name   : ShoppingMainInteractor.swift
//
//  Author      : khoi tran
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol ShoppingMainRouting: ViewableRouting, BookingConfirmRoutingProtocol, BookingConfirmIntripProtocol {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToPinLocation(address: AddressProtocol?, isOrigin: Bool)
    func routeToLocationPicker(type: SearchType, address: AddressProtocol?)
    func routeToShoppingFillInformation(info: DeliveryInputInformation)
    func routeNoteDelivery(note: NoteDeliveryModel?)

    func presentAlert(message: String)
    func detactCurrentChild()
    func showAlertIntrip(tripId: String)
    func presentMessage(message: String)

}

protocol ShoppingMainPresentable: Presentable {
    var listener: ShoppingMainPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func showConfirmView()
}

protocol ShoppingMainListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func shoppingMoveBack()
    func booking(use: JSON)
    func onTripCompleted()

}

final class ShoppingMainInteractor: PresentableInteractor<ShoppingMainPresentable>, BookingDependencyProtocol, ActivityTrackingProgressProtocol {
    
    var mComponent: BookingConfirmComponentProtocol & BookingConfirmSecurityProtocol {
        return component
    }
    
    var currentBook: Booking? {
        didSet {
            guard let b = self.currentBook else {
                return
            }
            self.component.priceUpdate.calculatePriceAgain()
            self.component.transportStream.update(book: b)
            if let defaultSelect = self.loadDefault(by: PaymentMethodVATOPay) {
                self.update(payment: defaultSelect)
            }
        }
    }
    
    private var currentNote: NoteDeliveryModel? {
        didSet {
            component.noteStream.update(note: currentNote?.description ?? "")
        }
    }
    
    var listFare: PublishSubject<[FareDisplay]>  = PublishSubject()
    let component: BookingConfirmDeliveryType
    private var isLoading: Bool = false
    private var currentInput: DeliveryDisplayType = .sender
    private lazy var infoSender: DeliveryInputInformation = DeliveryInputInformation(type: .sender)
    private lazy var infoReceiver: DeliveryInputInformation = DeliveryInputInformation(type: .receiver)
    private lazy var mSender = ReplaySubject<DeliveryInputInformation>.create(bufferSize: 1)
    private lazy var mReceiver = ReplaySubject<DeliveryInputInformation>.create(bufferSize: 1)
    private let subjectRoute: ReplaySubject<RouteTrip?> = ReplaySubject.create(bufferSize: 1)
    private let subjectZone: ReplaySubject<Zone> = ReplaySubject.create(bufferSize: 1)
    private (set) var directionFares: ReplaySubject<BookingConfirmDirectionFares> = ReplaySubject.create(bufferSize: 1)
    var groupServiceName: String {
        return ""
    }
    
    private var currentListServiceMore: [AdditionalServices] = []
    private var otherOptions: String?
    private var foundRoute: Bool = false

    var profileStream: ProfileStream {
        return component.profileStream
    }
    /// Class's public properties.
    weak var router: ShoppingMainRouting?
    weak var listener: ShoppingMainListener?
    var segment: String? {
        return VatoServiceType.shopping.segment
    }

    /// Class's constructor.
    init(presenter: ShoppingMainPresentable, component: BookingConfirmDeliveryType) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        updateZoneAddress()
        loadDefaultSender()
        // todo: Implement business logic here.
    }
    
    
    private func loadDefaultSender() {
        let points = component.bookingPoints.booking.take(1)
        let userInfor = component.profileStream.client.take(1)
        
        userInfor.bind { [weak self](client) in
            guard let wSelf = self else {
                return
            }
            let sender = wSelf.infoSender
            let user = client.user
            sender.name = user?.displayName
            sender.phone = user?.phone
            sender.email = user?.email
            wSelf.mSender.onNext(sender)
            }.disposeOnDeactivate(interactor: self)
        
        points.timeout(0.5, scheduler: MainScheduler.instance).subscribe { [weak self](event) in
            guard let wSelf = self else {
                return
            }
            switch event {
            case .next(let address):
                let sender = wSelf.infoSender
                sender.originalDestination = address.originAddress
                wSelf.mSender.onNext(sender)
            case .error(let e):
                print(e.localizedDescription)
            default:
                break
            }
            }.disposeOnDeactivate(interactor: self)
        
        self.mReceiver.onNext(infoReceiver)
        
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: ShoppingMainInteractable's members
extension ShoppingMainInteractor: ShoppingMainInteractable {
    func presentMessage(message: String) {
        router?.presentMessage(message: message)
    }
    
    func dismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func updateNote(note: NoteDeliveryModel) {
        self.currentNote = note
    }
    
    var errorStream: ErrorBookingStream {
        return component.errorStream
    }
    
    var eMethod: Observable<PaymentCardDetail> {
        return self.component.priceUpdate.eMethod
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    var eApplyPromotion: Observable<Void> {
        return component.promotionStream.eUsePromotion
    }
    
    func detachMe() {
        self.moveBack()
    }

    func closeTip() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToNote() {
        router?.routeNoteDelivery(note: currentNote)
    }
    
    func update(tip: Double) {
        component.tipStream.update(tip: tip)
    }
    
    func update(supply: SupplyTripInfo?) {
        component.tipStream.update(supply: supply)
    }
    
    func change(method: ChangeMethod) {
        switch method {
        case .cash:
            let cash = PaymentCardDetail.cash()
            self.component.priceUpdate.update(paymentMethod: cash)
        case .inputMoney:
            self.router?.routeToTopupWallet()
        }
    }
    
    func closeChangeMethod() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func closeInputPromotion() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func update(model: PromotionModel?) {
        component.promotionStream.update(promotion: model)

    }
    
    func promotionMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func dismissDetail() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func requestBookCancel(revert need: Bool) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.applyPromotionAgain()
        })
    }
    
    func bookChangeToInTrip(by tripId: String) {
        self.router?.dismissCurrentRoute(true, completion: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.router?.moveToIntrip(by: tripId)
        })
    }
    
    func switchPaymentMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func switchPaymentChoose(by card: PaymentCardDetail) {
       guard let method = card.type.method else {
            return
        }
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            if !(method == PaymentMethodCash || method == PaymentMethodVATOPay) {
                wSelf.component.mutablePaymentStream.update(select: card)
            }
            wSelf.update(payment: card)
        })
    }
    
    func forceUseCash() {
        let cash = PaymentCardDetail.cash()
        self.update(payment: cash)
    }
    
    
    
    func closeDetailPrice() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func detailBook() {
        router?.dismissCurrentRoute(completion: {
            self.activeBook()
        })
    }
    
    func dimissServiceMore() {
         router?.dismissCurrentRoute(completion: nil)
    }
    
    func confirmBookingService(arrayServiceMore: [AdditionalServices]) {
        self.component.bookingPoints.updateDefaultServiceMore(list: arrayServiceMore)
        self.component.priceUpdate.price.filterNil().take(1).asObservable().subscribe(onNext: { (price) in
            self.currentListServiceMore = arrayServiceMore
            var tip: Double = 0
            for service in arrayServiceMore {
                tip += service.caculateAdditionalAmount(currentAmount: Double(price.lastPrice))
            }
            tip = Double(tip.roundPrice())
            self.component.tipStream.update(tip: tip)
        }).disposeOnDeactivate(interactor: self)
        router?.detactCurrentChild()
    }
    
    func cancelPromotion() {
        router?.dismissCurrentRoute(completion: { [weak self] in
            self?.revert()
        })
    }
    
    func revert() {
        guard let promotion = self.component.currentPromotion,
            let promotionToken = promotion.data?.data?.promotionToken
            else {
                return
        }
        self.component.promotionStream.update(promotion: nil)
        self.revertPromotion(from: promotionToken).subscribe(onNext: { (_) in
            printDebug("Success to cancel promotion token.")
        }, onError: { (e) in
            printDebug(e.localizedDescription)
        }).disposeOnDeactivate(interactor: self)
        
    }
    
    func fillInformation(new: DeliveryInputInformation) {
        router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.infoReceiver = new
            wSelf.mReceiver.onNext(new)
            wSelf.update(supply: new.supplyTripInfo)
        })
    }
    
    func shoppingFillInformationMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func pinAddressDismiss() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func pinDidselect(model: MapModel.Place) {
        router?.dismissCurrentRoute(completion: {
            let location = CLLocationCoordinate2D(latitude: model.location?.lat ?? 0, longitude: model.location?.lon ?? 0)
            let address = Address(
                placeId: nil,
                coordinate: location,
                name: model.primaryName ?? "",
                thoroughfare: "",
                locality: "",
                subLocality: model.address ?? "",
                administrativeArea: "",
                postalCode: "",
                country: "",
                lines: [],
                zoneId: 0,
                isOrigin: false,
                counter: 0,
                distance: nil,
                favoritePlaceID: 0)
            self.infoSender.originalDestination = address
            self.mSender.onNext(self.infoSender)
            
        })
    }
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            if let infoSender = self?.infoSender {
                let marker = MarkerHistory(with: model)
                infoSender.originalDestination = marker.address
                self?.infoSender = infoSender
                self?.mSender.onNext(infoSender)
            }
        })
    }
    
    private func applyPromotionAgain() {
        guard let promotion = self.component.currentPromotion,
            let promotionToken = promotion.data?.data?.promotionToken
            else {
                return
        }
        
        self.revertPromotion(from: promotionToken).subscribe(onNext: { [weak self](_) in
            printDebug("Success to cancel promotion token.")
            self?.reUsePromotion()
            }, onError: { (e) in
                printDebug(e.localizedDescription)
        }).disposeOnDeactivate(interactor: self)
    }
    
    
    func reUsePromotion() {
        guard let promotion = self.component.currentPromotion else {
            return
        }
        
        let payment = promotion.paymentMethod
        let manifest = promotion.mainfest
        let code = promotion.code
        
        self.requestPromotionData(from: code).trackProgressActivity(self.indicator).map { data -> PromotionModel in
            let model = PromotionModel(with: code)
            model.data = data
            model.paymentMethod = payment
            model.mainfest = manifest
            return model
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.component.promotionStream.update(promotion: $0)
                }, onError: { [weak self](e) in
                    self?.component.errorStream.update(from: PromotionError.applyCode(e: e))
                    self?.component.confirmStream.resetPromotion()
            }).disposeOnDeactivate(interactor: self)
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
    
    private func activeBook() {
           guard !isLoading else { return }
           self.checkLastTrip()
               .observeOn(MainScheduler.instance)
               .timeout(10, scheduler: MainScheduler.asyncInstance)
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
            case .review:
                wSelf.move(to: .coupon)
            }
        }).disposeOnDeactivate(interactor: self)
    }
    
    private func moveToBook() {
        self.checkMethod().subscribe(onNext: { [weak self](_) in
            guard let wSelf = self else { return }
            
            if wSelf.currentNote == nil {
                wSelf.component.currentModelBook.note = wSelf.otherOptions
            } else {
                wSelf.currentNote?.option = wSelf.otherOptions
            }
            
            // Update info
            wSelf.component.currentModelBook.senderName = wSelf.infoSender.name
            wSelf.component.currentModelBook.userInfor?.update(phone: wSelf.infoSender.phone ?? "")
            wSelf.component.currentModelBook.receiverName = wSelf.infoReceiver.name
            wSelf.component.currentModelBook.receiverPhone = wSelf.infoReceiver.phone
            
            let json = wSelf.component.currentModelBook.exportJson() ?? [:]
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
            self.router?.routeToWallet(vatoServiceType: .shopping)
//            self.component.transportStream.selectedService.take(1).bind(onNext: { [weak self] (s) in
//                self?.router?.routeToWallet(vatoServiceType: s.service.serviceType)
//            }).disposeOnDeactivate(interactor: self)
        case .addTip:
            //            router?.routeToTip()
            self.routeToConfirmBookingServiceMore()
        //            self.routeToServiceMoreInteractor()
        case .chooseInformation:
            print("Change transport")
        //            router?.routeToDetailPrice()
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
//                        wSelf.router?.routeToChooseMethod()
                        wSelf.router?.presentMessage(message: Text.notEnoughMoneyShopping.localizedText)
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
            fatalError("Please Implement")
        case .detailPrice:
            router?.routeToDetailPrice()
        case .coupon:
            guard let promotion = self.component.currentPromotion else {
                self.component.bookingPoints.booking.map { $0.originAddress.coordinate }.take(1).bind(onNext: { [weak self] coord in
                    self?.router?.routeToPromotion(coordinate: coord)
                }).disposeOnDeactivate(interactor: self)
                return
            }
            router?.routeToDetailPromotion(with: promotion.code, maifest: promotion.mainfest)
            
        default:
            break
        }
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
    
    func routeToConfirmBookingServiceMore() {
        
        let selectedServiceObser = self.component.transportStream.selectedService.take(1)
        let listAdditionalServicesObserable = self.component.confirmStream.listAdditionalServicesObserable.take(1)
        
        Observable.combineLatest(selectedServiceObser, listAdditionalServicesObserable).bind { [weak self] (currentService, listAdditionalServices) in
            guard let me = self else { return }
            let listService = listAdditionalServices.filter({ $0.canAppy(serviceId: currentService.service.id) })
            if !listService.isEmpty {
                me.router?.routeToServiceMore(listService: listService, listCurrentSelectedService: me.currentListServiceMore)
            }
            
            }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: ShoppingMainPresentableListener's members
extension ShoppingMainInteractor: ShoppingMainPresentableListener, Weakifiable {
    var sender: Observable<DestinationDisplayProtocol> {
        return mSender.map { $0 as DestinationDisplayProtocol}.observeOn(MainScheduler.asyncInstance)
    }
    
    var receiver: Observable<DestinationDisplayProtocol> {
        return mReceiver.map { $0 as DestinationDisplayProtocol}.observeOn(MainScheduler.asyncInstance)
    }
    
    
    var routeTrip: Observable<RouteTrip> {
        return subjectRoute.observeOn(MainScheduler.asyncInstance).filterNil()
    }
    
    var ready: Observable<Bool> {
        return Observable.combineLatest(mSender, mReceiver) { (v1, v2) -> Bool in
            return v1.valid && v2.valid
        }
    }
    
    private func findRoute() {
        directionFares.map { $0.direction_info }.take(1).bind(onNext: weakify({ (router, wSelf) in
            wSelf.currentListServiceMore.removeAll()
            wSelf.update(routes: router.overviewPolyline)
            wSelf.subjectRoute.onNext(router.route)
            wSelf.presentConfirmView()
            wSelf.foundRoute = true
        })).disposeOnDeactivate(interactor: self)
    }
    
    func book() {
        guard let l1 = infoSender.originalDestination,
            let l2 = infoReceiver.originalDestination,
            allowBooking() else {
                return
        }
        
        let newBook = Booking(tripType: BookService.fixed, originAddress: l2, destinationAddress1: l1)
        
        if currentBook == newBook && self.foundRoute == true {
            self.presentConfirmView()
            return
        }
        
        let runCheck: (Booking) ->() = { [weak self] in
            guard let wSelf = self else { return }
            wSelf.currentBook = $0
            wSelf.foundRoute = false
            wSelf.findZone()
            wSelf.findRoute()
            wSelf.checkTip()
        }
        
        if currentBook != nil {
            component.bookingPoints.booking.take(1).bind { (book) in
                newBook.defaultSelect.copy(from: book.defaultSelect)
                runCheck(newBook)
            }.disposeOnDeactivate(interactor: self)
        } else {
            runCheck(newBook)
        }
    }
    
    func update(routes: String) {
        component.transportStream.update(routes: routes)
    }
    
    private func allowBooking() -> Bool {
        guard let l1 = infoSender.originalDestination, let l2 = infoReceiver.originalDestination else {
            return false
        }
        // Check distance
        let distance = round(l1.coordinate.distance(to: l2.coordinate))
        guard distance >= 50.0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.router?.presentAlert(message: Text.minDistanceBetweenOriginAndDestination.localizedText)
            }
            return false
        }
        return true
    }
    
    func presentConfirmView() {
        self.presenter.showConfirmView()
    }
    
    func inputInformation(_ type: DeliveryDisplayType, serviceType: DeliveryServiceType, item: DeliveryInputInformation?) {
        self.router?.routeToShoppingFillInformation(info: self.infoReceiver)
    }
    
    func routeToLocationPicker() {
        self.currentInput = .sender
        self.router?.routeToLocationPicker(type: .shopping(origin: false), address: infoSender.originalDestination)
    }
    
    func removeReceiverIfNeed(type: DeliveryDisplayType) {}
    
    func moveBack() {
        if let promotion = self.component.currentPromotion,
            let promotionToken = promotion.data?.data?.promotionToken {
            self.revertPromotion(from: promotionToken).subscribe(onNext: { (_) in
                printDebug("Success to cancel promotion token.")
            }, onError: { (e) in
                printDebug(e.localizedDescription)
            }).disposeOnDeactivate(interactor: self)
            
        }
        self.listener?.shoppingMoveBack()
    }
    
    func moveToPinLocation() {
        self.currentInput = .sender
        router?.routeToPinLocation(address: infoSender.originalDestination, isOrigin: true)
    }
    
    func tripCompleted() {
        self.router?.dismissCurrentRoute(completion: listener?.onTripCompleted)
//         listener?.onTripCompleted()
    }
}

// MARK: Class's private methods
private extension ShoppingMainInteractor {
    private func checkTip() {
        component.bookingPoints.booking.take(1).bind { [weak self](b) in
            guard let wSelf = self else { return }
            guard let listServiceMore = b.defaultSelect.arrayServiceMore, !listServiceMore.isEmpty else {
                return
            }
            wSelf.confirmBookingService(arrayServiceMore: listServiceMore)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func setupRX() {
        // todo: Bind data stream here.
        registerHandlerFares()
        self.indicator.asObservable().bind { [weak self]  (isloading, progress) in
            self?.isLoading = isloading
            }.disposeOnDeactivate(interactor: self)
        
        eMethod.subscribe(onNext: { [weak self] card in
            self?.component.mutablePaymentStream.update(select: card)
        }).disposeOnDeactivate(interactor: self)
        
        component
            .bookingPoints
            .promotion.filter { model -> Bool in
                let p = model?.data?.data?.promotionPredicates.first
                return p?.service == VatoServiceType.delivery.rawValue
            }
            .take(1)
            .filterNil()
            .bind { [weak self] (promotionModel) in
                // if have current promotion in the first time push ==> apply from left menu or manifest
                // if apply from left menu if promotion is invalid => not auto apply promotion, but then user change service, distance, payment method must auto apply promotion
                self?.component.transportStream.setStatusAutoApplyPromotionCode(isAutoApply: false)
                self?.update(model: promotionModel)
            }
            .disposeOnDeactivate(interactor: self)
        
        self.component.priceUpdate.price.filterNil().map({ BookingConfirmUpdateType.updatePrice(infor: $0) }).bind { [weak self] update in
            self?.router?.update(from: update)
            }.disposeOnDeactivate(interactor: self)
        
        profileStream.user.bind { [weak self] user in
            self?.component.priceUpdate.update(userInfor: user)
            }.disposeOnDeactivate(interactor: self)
        
        profileStream.client.take(1).timeout(.milliseconds(400), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self](v) in
            guard let wSelf = self else { return }
            let nextPayment = v.paymentMethod ?? PaymentMethodCash
            let card = wSelf.loadDefaultMethod(from: nextPayment)
            wSelf.component.priceUpdate.update(paymentMethod: card)
            }, onError: { [weak self](e) in
                guard let wSelf = self else { return }
                let nextPayment = PaymentMethodCash
                let card = wSelf.loadDefaultMethod(from: nextPayment)
                wSelf.component.priceUpdate.update(paymentMethod: card)
        }).disposeOnDeactivate(interactor: self)
        
        self.findBookAddPrice()
        
        component.noteStream.valueNote.bind { [weak self] in
            self?.component.bookingPoints.updateDefaultNote(note: $0)
            self?.router?.update(from: BookingConfirmUpdateType.note(string: $0))
        }.disposeOnDeactivate(interactor: self)
        
        
        self.listFare.map { $0.filter { $0.setting.serviceType == .delivery }}.subscribe(onNext: { [weak self] in
            // sort
            let new = $0.sorted(by: >)
            self?.component.transportStream.updateList(listFare: new)
            }, onError: { e in
                printDebug(e.localizedDescription)
        }).disposeOnDeactivate(interactor: self)
        
        self.component.transportStream.selectedService.bind { [weak self] in
            self?.router?.update(from: .updateListService(listService: [$0]))
            }.disposeOnDeactivate(interactor: self)
        
        component.bookingPoints.booking.subscribe(onNext: {[weak self] (booking) in
            self?.router?.update(from: .updateBooking(booking: booking))
        }).disposeOnDeactivate(interactor: self)
        
        component.bookingPoints.booking.map { $0.originAddress.coordinate }.bind(onNext: weakify({ (coord, wSelf) in
            PromotionManager.shared.checkPromotion(coordinate: coord)
        })).disposeOnDeactivate(interactor: self)
        
        self.component.transportStream.selectedService.map({ BookingConfirmUpdateType.service(type: $0) }).bind { [weak self] in
            self?.router?.update(from: $0)
            }.disposeOnDeactivate(interactor: self)
        
        self.component.tipStream.currentTip.map({ BookingConfirmUpdateType.updateTip(tip: $0) }).bind { [weak self] in
            self?.router?.update(from: $0)
            }.disposeOnDeactivate(interactor: self)
        
        // Promotion
        self.component.promotionStream.ePromotion.bind { [weak self] in
            self?.router?.update(from: BookingConfirmUpdateType.updatePromotion(model: $0))
            }.disposeOnDeactivate(interactor: self)
        
        // Find Zone
        self.component.transportStream.listFare.bind { [weak self] in
            self?.findSelectDefault(from: $0)
        }.disposeOnDeactivate(interactor: self)
        
        // Find Price
        subjectZone.bind(onNext:{ [weak self] z in
            guard let wSelf = self else { return }
            wSelf.component.transportStream.update(zone: z)
            wSelf.preparePrice()
        }).disposeOnDeactivate(interactor: self)
        
        //service more
        let listAdditionalServicesObserable = self.component.confirmStream.listAdditionalServicesObserable.map { $0.filter({ $0.changeable == false }) }.take(1)
        let priceStream = self.component.priceUpdate.price.filterNil().distinctUntilChanged()
        let service = self.component.transportStream.selectedService
        
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
    
    func findZone() {
        guard let coordinate = currentBook?.originAddress.coordinate else {
            return
        }
        self.findZone(from: coordinate).subscribe(onNext: { [weak self](zone) in
            self?.subjectZone.onNext(zone)
        }).disposeOnDeactivate(interactor: self)
    }
    
    func findSelectDefault(from values: [FareDisplay]) {
        // canpromotion cũ
        // tim promotion lại
        let defaultChooseService = Car(id: VatoServiceType.shopping.rawValue, choose: true, name: "Đi chợ", description: nil)
        
        // Check if ready set default
        let isFixedPrice = self.currentBook?.tripType == BookService.fixed
        let nextService = defaultChooseService
        let customSelect = nextService.id
        
        let fare = values.first(where: { customSelect == $0.setting.service && $0.setting.listTripType.contains(1) })
        // let select = ServiceUse(idService: customSelect, service: nextService, fare: fare, predicate: nil, modifier: nil, isFixedPrice: isFixedPrice, priceTotal: 0, priceDiscount: 0)
        let select = ServiceChooseGroup(idService: nextService.id, service: nextService, fare: fare)
        self.component.transportStream.update(select: select)
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
    
    private func loadMethod(by m: PaymentMethod) -> PaymentCardDetail {
        switch m {
        case PaymentMethodVATOPay:
            return PaymentCardDetail.vatoPay()
        default:
            return PaymentCardDetail.cash()
        }
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
    
    private func findBookAddPrice() {
        self.firebaseDatabase.findBookAddPrice().take(1).subscribe(onNext: { [weak self] tip in
            self?.component.tipStream.update(config: tip)
            }, onError: { e in
                let error = e as NSError
                printDebug(error)
        }).disposeOnDeactivate(interactor: self)
    }
    
    private func loadDefault(by method: PaymentMethod?) -> PaymentCardDetail? {
        guard let method = method else { return nil }
        return loadMethod(by: method)
    }
}


extension ShoppingMainInteractor: UsePromotionProtocol {
    var authenticatedStream: AuthenticatedStream {
        return component.authenticated
    }
}

extension ShoppingMainInteractor {
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
