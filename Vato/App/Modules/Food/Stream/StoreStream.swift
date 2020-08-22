//  File name   : StoreStream.swift
//
//  Author      : Dung Vu
//  Created date: 12/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import Alamofire

enum StoreBookingState {
    case NEW
    case DEFAULT
}

typealias BasketModel = [DisplayProduct: BasketStoreValueProtocol]

protocol BasketStoreValueProtocol {
    var note: String? { get }
    var quantity: Int { get }
}

struct DateTime: Equatable {
    struct Config {
        static let formatTime = "HH:mm"
        static let formatDate = "dd/MM/yyyy"
        static let timeAppendDelivery: TimeInterval = 600 //minute
    }
    
    var date: Date
    var time: Date
    
    var timeDescription: String { return time.string(from: Config.formatTime) }
    var dateDescription: String { return date.string(from: Config.formatDate) }
    
    func string() -> String { return "\(timeDescription) - \(dateDescription)" }
    
    static func defautValue(interval: TimeInterval = Config.timeAppendDelivery) -> DateTime {
        let result = Date().addingTimeInterval(interval)
        return DateTime(date: result, time: result)
    }
    
    static func == (lhs: DateTime, rhs: DateTime) -> Bool {
        return lhs.date == rhs.date && lhs.time == rhs.time
    }
    
    func toString() -> String {
        let calendar = Calendar.current
        let hour = String(format: "%02d", calendar.component(.hour, from: time))
        let minute = String(format: "%02d", calendar.component(.minute, from: time))
        let second = String(format: "%02d", calendar.component(.second, from: time))
        return date.string(from: "yyyy-MM-dd") + "T" + "\(hour):\(minute):\(second).000"
    }
}

protocol StoreIdentifyProtocol {
    var id : Int? { get }
    var coordinate: CLLocationCoordinate2D { get }
}

extension FoodExploreItem: StoreIdentifyProtocol{}


protocol StoreStream {
    var basket: Observable<BasketModel> { get }
    var address: Observable<AddressProtocol> { get }
    var note: Observable<NoteDeliveryModel> { get }
    var timeDelivery: Observable<DateTime?> { get }
    var quoteCart: Observable<QuoteCart?> { get }
    var paymentMethod: Observable<PaymentCardDetail> { get }
    subscript (item: DisplayProduct) -> BasketStoreValueProtocol? { get }
    var storeBookingState: Observable<StoreBookingState> { get }
    var store: Observable<FoodExploreItem?> { get }
    var currentStoreId: Observable<Int?> { get }
    var bookingTimeInterval: TimeInterval { get }
    var stateOrder: Observable<StoreOrderState> { get }
    var showingAlert: Observable<Bool> { get }
}

typealias QuoteCartParams = (params: JSON, method: HTTPMethod)
protocol MutableStoreStream: StoreStream {
    func update(basket: BasketModel)
    func update(item: DisplayProduct, value: BasketStoreValueProtocol?)
    func update(time: DateTime?)
    func update(address: AddressProtocol)
    func update(quoteCard: QuoteCart?)
    func update(note: NoteDeliveryModel)
    func update(paymentCard: PaymentCardDetail)
    func update(store: FoodExploreItem?)
    func update(stateOrder: StoreOrderState?)
    
    func createParams(customerId: Int64) -> Observable<QuoteCartParams?>
    func reset()
    func update(bookingState: StoreBookingState)
    func updateBookingTimeInterval(bookingTimeInterval: TimeInterval)
    func updateStore(identify: StoreIdentifyProtocol?)
    
    func update(showingAlert: Bool)
}

final class StoreStreamImpl {
    private lazy var mBasket: BehaviorRelay<BasketModel> = BehaviorRelay(value: [:])
    private lazy var mTimeDelivery: BehaviorRelay<DateTime?> = BehaviorRelay(value: nil)
    private lazy var mAddress: ReplaySubject<AddressProtocol> = ReplaySubject.create(bufferSize: 1)
    
    private lazy var mQuoteCart: BehaviorRelay<QuoteCart?> = BehaviorRelay(value: nil)
    private let mNote: BehaviorRelay<NoteDeliveryModel> = BehaviorRelay(value: NoteDeliveryModel(note: "", option: ""))
    private let mPaymentMethod: BehaviorRelay<PaymentCardDetail> = BehaviorRelay(value: PaymentCardDetail.cash())
    private let mBookingState = PublishSubject<StoreBookingState>()
    private let mStore: BehaviorRelay<FoodExploreItem?> = BehaviorRelay(value: nil)
    private var _bookingTimeInterval: TimeInterval = 600
    @Replay(queue: MainScheduler.instance) private var storeValue: StoreIdentifyProtocol?
    private lazy var disposeBag = DisposeBag()
    @Replay(queue: MainScheduler.instance) private var mStateOrder: StoreOrderState?
    @Replay(queue: MainScheduler.instance) private var mShowing: Bool
    
    init() {
        mShowing = false
        setupRX()
    }
}

extension StoreStreamImpl: MutableStoreStream {
    var showingAlert: Observable<Bool> {
        return $mShowing
    }
    
    var stateOrder: Observable<StoreOrderState> {
        return $mStateOrder.filterNil()
    }
    
    var currentStoreId: Observable<Int?> {
        return $storeValue.map { $0?.id }
    }
    
    var store: Observable<FoodExploreItem?> {
        return mStore.asObservable()
    }
    
    var note: Observable<NoteDeliveryModel> {
        return mNote.asObservable()
    }
    
    func update(note: NoteDeliveryModel) {
        mNote.accept(note)
    }
    
    func update(address: AddressProtocol) {
        mAddress.onNext(address)
    }
    
    var timeDelivery: Observable<DateTime?> {
        return mTimeDelivery.asObservable()
    }
    
    func update(time: DateTime?) {
        mTimeDelivery.accept(time)
    }
    
    subscript(item: DisplayProduct) -> BasketStoreValueProtocol? {
        let value = mBasket.value[item]
        return value
    }
    
    var basket: Observable<BasketModel> {
        return mBasket.observeOn(MainScheduler.asyncInstance)
    }
    
    var address: Observable<AddressProtocol> {
        return mAddress.asObservable()
    }
    
    func update(basket: BasketModel) {
        mBasket.accept(basket)
    }
    
    func update(item: DisplayProduct, value: BasketStoreValueProtocol?) {
        var current = mBasket.value
        current[item] = value
        mBasket.accept(current)
    }
    
    func update(quoteCard: QuoteCart?) {
        mQuoteCart.accept(quoteCard)
    }
    
    func update(showingAlert: Bool) {
        mShowing = showingAlert
    }
    
    var quoteCart: Observable<QuoteCart?> {
        return mQuoteCart.asObservable()
    }
    
    func update(paymentCard: PaymentCardDetail) {
        mPaymentMethod.accept(paymentCard)
    }
    
    var paymentMethod: Observable<PaymentCardDetail> {
        return mPaymentMethod.asObservable()
    }
    
    var storeBookingState: Observable<StoreBookingState> {
        return mBookingState.asObservable()
    }
    
    var bookingTimeInterval: TimeInterval {
        return _bookingTimeInterval
    }
    
    func update(store: FoodExploreItem?) {
        mStore.accept(store)
    }
    
    func updateStore(identify: StoreIdentifyProtocol?) {
        storeValue = identify
    }
    
    func update(bookingState: StoreBookingState) {
        self.mBookingState.onNext(bookingState)
    }
    
    func updateBookingTimeInterval(bookingTimeInterval: TimeInterval) {
        self._bookingTimeInterval = bookingTimeInterval
    }

    func update(stateOrder: StoreOrderState?) {
        mStateOrder = stateOrder
    }
    
    func createParams(customerId: Int64) -> Observable<QuoteCartParams?> {
        let basketObserver = self.basket.take(1)
        let addressObserver = self.address.take(1)
        let quoteCartObserver = self.quoteCart.take(1)
        let timeDeliveryObserver = self.timeDelivery.take(1)
        let storeObserver = self.$storeValue.take(1)
        let payment = self.paymentMethod.take(1)
        
        return Observable.zip(basketObserver, addressObserver, quoteCartObserver, timeDeliveryObserver, storeObserver, payment).map { (basket, address, quoteCard, timeDelivery, store, p) -> QuoteCartParams? in
            var params: JSON = [:]
            guard let storeId = store?.id else {
                return nil
            }
            
            params["customerId"] = customerId
            params["itemsCount"] = basket.count
            params["paymentMethods"] = [p.type.rawValue]
            params["appliedVatoRuleIds"] = quoteCard?.appliedVatoRuleIds
            
            var quoteAddress: JSON = [:]
            let a = address.subLocality
            quoteAddress["address"] = a
            quoteAddress["customerId"] = customerId
            quoteAddress["customerNotes"] = ""
            quoteAddress["email"] = UserManager.instance.info?.email ?? ""
            quoteAddress["lat"] = address.coordinate.latitude
            quoteAddress["lon"] = address.coordinate.longitude
            quoteAddress["phone"] = UserManager.instance.info?.phone ?? ""
            params["quoteAddress"] = [quoteAddress]
            
            var quoteItems: [JSON] = []
            for (key, value) in basket {
                var quoteItem: JSON = [:]
                quoteItem["appliedRuleIds"] = []
                quoteItem["basePrice"] = 0.0
                quoteItem["description"] = value.note ?? ""
                quoteItem["name"] = key.name ?? ""
                quoteItem["priceInclTax"] = 0.0
                quoteItem["productId"] = key.productId
                quoteItem["qty"] = value.quantity
                quoteItem["quoteItemOptions"] = []
                quoteItem["storeId"] = storeId
                quoteItems.append(quoteItem)
            }
            params["quoteItems"] = quoteItems
            var distance: Double = 0
            if let store = store {
                let coord = store.coordinate
                if coord != kCLLocationCoordinate2DInvalid {
                    distance = coord.distance(to: address.coordinate)/1000
                }
            }
            var quoteShipment:JSON = [:]
            quoteShipment["distance"] = distance
            quoteShipment["method"] = 1 // Phuong thuc van chuyen : vato = 1
            
            params["quoteShipments"] = [quoteShipment]
            
            params["storeId"] = [storeId]
            if let timeDelivery = timeDelivery {
                let time = DateTime(date: timeDelivery.date.toGMT(), time: timeDelivery.time.toGMT())
                params["timePickup"] = time.toString()
            } else {
                params["timePickup"] = nil
            }
            
            var method: HTTPMethod = .post
            if let quoteId = quoteCard?.id {
                params["id"] = quoteId
                method = .put
            }
            
            if let ruleIds = quoteCard?.appliedRuleIds {
                params["appliedRuleIds"] = [ruleIds]
            } else {
                params["appliedRuleIds"] = []
            }
            
            if let v = quoteCard?.quoteCoupons?.first {
                var child = JSON()
                child["code"] = v.code
                child["value"] = 0
                params["coupons"] = [child]
            } else {
                params["coupons"] = []
            }
            
            if let v = quoteCard?.vatoCoupons?.first {
                var child = JSON()
                child["code"] = v.code
                child["value"] = 0
                params["vatoCoupons"] = [child]
            } else {
                params["vatoCoupons"] = []
            }
            
            return QuoteCartParams(params: params, method: method)
        }
    }
    
    func setupRX() {
        store.bind(onNext: weakify({ (item, wSelf) in
            wSelf.storeValue = item
        })).disposed(by: disposeBag)
    }
    
    func reset() {
        self.update(stateOrder: nil)
        self.update(basket: [:])
        self.update(note: NoteDeliveryModel(note: "", option: ""))
        self.update(time: nil)
        self.update(quoteCard: nil)
//        self.update(store: nil)
    }
}

extension StoreStreamImpl: Weakifiable {}
