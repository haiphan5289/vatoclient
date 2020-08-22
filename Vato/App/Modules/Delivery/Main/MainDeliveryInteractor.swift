//  File name   : MainDeliveryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 8/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

import FwiCore
import FwiCoreRX
import Alamofire

protocol MainDeliveryRouting: ViewableRouting, BookingConfirmRoutingProtocol, BookingConfirmIntripProtocol {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    var bookingConfirmView: MainDeliveryBookingView { get }
    var viewControllable: ViewControllable { get }
    
    func routeNoteDelivery(note: NoteDeliveryModel?)
    func routeToInputInformation(_ type: DeliveryInputInformation, serviceType: DeliveryServiceType)
    func presentAlert(message: String)
    func presentMessage(message: String)
    func showAlertIntrip(tripId: String)
    //    func routeToLocationPicker(type: SearchType, address: AddressProtocol?)
    func routeToPinLocation(address: AddressProtocol?, isOrigin: Bool)
    func detactCurrentChild()
    func routeToDeliverySuccess()
    func routeToAddCard()
}

protocol MainDeliveryPresentable: Presentable {
    var listener: MainDeliveryPresentableListener? { get set }
    func showConfirmView()
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol MainDeliveryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func deliveryMoveBack()
    func onTripCompleted()
    func booking(use: JSON)
}

protocol CopiableProtocol {
    associatedtype Object
    func copy() -> Object
}

final class DeliveryInputInformation: DestinationDisplayProtocol, CopiableProtocol, Equatable {
    let type: DeliveryDisplayType
    var name: String?
    var phone: String?
    var email: String?
    var packageNote: String?
    var packageSize: PackageSize?
    var isMe: Bool?
    var originalDestination: AddressProtocol?
    var timeStamp: Double
    var estimatePrice: Int?
    
    var icon: UIImage? {
        return type.icon
    }
    var description: String {
        var result: String?
        if let name = name, let phone = phone {
            switch type {
            case .sender:
                result = "\(name)\n\(phone)"
            case .receiver:
                result = "\(name)  •  \(phone)"
            }
        }
        
        return result ?? ""
    }
    
    var title: String {
        return originalDestination?.name ?? ""
    }
    
    var valid: Bool {
        return originalDestination != nil && name != nil && phone != nil
    }
    
    var shoppingValid: Bool {
        return originalDestination != nil &&
            !(name?.isEmpty ?? true) &&
            !(phone?.isEmpty ?? true) &&
            !(packageNote?.isEmpty ?? true) &&
            estimatePrice != nil
    }
    
    var supplyTripInfo: SupplyTripInfo? {
        let s = SupplyTripInfo()
        s.estimatedPrice = (self.estimatePrice != nil) ? Double(self.estimatePrice!) : nil
        s.productDescription = self.packageNote
        return s
    }
    
    init(type: DeliveryDisplayType) {
        self.type = type
        self.timeStamp = Date().timeIntervalSince1970
    }
    
    func copy() -> DeliveryInputInformation {
        let type = self.type
        let new = DeliveryInputInformation(type: type)
        new.name = self.name
        new.phone = self.phone
        new.isMe = self.isMe
        new.originalDestination = originalDestination
        new.timeStamp = self.timeStamp
        new.packageNote = self.packageNote
        new.estimatePrice = self.estimatePrice
        return new
    }
    
    static func == (lhs: DeliveryInputInformation, rhs: DeliveryInputInformation) -> Bool {
        return lhs.name == lhs.name && lhs.phone == rhs.phone
    }
}

final class MainDeliveryInteractor: PresentableInteractor<MainDeliveryPresentable>, BookingDependencyProtocol, ActivityTrackingProgressProtocol {
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
            if let defaultSelect = self.loadDefault(by: b.defaultSelect.paymentMethod) {
                self.update(payment: defaultSelect)
            }
        }
    }
    var listFare: PublishSubject<[FareDisplay]> = PublishSubject()
    private var isLoading: Bool = false
    
    /// Class's public properties.
    weak var router: MainDeliveryRouting?
    weak var listener: MainDeliveryListener?
    private var currentInput: DeliveryDisplayType = .sender
    private var isPressMap: DeliveryDisplayType = .sender
    private lazy var infoSender: DeliveryInputInformation = DeliveryInputInformation(type: .sender)
    private lazy var infoReceiver: DeliveryInputInformation = DeliveryInputInformation(type: .receiver)
    private lazy var disposeBag = DisposeBag()
    private var foundRoute: Bool = false
    private (set) var directionFares: ReplaySubject<BookingConfirmDirectionFares> = ReplaySubject.create(bufferSize: 1)
    var groupServiceName: String {
        return "DELIVERY"
    }
    
    var segment: String? {
        return VatoServiceType.delivery.segment
    }
    
    private lazy var listDeliveryVehicle: [DeliveryVehicle] = [
        DeliveryVehicle(id: nil, imageURL: "ic_service_bike", name: Text.bikeDelivery.localizedText),
        DeliveryVehicle(id: nil, imageURL: "ic_service_truck500", name: Text.truck500Kg.localizedText),
        DeliveryVehicle(id: nil, imageURL: "ic_service_truck1000", name: Text.truck1Ton.localizedText),
        DeliveryVehicle(id: nil, imageURL: "ic_service_truck2000", name: Text.truck2Ton.localizedText),
    ]
    
    /// Class's constructor.
    init(presenter: MainDeliveryPresentable, component: BookingConfirmDeliveryType) {
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        FireBaseTimeHelper.default.startUpdate()
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
        
        points.subscribe { [weak self](event) in
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
        
        self.loadDefaultDomesticReceiver()
    }
    
    override func willResignActive() {
        FireBaseTimeHelper.default.stopUpdate()
        super.willResignActive()
        self.component.bookingPoints.updateDefaultServiceMore(list: nil)
        component.confirmStream.cleanUp()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    let component: BookingConfirmDeliveryType
    private lazy var mSender = ReplaySubject<DeliveryInputInformation>.create(bufferSize: 1)
    private lazy var mReceiver = ReplaySubject<DeliveryInputInformation>.create(bufferSize: 1)
    private let subjectRoute: ReplaySubject<RouteTrip?> = ReplaySubject.create(bufferSize: 1)
    private let subjectZone: ReplaySubject<Zone> = ReplaySubject.create(bufferSize: 1)
    private var currentNote: NoteDeliveryModel? {
        didSet {
            component.noteStream.update(note: currentNote?.description ?? "")
        }
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
               .updatePaymentStream(use: wSelf.component.mutablePaymentStream,
                                    controller: wSelf.router?.viewControllable.uiviewController,
                                    type: .service(service: vatoService))
       })).disposeOnDeactivate(interactor: self)
    }
    
    private var currentListServiceMore: [AdditionalServices] = []
    private var otherOptions: String?
    
// MARK: - Domestic properties
    
    internal lazy var mDomesticReceiver = ReplaySubject<[DeliveryInputInformation]>.create(bufferSize: 1)
    internal lazy var domesticInfoReceiver: [DeliveryInputInformation] = []

}

// MARK: MainDeliveryInteractable's members
extension MainDeliveryInteractor: MainDeliveryInteractable, LocationRequestProtocol, Weakifiable {
    //pinAddress
    func pinAddressDismiss() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    private func updateMap(model: MapModel.Place) {
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
        Observable.combineLatest(self.mSender, self.mReceiver) { (v1, v2) -> Bool in
            return v1.valid && v2.valid
            }
            .take(1)
            .bind(onNext: { [weak self] (valid) in
                guard let wSelf = self else {
                    return
                }
                if !valid {
                    switch wSelf.isPressMap {
                    case .sender:
                        wSelf.router?.routeToInputInformation(wSelf.infoSender, serviceType: .URBAN_DELIVERY)
                    default:
                        break
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    func pinDidselect(model: MapModel.Place) {
        router?.dismissCurrentRoute(completion: { [weak self] in
            self?.updateMap(model: model)
        })
    }
    
    func dimissServiceMore() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func confirmBookingService(arrayServiceMore: [AdditionalServices]) {
        self.component.bookingPoints.updateDefaultServiceMore(list: arrayServiceMore)
        self.component.priceUpdate.price.filterNil().take(1).asObservable().subscribe(onNext: { [weak self] (price) in
            guard let wSelf = self else {
                return
            }
            wSelf.currentListServiceMore = arrayServiceMore
            var tip: Double = 0
            for service in arrayServiceMore {
                tip += service.caculateAdditionalAmount(currentAmount: Double(price.lastPrice))
            }
            tip = Double(tip.roundPrice())
            wSelf.component.tipStream.update(tip: tip)
        }).disposed(by: disposeBag)
        router?.detactCurrentChild()
        
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.update(model: model)
        })
    }
    
    private func update(model: AddressProtocol) {
        updateAddress(model: model, update: weakify({ (new, wSelf) in
            let infoSender = wSelf.infoSender
            let marker = MarkerHistory(with: new)
            infoSender.originalDestination = marker.address
            wSelf.infoSender = infoSender
            wSelf.mSender.onNext(infoSender)
        }))
    }
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func closeDetailPrice() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func detailBook() {
        router?.dismissCurrentRoute(completion: {
            self.activeBook()
        })
    }
    
    func routeToNote() {
        router?.routeNoteDelivery(note: currentNote)
    }
    
    var currentMethod: PaymentMethod {
        return component.priceUpdate.methodPayment
    }
    
    var eMethod: Observable<PaymentCardDetail> {
        return self.component.priceUpdate.eMethod
    }
    
    var profileStream: ProfileStream {
        return component.profileStream
    }
    
    var errorStream: ErrorBookingStream {
        return component.errorStream
    }
    
    var eApplyPromotion: Observable<Void> {
        return component.promotionStream.eUsePromotion
    }
    
    var domesticReceivers: Observable<[DestinationDisplayProtocol]>  {
        return mDomesticReceiver.map({ $0.map({ $0 as DestinationDisplayProtocol}) }).asObservable()
    }
    
    private func activeBook() {
        guard !isLoading else { return }
        self.checkLastTrip()
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
    
    func move(to type: BookingConfirmType) {
        switch type {
        case .note:
            router?.routeToNote()
        case .wallet:
            self.component.transportStream.selectedService.take(1).bind(onNext: { [weak self] (s) in
                self?.router?.routeToWallet(vatoServiceType: s.service.serviceType)
            }).disposeOnDeactivate(interactor: self)
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
    
    func detachMe() {
        self.moveBack()
    }
    
    func tripCompleted() {
        self.router?.dismissCurrentRoute(completion: listener?.onTripCompleted)
    }
    
    func fillInformation(new: DeliveryInputInformation, serviceType: DeliveryServiceType) {
        router?.dismissCurrentRoute(completion: { [weak self] in
            guard let wSelf = self else { return }
            
            switch wSelf.currentInput {
            case .sender:
                wSelf.infoSender = new
                wSelf.mSender.onNext(new)
            case .receiver:
                if serviceType == .URBAN_DELIVERY {
                    wSelf.infoReceiver = new
                    wSelf.mReceiver.onNext(new)
                } else {
                    if let idx = wSelf.domesticInfoReceiver.firstIndex(where: { $0.timeStamp == new.timeStamp }) {
                        wSelf.domesticInfoReceiver[idx] = new
                    } else {
                        wSelf.domesticInfoReceiver.append(new)
                    }
                    wSelf.mDomesticReceiver.onNext(wSelf.domesticInfoReceiver)
                }
            }
        })
        
    }
    
    func fillInformationMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func dismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func forceUseCash() {
        let cash = PaymentCardDetail.cash()
        self.router?.bookingConfirmView.selectPaymentView?.select(card: cash)
    }
    
    func closeTip() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func update(tip: Double) {
        component.tipStream.update(tip: tip)
    }
    
    func change(method: ChangeMethod) {
        switch method {
        case .cash:
            forceUseCash()
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
    
    func promotionMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func update(model: PromotionModel?) {
        component.promotionStream.update(promotion: model)
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
    
    func update(routes: String) {
        component.transportStream.update(routes: routes)
    }
    
    func updateNote(note: NoteDeliveryModel) {
        self.currentNote = note
    }
}

// MARK: MainDeliveryPresentableListener's members
extension MainDeliveryInteractor: MainDeliveryPresentableListener {
    var listVehicle: Observable<[DeliveryVehicle]> {
        return Observable<[DeliveryVehicle]>.just(self.listDeliveryVehicle)
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
        
        let newBook = Booking(tripType: BookService.fixed, originAddress: l1, destinationAddress1: l2)
        
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
    
    var sender: Observable<DestinationDisplayProtocol> {
        return mSender.map { $0 as DestinationDisplayProtocol}.observeOn(MainScheduler.asyncInstance)
    }
    
    var receiver: Observable<DestinationDisplayProtocol> {
        return mReceiver.map { $0 as DestinationDisplayProtocol}.observeOn(MainScheduler.asyncInstance)
    }
    
    func inputInformation(_ type: DeliveryDisplayType, serviceType: DeliveryServiceType, item: DeliveryInputInformation?) {
        let model: DeliveryInputInformation
        self.currentInput = type
        switch type {
        case .sender:
            model = infoSender
            router?.routeToInputInformation(model, serviceType: serviceType)
        case .receiver:
            if serviceType == .URBAN_DELIVERY {
                model = infoReceiver
                router?.routeToInputInformation(model, serviceType: serviceType)
            } else {
                if let existingItem = self.domesticInfoReceiver.first(where: { $0.timeStamp == item?.timeStamp}) {
                     router?.routeToInputInformation(existingItem, serviceType: serviceType)
                } else {
                    let newItem = DeliveryInputInformation.init(type: .receiver)
                    router?.routeToInputInformation(newItem, serviceType: serviceType)

                }
            }
        }
    }
    
    func moveBack() {
        if let promotion = self.component.currentPromotion,
            let promotionToken = promotion.data?.data?.promotionToken {
            self.revertPromotion(from: promotionToken).subscribe(onNext: { (_) in
                printDebug("Success to cancel promotion token.")
            }, onError: { (e) in
                printDebug(e.localizedDescription)
            }).disposed(by: disposeBag)
            
        }
        listener?.deliveryMoveBack()
    }
    
    func selectOtherDeliveryOption(_ option: String) {
        self.otherOptions = option
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func moveToPinLocation() {
        self.currentInput = .sender
        router?.routeToPinLocation(address: infoSender.originalDestination, isOrigin: true)
    }
    
    
    func removeReceiverIfNeed(type: DeliveryDisplayType) {
        let model: DeliveryInputInformation
        self.currentInput = type
        if infoReceiver.description.count == 0 {
            model = infoReceiver
            router?.routeToInputInformation(model, serviceType: .URBAN_DELIVERY)
        } else {
            infoReceiver = DeliveryInputInformation(type: .receiver)
            mReceiver.onNext(infoReceiver)
        }
    }
    
    func removeDomesticItem(item: DeliveryInputInformation?) {
        guard let item = item else { return }
        
        self.domesticInfoReceiver.removeAll(where: { $0.timeStamp == item.timeStamp })
        self.mDomesticReceiver.onNext(domesticInfoReceiver)
    }
}

extension MainDeliveryInteractor: UsePromotionProtocol {
    var authenticatedStream: AuthenticatedStream {
        return component.authenticated
    }
}

extension MainDeliveryInteractor {
    private func routeToServiceMoreInteractor() {
        let selectedServiceObser = self.component.transportStream.selectedService.take(1)
        let listAdditionalServicesObserable = self.component.confirmStream.listAdditionalServicesObserable.take(1)
        
        Observable.combineLatest(selectedServiceObser, listAdditionalServicesObserable).bind { [weak self] (currentService, listAdditionalServices) in
            guard let me = self else { return }
            //            me.currentListServiceMore = listAdditionalServices
            let listService = listAdditionalServices.filter({ $0.canAppy(serviceId: currentService.service.id) })
            if !listService.isEmpty {
                me.router?.routeToServiceMore(listService:listService , listCurrentSelectedService: me.currentListServiceMore)
            }
            
            }.disposeOnDeactivate(interactor: self)
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
    
    func routeToDeliverySuccess() {
        router?.routeToDeliverySuccess()
    }
    
    func presentMessage(message: String) {
        router?.presentMessage(message: message)
    }
}

// MARK: Class's private methods
private extension MainDeliveryInteractor {
    func findZone() {
        guard let coordinate = currentBook?.originAddress.coordinate else {
            return
        }
        self.findZone(from: coordinate).subscribe(onNext: { [weak self](zone) in
            self?.subjectZone.onNext(zone)
        }).disposeOnDeactivate(interactor: self)
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
    
    func findSelectDefault(from values: [FareDisplay]) {
        // canpromotion cũ
        // tim promotion lại
        let defaultChooseService = Car(id: VatoServiceType.delivery.rawValue, choose: true, name: Text.delivery.localizedText, description: nil)
        
        // Check if ready set default
        let nextService = defaultChooseService
        let customSelect = nextService.id
        
        let fare = values.first(where: { customSelect == $0.setting.service && $0.setting.listTripType.contains(1) })
        let select = ServiceChooseGroup(idService: nextService.id, service: nextService, fare: fare)
        self.component.transportStream.update(select: select)
    }
    
    private func findBookAddPrice() {
        self.firebaseDatabase.findBookAddPrice().take(1).subscribe(onNext: { [weak self] tip in
            self?.component.tipStream.update(config: tip)
            }, onError: { e in
                let error = e as NSError
                printDebug(error)
        }).disposeOnDeactivate(interactor: self)
    }
    
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
        configHandlerPayment()
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
        subjectZone.bind(onNext: weakify({ (z, wSelf) in
            wSelf.component.transportStream.update(zone: z)
            wSelf.preparePrice()
        })).disposeOnDeactivate(interactor: self)
        
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

// MARK: InTripHandler
extension MainDeliveryInteractor {
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
extension MainDeliveryInteractor {
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
