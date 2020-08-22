//  File name   : BookingRequestCreateOrder.swift
//
//  Author      : Dung Vu
//  Created date: 4/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import VatoNetwork
import Alamofire
import FirebaseAuth
import FirebaseFirestore

fileprivate struct BookingRequestItem: Codable {
    let expired_at: TimeInterval
    let order_id: String
    var retry: Bool?
}

extension PaymentMethod {
    var rawName: String? {
        switch self {
        case PaymentMethodCash:
            return "CASH"
        case PaymentMethodVATOPay:
            return "WALLET"
        case PaymentMethodVisa:
            return "VISA"
        case PaymentMethodMastercard:
            return "MASTER"
        case PaymentMethodATM:
            return "ATM"
        default:
            return nil
        }
    }
}

fileprivate struct BookConfirmNotification: Codable, Comparable {
    struct Payload: Codable {
        var requestId: String?
        var tripId: String?
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            if let v = try? values.decode(Double.self, forKey: .requestId) {
                requestId = "\(v)"
            } else {
                requestId = try values.decodeIfPresent(String.self, forKey: .requestId)
            }
            tripId = try values.decodeIfPresent(String.self, forKey: .tripId)
        }
    }
    var action: String?
    let created_at: TimeInterval
    let expired_at: TimeInterval
    var type: String?
    var payload: Payload?
    
    static func == (lhs: BookConfirmNotification, rhs: BookConfirmNotification) -> Bool {
        let c1 = lhs.payload?.tripId == rhs.payload?.tripId
        let c2 = lhs.payload?.requestId == rhs.payload?.requestId
        let c3 = lhs.created_at == rhs.created_at
        return c1 && c2 && c3
    }
    
    static func < (lhs: BookConfirmNotification, rhs: BookConfirmNotification) -> Bool {
        let c1 = lhs.payload?.tripId == rhs.payload?.tripId
        let c2 = lhs.payload?.requestId == rhs.payload?.requestId
        let c3 = lhs.created_at < rhs.created_at
        return c1 && c2 && c3
    }
}

// MARK: Book error
enum BookingError: Error {
    case noNetwork
    case noDriver
    case noStartCoordinate
    case noDriverCoordinate
    case driverNotValid
    case noDriverAccept
    case driverInTrip
    case driverNotAccept
    case clientCantBook
    case cantCreateKey
    case cantEncodeKeyToData
    case other(error: Error)
    case errorRequestDriver
    case userCancel(error: Error)
}

extension NSError {
    convenience init(use message: String?) {
        var userInfo = JSON()
        userInfo[NSLocalizedDescriptionKey] = message
        self.init(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: userInfo)
    }
}

enum BookingRequestTripResultType {
    case newTrip(tripId: String)
    case error(e: Error)
    
    var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
}

final class BookingRequestCreateOrder: ManageListenerProtocol, Weakifiable {
    internal lazy var listenerManager: [Disposable] = []
    internal lazy var lock: NSRecursiveLock = NSRecursiveLock()
    @Replay(queue: MainScheduler.asyncInstance) private var currentOrderId: String?
    private let currentTime = FireBaseTimeHelper.default.currentTime
    private (set) lazy var tripId: ReplaySubject<BookingRequestTripResultType> = ReplaySubject.create(bufferSize: 1)
    private let order: FirebaseTrip?
    private lazy var disposeBag = DisposeBag()
    private lazy var cacheOrderRef: DocumentReference? = {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        let documentRef = Firestore.firestore().documentRef(collection: .custom(id: "Client"), storePath: .custom(path: "\(uid)"), action: .read)
        return documentRef
    }()
    private var isError = false
    private let rangePrice: (min: UInt32, max: UInt32)?
    private var currentRequest: BookingRequestItem?
    private var numberReTry: Int = 0
    init(use order: FirebaseTrip?, currentOrderId: String?, rangePrice: (min: UInt32, max: UInt32)? = nil) {
        self.order = order
        self.rangePrice = rangePrice
        defer {
            setupRX()
            prepareFindTrip()
        }
        self.currentOrderId = currentOrderId
    }
    
    deinit {
        LogEventHelper.log(key: "Book_Request_Number_Retry", params: ["number": numberReTry])
    }
    
    private func prepareFindTrip() {
        // 2 case: 1> not have current trip 2> load from current
        guard let order = self.order else {
            return retry()
        }
        createOrderRequest(order)
    }
    
    private func cacheOrder(json: JSON?) {
        cacheOrderRef?.find(action: .addField, json: json).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let snapshot):
                printDebug(snapshot?.data() ?? [:])
            case .error(let e):
                assert(false, e.localizedDescription)
            default:
                break
            }
        })).disposed(by: disposeBag)
    }
    
    private func setupRX() {
        $currentOrderId.bind(onNext: weakify({ (code, wSelf) in
            let json: JSON = ["currentBrief": ["orderId": code]]
            wSelf.cacheOrder(json: json)
        })).disposed(by: disposeBag)
    }
    
    private func createOrderRequest(_ order: FirebaseTrip) {
        defer {
            LogEventHelper.log(key: "Booking_Request_Create", params: nil)
        }
        let info = order.info
        var params = JSON()
        params["addition_price"] = Int(info.additionPrice)
        var departure = JSON()
        departure["address"] = info.startAddress
        departure["lat"] = info.startLat
        departure["lon"] = info.startLon
        departure["name"] = info.startName
        departure["place_id"] = order.start_place_id
        params["departure"] = departure
        
        var destination = JSON()
        destination["address"] = info.endAddress
        destination["lat"] = info.endLat
        destination["lon"] = info.endLon
        destination["name"] = info.endName
        destination["place_id"] = order.end_place_id
        params["destination"] = destination
        
        params["fare"] = order.originalP
        let p = PaymentMethod(rawValue: info.payment)
        params["payment_method"] = p.rawName
        var extra: JSON = [:]
        extra["senderName"] = info.senderName
        extra["receiverPhone"] = info.receiverPhone
        extra["receiverName"] = info.receiverName
        extra["clientVersion"] = info.clientVersion
        extra["contactPhone"] = info.contactPhone
        extra["senderPhone"] = info.senderPhone
        
        if let supplyInfo = try? info.supplyInfo?.toJSON() {
            extra["supplyInfo"] = supplyInfo
        }
        
        params["extra_data"] = extra
        
        if let rangePrice = rangePrice {
            params["min_fare"] = rangePrice.min
            params["max_fare"] = rangePrice.max
        }
        
        if info.promotionCode != nil {
            var promotion_info = JSON()
            promotion_info["code"] = info.promotionCode
            promotion_info["modifier_id"] = info.promotionModifierId
            promotion_info["token"] = info.promotionToken
            promotion_info["promotionDescription"] = info.promotionDescription
            params["promotion_info"] = promotion_info
        }
        params["service_id"] = info.serviceId
        params["trip_type"] = info.tripType
        params["note"] = info.note
        params["card_id"] = info.cardId
        
        let router = VatoAPIRouter.customPath(authToken: "", path: "trip/orders", header: nil, params: params, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<BookingRequestItem>.self,
                        method: .post,
                        encoding: JSONEncoding.default)
            .bind(onNext: weakify({ (r, wSelf) in
            switch r {
            case .success(let r):
                if r.error != nil {
                    let e = NSError(use: r.message)
                    wSelf.tripId.onNext(.error(e: BookingError.other(error: e)))
                } else {
                    guard let data = r.data else { return }
                    let id = data.order_id
                    wSelf.currentOrderId = id
                    wSelf.currentRequest = data
                    try? wSelf.createRetry(data.expired_at)
                    wSelf.addListenNotification()
                }
            case .failure(let e):
                defer {
                    LogEventHelper.log(key: "Booking_Request_Create_Fail", params: ["reason": e.localizedDescription])
                }
                let err = wSelf.verifyError(e: e)
                wSelf.tripId.onNext(.error(e: err))
            }
        })).disposed(by: disposeBag)
    }
    
    private func addListenNotification() {
        guard let userId = UserManager.instance.userId else { return }
        let collectionRef = Firestore.firestore().collection(collection: .custom(id: "Notifications"), .custom(id: "\(userId)"), .custom(id: "client")).whereField("action", isEqualTo: "CONFIRM")
        let requestId = $currentOrderId
        let list = collectionRef.listenChanges()
            .map { values -> [QueryDocumentSnapshot] in
               let r = values[from: .added].flatMap { $0 }
               return r
            }
            .debug("!!!!\(type(of: self)) Notifications:")
            .map {
                $0.compactMap ({ try? $0.decode(to: BookConfirmNotification.self) }).sorted(by: >)
        }
        let event = Observable.combineLatest(requestId, list) { (id, l) -> BookConfirmNotification? in
            l.first(where: { $0.payload?.requestId == id && $0.payload?.tripId != nil })
        }.filterNil()
        
        let dispose = event.take(1).bind(onNext: weakify({ (i, wSelf) in
            wSelf.handler(notify: i)
        }))
        add(dispose)
    }
    
    private func handler(notify: BookConfirmNotification) {
        guard let id = notify.payload?.tripId else {
            return
        }
        cleanUpListener()
        tripId.onNext(.newTrip(tripId: id))
    }
    
    private func createRetry(_ time: TimeInterval, canRetry: Bool = true) throws {
        guard canRetry else {
            throw BookingError.noDriver
        }
        let date = Date(timeIntervalSince1970: time / 1000)
        let remain = max(date.timeIntervalSinceNow, 0) + 1
        let dispose = Observable<Int>.interval(.seconds(Int(remain.rounded(.up))), scheduler: MainScheduler.asyncInstance).take(1).bind(onNext: weakify({ (_, wSelf) in
            wSelf.retry()
        }))
        add(dispose)
    }
    
    private func retry() {
        numberReTry += 1
        guard self.currentRequest?.retry == true else {
            self.isError = true
            self.tripId.onNext(.error(e: BookingError.noDriver))
            return
        }
        
        let dispose = $currentOrderId.filterNil().take(1).flatMap { (orderId) -> Observable<OptionalIgnoreMessageDTO<BookingRequestItem>> in
            let params = ["request_id": orderId]
            let router = VatoAPIRouter.customPath(authToken: "", path: "trip/orders/retry", header: nil, params: params, useFullPath: false)
            let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
            return network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<BookingRequestItem>.self,
                                   method: .post,
                                   encoding: JSONEncoding.default).map { try $0.get() }
        }.subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let item):
                if item.error != nil {
                    let e = NSError(use: item.message)
                    wSelf.tripId.onNext(.error(e: BookingError.other(error: e)))
                } else {
                    guard let data = item.data else { return }
                    do {
                        try wSelf.createRetry(data.expired_at)
                        wSelf.currentRequest = data
                    } catch {
                        wSelf.tripId.onNext(.error(e: error))
                    }
                }
            case .error(let e):
                let err = wSelf.verifyError(e: e)
                wSelf.tripId.onNext(.error(e: err))
            default:
                break
            }
        }))
        add(dispose)
    }
    
    private func verifyError(e: Error) -> BookingError {
        let e = e as NSError
        if e.code == NSURLErrorNotConnectedToInternet {
            return BookingError.noNetwork
        }
        return BookingError.other(error: e)
    }
    
    func cancel(end_reason: String?, end_reason_id: Int?) {
        let dispose = $currentOrderId.take(1).flatMap { [weak self](orderId) -> Observable<OptionalIgnoreMessageDTO<String>> in
            guard self?.isError == false else {
                let e = NSError(use: "Not have order!!!")
                return Observable.error(e)
            }
            
            guard let orderId = orderId else {
                let e = NSError(use: "Not have order!!!")
                return Observable.error(e)
            }
            var params: JSON = ["status": "CANCELED"]
            params["end_reason"] = end_reason
            params["end_reason_id"] = end_reason_id
            let router = VatoAPIRouter.customPath(authToken: "", path: "trip/orders/\(orderId)", header: nil, params: params, useFullPath: false)
            let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
            return network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<String>.self, method: .put, encoding: JSONEncoding.default).map { try $0.get() }
        }.subscribe(weakify({ (event, wSelf) in
            switch event {
            case .error(let e):
                #if DEBUG
                   print(e.localizedDescription)
                #endif
                wSelf.cacheOrder(json: ["currentBrief": [:]])
                wSelf.cleanUpListener()
                wSelf.tripId.onCompleted()
            case .next:
                wSelf.cacheOrder(json: ["currentBrief": [:]])
                wSelf.cleanUpListener()
                wSelf.tripId.onCompleted()
            default:
                break
            }
        }))
        add(dispose)
    }
}

struct TripOrderDetails: Codable {
    enum TripStatus: String, Codable {
        case `init` = "INIT"
        case processing = "PROCESSING"
        case canceled = "CANCELED"
        case completed = "COMPLETED"
        case failed = "FAILED"
        
        var finished: Bool {
            switch self {
            case .canceled, .completed, .failed:
                return true
            default:
                return false
            }
        }
    }
    
    struct Promotion: Codable {
        var code: String
        var modifier_id: Int
        var token: String
        var value: Int
    }
    var client_id: Int64?
    var destination: Coordinate?
    var origin: Coordinate?
    var expired_at: TimeInterval
    var id: String?
    var note: String?
    var payment_method: String?
    let retry: Bool
    var service_id: Int
    var status: TripStatus?
    var tip: Double?
    var trip_type: Int
    var promotion_info: Promotion?
    var tripId: String?
    
}

// MARK: - load old order
extension BookingRequestCreateOrder {
    static func clearCurrentOrder() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentRef = Firestore.firestore().documentRef(collection: .custom(id: "Client"), storePath: .custom(path: "\(uid)"), action: .read)
        documentRef.setData(["currentBrief": [:]], merge: true)
    }
    
    private static func findOrderId() -> Observable<String?> {
        guard let uid = Auth.auth().currentUser?.uid else { return Observable.empty() }
        let documentRef = Firestore.firestore().documentRef(collection: .custom(id: "Client"), storePath: .custom(path: "\(uid)"), action: .read)
        
        return documentRef.find(action: .get, json: nil, source: .server).map { (snapshot) -> String? in
            let d = snapshot?.data()
            guard let order: JSON = d?.value("currentBrief", defaultValue: nil) else { return nil }
            return order.value("orderId", defaultValue: nil)
        }
    }
    
    private static func requestInfo(order: String?) -> Observable<TripOrderDetails?> {
        guard let order = order, !order.isEmpty else {
            return Observable.empty()
        }
        let router = VatoAPIRouter.customPath(authToken: "", path: "trip/orders/\(order)", header: nil, params: nil, useFullPath: false)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: OptionalMessageDTO<TripOrderDetails>.self).map { r -> TripOrderDetails? in
            let result = try r.get().data
            if result?.tripId == nil {
                if let status = result?.status, status.finished {
                    throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "Trip finished."])
                }
                
                if result?.retry == false {
                    throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "Finish Retry."])
                }
            }
            
            return result
        }
    }
    
    static func loadCurrentOrder() -> Observable<TripOrderDetails?> {
        return findOrderId().flatMap(requestInfo).do(onError: { (e) in
            print(e.localizedDescription)
            self.clearCurrentOrder()
        })
    }
}
