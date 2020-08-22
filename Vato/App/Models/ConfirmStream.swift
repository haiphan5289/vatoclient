//
//  ConfirmStream.swift
//  FaceCar
//
//  Created by Dung Vu on 9/21/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation
import RIBs
import RxSwift

import FwiCoreRX

protocol PriceStream {
    var booking: Observable<Booking> { get }
    var methodPayment: PaymentMethod { get }
    var eMethod: Observable<PaymentCardDetail> { get }
    var price: Observable<BookingConfirmPrice?> { get }
    func update(userInfor: UserInfo)
    func calculatePriceAgain()
    func canPayment() throws -> Bool
    func cleanUp()
}

protocol NoteStream {
    var valueNote: Observable<String> { get }
}

protocol TipStream {
    var currentTip: Observable<Double> { get }
    var price: Observable<BookingConfirmPrice?> { get }
    var configs: Observable<TipConfig> { get }
}

protocol PromotionStream {
    var ePromotion: Observable<PromotionModel?> { get }
    var updateDiscount: Observable<Void> { get }
    var eUsePromotion: Observable<Void> { get }
}

protocol ErrorBookingStream {
    var eError: Observable<Error> { get }
}

// MARK: Mutable stream
protocol MutableErrorBooking: ErrorBookingStream {
    func update(from error: Error)
}

protocol MutableTip: TipStream {
    func updateSelect(from selects: [PriceAddition])
    func update(tip: Double)
    func update(config: TipConfig)
    func update(supply: SupplyTripInfo?)
}

protocol MutableNoteStream: NoteStream {
    func update(note text: String)
}

protocol MutablePriceStream: PriceStream {
    func update(paymentMethod: PaymentCardDetail)
}

protocol TransportStream {
    var listFarePredicate: [FarePredicate]? { get }
    var listFareModifier: [FareModifier]? { get }
    var listAdditionalServicesObserable: Observable<[AdditionalServices]> {get}
    var selectedService: Observable<ServiceCanUseProtocol> { get }
    var listFare: Observable<[FareDisplay]> { get }
    var listService: Observable<[Service]> { get }
    var booking: Observable<Booking> { get }
    var serviceGroup: Observable<[ServiceGroup]> { get }
    func findGroup() -> Observable<[TransportGroup]>
}

protocol MutableTransportStream: TransportStream {
    func update(serviceGroups:[ServiceGroup])
    func update(book: Booking)
    func update(listPredicate: [FarePredicate])
    func update(listModifiers: [FareModifier])
    func update(listAdditionalServices: [AdditionalServices])
    func update(select: ServiceCanUseProtocol)
    func updateList(listFare: [FareDisplay])
    func updateListService(list: [Service])
    func update(zone: Zone)
    func update(routes: String)
    func updateSelectFavorite(use: Bool)
    func setStatusAutoApplyPromotionCode(isAutoApply: Bool)
}

protocol MutablePromotion: PromotionStream {
    func update(promotion: PromotionModel?)
    func resetPromotion()
}

final class ConfirmStreamImpl: LoadingAnimateProtocol, DisposableProtocol  {
    let model: BookingConfirmInformation
    private(set) var listFarePredicate: [FarePredicate]?
    private(set) var listFareModifier: [FareModifier]?
    private(set) var listAdditionalServices: [AdditionalServices]? {
        didSet {
            listAdditionalServicesSubject.onNext(listAdditionalServices ?? [])
        }
    }
    private(set) var tipConfig: TipConfig?
    private var calculateAgain: Bool = false
    // requirement: auto apply promotion code: if first enter confirm booking and not have promotion availalbe ==> not show message
    var isEnableMessagePromotionStatus = true
    // fix bug: when apply code from promotion leftmenu => bind to call apply promotion 2 time (1 is change payment method, 2 is change promotion)
    var flagApplyCodeInPromotionLeftMenu = true
    
    var currentPromotion: PromotionModel? {
        return self.model.promotionModel
    }
    
    var isAutoApplyPromotionCode = true
    lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    
    init(with model: BookingConfirmInformation) {
        self.model = model
        setupRX()
    }

    private func setupRX() {
        valueNote.bind { [weak self] value in
            self?.model.note = value
        }.disposed(by: disposeBag)

        selectedServiceSubject.bind { [weak self] value in
            let canChange: Bool
            if let current = self?.model.service {
                canChange = !(current.service.id == value.service.id)
            } else {
                canChange = true
            }
            guard canChange || self?.calculateAgain == true else { return }
            self?.calculateAgain = false
            self?.model.service = value
            self?.update(tip: 0)
            self?.updatePrice()
            
            // check autoapply or not
            if self?.isAutoApplyPromotionCode == false
                || self?.model.booking?.tripType == BookService.quickBook {
                self?.reCalculatePromotion()
            } else {
                self?.reCalculatePromotionWithAutoApplyPromotion()
            }
        }.disposed(by: disposeBag)

        subjectTip.bind { [weak self] v in
            self?.model.tip = v
            self?.updatePrice()
        }.disposed(by: disposeBag)

        subjectTotal.bind { [weak self] price in
            self?.model.informationPrice = price
        }.disposed(by: disposeBag)

        subjectPaymentMethod.bind { [weak self] payment in
            // if apply promotion from leftmenu -> if faild the first time not check autoapply but then must be check auto apply if user change severice, distance, payment method
            if self?.flagApplyCodeInPromotionLeftMenu == true,
                self?.currentPromotion != nil {
                self?.isAutoApplyPromotionCode = false
            }
            
            self?.flagApplyCodeInPromotionLeftMenu = false
            self?.model.paymentMethod = payment
            if self?.isAutoApplyPromotionCode == false
                || self?.model.booking?.tripType == BookService.quickBook {
                self?.reCalculatePromotion()
            } else {
                self?.reCalculatePromotionWithAutoApplyPromotion()
            }
        }.disposed(by: disposeBag)

        subjectPromotion.bind { [weak self] promotion in
            self?.model.promotionModel = promotion
            self?.reCalculatePromotion()
        }.disposed(by: disposeBag)
        
        showLoading(use: trackProgress.asObservable())
    }
    
    private func reCalculatePromotion() {
        guard let promotion = model.promotionModel else {
            return
        }
        let method = model.paymentMethod?.type.method ?? PaymentMethodCash
        defer { eUpdateDiscount.onNext(()) }
        do {
            let s = self.model.service?.service.serviceType ?? .none
            try promotion.calculateDiscount(from: model.booking, paymentType: method, price: model.informationPrice, serviceType: s)
            self.eApplyUsePromotion.onNext(())
        } catch {
            self.update(from: error)
        }
    }

    private func updatePrice() {
        let price = BookingConfirmPrice()
        price.calculateLastPrice(from: self.model.service, tip: self.model.tip ?? 0)
        subjectTotal.onNext(price)
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    private let noteSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let selectedServiceSubject = ReplaySubject<ServiceCanUseProtocol>.create(bufferSize: 1)
    private let listFareSubject = ReplaySubject<[FareDisplay]>.create(bufferSize: 1)
    private let listServiceSubject = ReplaySubject<[Service]>.create(bufferSize: 1)
    private let subjectTip = ReplaySubject<Double>.create(bufferSize: 1)
    private let subjectTotal = ReplaySubject<BookingConfirmPrice?>.create(bufferSize: 1)
    private let subjectConfigsAddPrice = ReplaySubject<TipConfig>.create(bufferSize: 1)
    private let subjectPaymentMethod = ReplaySubject<PaymentCardDetail>.create(bufferSize: 1)
    private let subjectBooking = ReplaySubject<Booking>.create(bufferSize: 1)
    private let subjectPromotion = ReplaySubject<PromotionModel?>.create(bufferSize: 1)
    private let subjectError = PublishSubject<Error>()
    private var eUpdateDiscount: PublishSubject<Void> = PublishSubject()
    private var eApplyUsePromotion: PublishSubject<Void> = PublishSubject()
    private var subjectServiceGroup = ReplaySubject<[ServiceGroup]>.create(bufferSize: 1)
    private let listAdditionalServicesSubject = ReplaySubject<[AdditionalServices]>.create(bufferSize: 1)
}

extension ConfirmStreamImpl: MutablePriceStream {
    func cleanUp() {
        self.update(listAdditionalServices: [])
        self.update(tip: 0)
        disposeBag = DisposeBag()
    }
    
    func calculatePriceAgain() {
        calculateAgain = true
    }
    
    func update(userInfor: UserInfo) {
        self.model.userInfor = userInfor
    }

    func canPayment() throws -> Bool {
        return try self.model.canPayment()
    }

    var eMethod: Observable<PaymentCardDetail> {
        return subjectPaymentMethod.asObserver().distinctUntilChanged()
    }

    var methodPayment: PaymentMethod {
        return self.model.paymentMethod?.type.method ?? PaymentMethodCash
    }

    var price: Observable<BookingConfirmPrice?> {
        return subjectTotal.asObserver()
    }

    func update(paymentMethod: PaymentCardDetail) {
        subjectPaymentMethod.onNext(paymentMethod)
    }
}

// MARK: -- Note
extension ConfirmStreamImpl: MutableNoteStream {
    func update(note text: String) {
        noteSubject.onNext(text)
    }

    var valueNote: Observable<String> {
        return noteSubject.asObserver()
    }
}

// MARK: -- Tip
extension ConfirmStreamImpl: MutableTip {
    var currentTip: Observable<Double> {
        return subjectTip.asObserver()
    }

    func update(config: TipConfig) {
        self.tipConfig = config
        subjectConfigsAddPrice.onNext(config)
    }

    var configs: Observable<TipConfig> {
        return subjectConfigsAddPrice.asObserver()
    }

    func update(tip: Double) {
        subjectTip.onNext(tip)
    }

    func updateSelect(from selects: [PriceAddition]) {
        self.model.addPrice = selects
    }
    
    func update(supply: SupplyTripInfo?) {
        self.model.supplyInfo = supply
    }
}

// MARK: -- Transport
extension ConfirmStreamImpl: MutableTransportStream {
    
    func findGroup() -> Observable<[TransportGroup]> {
        let listFare = self.listFare
        
        let source: Observable<[TransportGroup]> = listFare.map({ list -> [TransportGroup] in
            let items = list.map { item -> ServiceCanUseProtocol in
                let idService = item.setting.service
                let car = Car(id: idService, choose: true, name: item.setting.name ?? "", description: nil)
                let service = ServiceChooseGroup(idService: idService, service: car, fare: item)
                return service
            }
            let values = Dictionary(grouping: items, by: { GroupTransport.check(idService: $0.idService).name })
            return values.compactMap { TransportGroup(name: $0.key, services: $0.value) }
        })
        return source
    }
    
    var listAdditionalServicesObserable: Observable<[AdditionalServices]> {
        return self.listAdditionalServicesSubject.asObserver()
    }
    
    func update(serviceGroups: [ServiceGroup]) {
        subjectServiceGroup.onNext(serviceGroups)
    }
    
    var serviceGroup: Observable<[ServiceGroup]> {
        return subjectServiceGroup.asObserver()
    }
    
    func setStatusAutoApplyPromotionCode(isAutoApply: Bool) {
        self.isAutoApplyPromotionCode = isAutoApply
    }
    
    var booking: Observable<Booking> {
        return subjectBooking.asObserver()
    }

    func updateSelectFavorite(use: Bool) {
        self.model.useFavoriteService = use
    }

    func update(routes: String) {
        self.model.polyline = routes
    }

    func update(zone: Zone) {
        self.model.zone = zone
    }

    func update(listModifiers: [FareModifier]) {
        self.listFareModifier = listModifiers
    }
    func update(listAdditionalServices: [AdditionalServices]){
        self.listAdditionalServices = listAdditionalServices
    }

    func update(listPredicate: [FarePredicate]) {
        var newList = listPredicate
        if let book = model.booking.map({ ($0.originAddress.coordinate, $0.destinationAddress1?.coordinate) }) {
            let type: Int = book.1 != nil ? BookService.fixed : BookService.quickBook
            newList = listPredicate.filter { ($0.tripType == type || $0.tripType == BookService.applyAll) && $0.validate(startBook: book.0, endBook: book.1, adjust: 0) }
        }
        self.listFarePredicate = newList
    }

    func update(book: Booking) {
        self.model.booking = book
        subjectBooking.onNext(book)
    }

    func updateListService(list: [Service]) {
        listServiceSubject.onNext(list)
    }

    func update(select: ServiceCanUseProtocol) {
        var new = select
        new.update(from: self.listFarePredicate, with: self.listFareModifier)
        selectedServiceSubject.onNext(new)
    }

    func updateList(listFare listService: [FareDisplay]) {
        listFareSubject.onNext(listService)
    }

    var selectedService: Observable<ServiceCanUseProtocol> {
        return selectedServiceSubject.asObserver()
    }

    var listFare: Observable<[FareDisplay]> {
        return listFareSubject.asObserver()
    }

    var listService: Observable<[Service]> {
        return listServiceSubject.asObserver()
    }
}

// MARK: - Promotion
extension ConfirmStreamImpl: MutablePromotion {
    var eUsePromotion: Observable<Void> {
        return eApplyUsePromotion
    }
    
    var updateDiscount: Observable<Void> {
        return eUpdateDiscount
    }
    
    var ePromotion: Observable<PromotionModel?> {
        return subjectPromotion.asObserver()
    }

    func update(promotion: PromotionModel?) {
        subjectPromotion.onNext(promotion)
    }
    
    func resetPromotion() {
        subjectPromotion.onNext(nil)
    }
}

// MARK: - Error
extension ConfirmStreamImpl: MutableErrorBooking {
    var eError: Observable<Error> {
        return subjectError.asObserver()
    }

    func update(from error: Error) {
        self.subjectError.onNext(error)
    }
}
