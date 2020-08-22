//  File name   : BookingRequestInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 1/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Firebase
import FirebaseFirestore

protocol BookingRequestRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol BookingRequestPresentable: Presentable {
    var listener: BookingRequestPresentableListener? { get set }
    func clearWindows() -> Observable<Void>
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol BookingRequestListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func requestBookCancel(revert need: Bool)
    func bookChangeToInTrip(by tripId: String)
    
}

final class BookingRequestInteractor: PresentableInteractor<BookingRequestPresentable>, BookingRequestInteractable, BookingRequestPresentableListener, SafeAccessProtocol, Weakifiable {
    struct Config {
        static let prefixDebug = "BookingRequest :"
        static let numberDriverRequest = 10
        static let timeOutSendDriver: TimeInterval = 30
    }
    
    weak var router: BookingRequestRouting?
    weak var listener: BookingRequestListener?
    let dependency: BookingRequestDependency
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    var appConfig: AppConfigure? {
        didSet { findRadius() }
    }
    
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    var radius: Double = 2.0
    private (set) var page: Int = 0
    private (set) lazy var tripInfor = FirebaseTrip()
    private (set) lazy var _eError: PublishSubject<Error> = PublishSubject()
    private (set) lazy var _priceNew: PublishSubject<String> = PublishSubject()
    private (set) lazy var _eStatus: ReplaySubject<String> = ReplaySubject.create(bufferSize: 1)
    private (set) lazy var _eShowDriver: PublishSubject<DriverInforTuple> = PublishSubject()
    private (set) lazy var firestoreRef: Firestore = Firestore.firestore()
    private (set) lazy var tripFirestoreRef: CollectionReference = firestoreRef.collection(FirestoreTable.trip.name)
    private var bookingRequestCreateOrder: BookingRequestCreateOrder?
    
    var listDriver = [DriverSearch]()
    var listenerManager: [Disposable] = []
    var inBookTrip = false
    var currentDriver: Driver?
    var startCoordinate: CLLocationCoordinate2D?
  
    var currentLocation: CLLocation = CLLocation.zero
    private let defaultReachabilityService: DefaultReachabilityService? = try? DefaultReachabilityService()
    private (set)var currentCash: Double = 0
    var bookingRequestStream: BookingRequestStream {
        return dependency
    }
    
    var eStatus: Observable<String> {
        return _eStatus.observeOn(MainScheduler.asyncInstance)
    }
    
    var priceNew: Observable<String> {
        return _priceNew.observeOn(MainScheduler.asyncInstance)
    }
    var eError: Observable<Error> {
        return _eError.observeOn(MainScheduler.asyncInstance)
    }
    
    var eShowDriver: Observable<DriverInforTuple> {
        return _eShowDriver.observeOn(MainScheduler.asyncInstance)
    }
    
    init(presenter: BookingRequestPresentable, dependency: BookingRequestDependency) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        startCoordinate = self.dependency.currentModelBook.booking?.originAddress.coordinate
        findAppConfig()
        let deliveryMode = self.bookingRequestStream.currentModelBook.service?.service.serviceType == VatoServiceType.delivery
        let text = deliveryMode ? BookingRequestVC.Config.HeaderDeliverNote.begin : BookingRequestVC.Config.HeaderNote.begin
        _eStatus.onNext(text)
        self.dependency.profileStream.user.subscribe(onNext: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.currentCash = $0.cash
            let time = Date().toGMT().timeIntervalSince1970 * 1000
            let requestId = "b\($0.id)\(time)"
            wSelf.tripInfor.info.requestId = requestId
        }).disposeOnDeactivate(interactor: self)
        updateLocation()
        updateTripInfor()
        
    }
    
    func beginBook() {
        guard let defaultReachabilityService = self.defaultReachabilityService else {
            return findingTrip()
        }
        
        defaultReachabilityService.reachability.take(1).bind { [weak self] (status) in
            guard let wSelf = self else { return }
            guard status.reachable else {
                wSelf._eError.onNext(BookingError.noNetwork)
                return
            }
            wSelf.findingTrip()
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func findingTrip() {
//        prepare()
        requestBookOrder()
    }
    
    private func prepareMoveToTrip(tripId: String) {
        let time = FireBaseTimeHelper.default.currentTime
        let command = FirebaseTrip.BookCommand(status: .clientAgreed, time: time)
        tripInfor.info.tripId = tripId
        self.updateBook(by: command)
            .debug("\(Config.prefixDebug) client accept")
            .subscribe
        { [weak self](event) in
            guard let wSelf = self else { return }
            switch event {
            case .next:
                wSelf.listener?.bookChangeToInTrip(by: tripId)
            case .error(let e):
                wSelf.checkErrorTrip(from: e)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func requestBookOrder() {
        let book = self.dependency.currentModelBook
        if let v = book.service?.fare?.setting.totalPrice {
            tripInfor.originalP = v + UInt32(tripInfor.info.additionPrice)
        }
        tripInfor.start_place_id = book.booking?.originAddress.placeId
        tripInfor.end_place_id = book.booking?.destinationAddress1?.placeId
        
        bookingRequestCreateOrder = BookingRequestCreateOrder(use: tripInfor,
                                                              currentOrderId: nil,
                                                              rangePrice: self.dependency.currentModelBook.service?.rangePrice)
        bookingRequestCreateOrder?.tripId.observeOn(MainScheduler.asyncInstance).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let result):
                switch result {
                case .newTrip(let tripId):
                    wSelf.cleanAndMoveto(tripId: tripId)
                case .error(let e):
                    wSelf._eError.onNext(e)
                }
            case .completed, .error:
                wSelf.listener?.requestBookCancel(revert: true)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func cleanAndMoveto(tripId: String) {
        presenter.clearWindows().bind(onNext: weakify({ (wSelf) in
            wSelf.prepareMoveToTrip(tripId: tripId)
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func prepare() {
        findDriver()
    }
    
    private func updateLocation() {
        Observable<Int>.interval(.seconds(3), scheduler: SerialDispatchQueueScheduler(qos: .background)).startWith(-1).bind { [weak self](_) in
            self?.currentLocation = VatoLocationManager.shared.location.orNil(.zero)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func updateTripInfor() {
        let bookModel = self.dependency.currentModelBook
        self.tripInfor.updateInfor(from: bookModel)
    }
    
    func prepareInformationSendToDriver() {
        bookByFirestore().flatMap { [weak self] (_) -> Observable<Void> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.sendNotifyToDriver()
        }.subscribe { [weak self](event) in
            guard let wSelf = self else { return }
            switch event {
            case .next:
                wSelf.sendBookToDriver()
                // Cache
                let serviceId = wSelf.tripInfor.info.serviceId
                let json = try? wSelf.tripInfor.info.toJSON()
                UserDataHelper.shareInstance().saveJSONTrip(json, currentCar: serviceId)
            case .error(let e):
                wSelf.checkErrorTrip(from: e)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func sendBookToDriver() {
        self.listenerNotifyRemove()
        self.registerListener()
    }
    
    private func registerListener() {
        requestNameDriver()
        runCheckTimeOut()
        listenerBookingStatus()
    }
    
    private func requestNameDriver() {
        let fId = self.tripInfor.info.driverFirebaseId
        let deliveryMode = self.bookingRequestStream.currentModelBook.service?.service.serviceType == VatoServiceType.delivery
        let m = deliveryMode ? BookingRequestVC.Config.HeaderDeliverNote.contactDriver : BookingRequestVC.Config.HeaderNote.contactDriver
        let disposeAble = self.requestInformationDriver(from: fId)
            .debug("\(Config.prefixDebug) requestNameDriver")
            .subscribe { [weak self](e) in
                guard let wSelf = self else { return }
                switch e {
                    /*
                     // remove name driver in request
                     case .next(let user):
                     if let name = user.fullName?.split(" ").last, !name.isEmpty {
                     m = m + " (\(name))"
                     }
                     
                     wSelf._eStatus.onNext(m)
                     */
                case .next(_):
                    wSelf._eStatus.onNext(m)
                case .error(let e):
                    printDebug(e)
                    wSelf._eStatus.onNext(m)
                default:
                    break
                }
        }
        self.add(disposeAble)
    }
    
    private func listenerNotifyRemove() {
        let disposeAble = self.notifyRef.listener(property: "")
            .subscribe
            { [weak self](event) in
                switch event {
                case .next(let json):
                    guard json == nil || json?.keys.count == 0 else {
                        return
                    }
                    self?.checkErrorTrip(from: BookingError.clientCantBook)
                default:
                    break
                }
        }
//        let disposeAble = self.listenNotifyRemove(from: ref).take(1)
//            .debug("\(Config.prefixDebug) NotifyRemove")
//            .subscribe
//        { [weak self](event) in
//            switch event {
//            case .next:
//                self?.checkErrorTrip(from: BookingError.clientCantBook)
//            default:
//                break
//            }
//        }
        self.add(disposeAble)
    }
    
    private func runCheckTimeOut() {
        let timeOutSendDriver: TimeInterval = self.appConfig?.booking_configure?.request_booking_timeout ?? Config.timeOutSendDriver
        let disposeAble = Observable<Int>
            .interval(.seconds(Int(timeOutSendDriver)), scheduler: MainScheduler.instance)
            .debug("\(Config.prefixDebug) Check Trip Timeout")
            .subscribe(onNext: { [weak self] _ in
            self?.bookRequestTimeOut()
        })
        self.add(disposeAble)
    }
    
    private func bookRequestTimeOut() {
        cleanUpListener()
        let time = FireBaseTimeHelper.default.currentTime
        let commandCancel = FirebaseTrip.BookCommand.init(status: .clientTimeout, time: time)
        self.updateBook(by: commandCancel)
            .timeout(.seconds(15), scheduler: MainScheduler.instance)
            .debug("\(Config.prefixDebug) bookRequestTimeOut")
            .subscribe { [weak self](event) in
                guard let wSelf = self else { return }
                switch event {
                case .next:
                    // Move to next
                    wSelf.requestToDriver()
                case .error:
                    wSelf.inBookTrip = false
                    wSelf._eError.onNext(BookingError.errorRequestDriver)
                default:
                    break
                }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func listenerBookingStatus() {
        let bookRef = self.bookRef
        let disposeAble = bookRef.listener(property: "command").map { (json) -> FirebaseTrip.BookCommand? in
            guard let json = json else { return nil }
            let values = json.compactMap { $0.value as? JSON }
            let allCommands = values.compactMap { try? FirebaseTrip.BookCommand.toModel(from: $0) }.sorted(by: <)
            return allCommands.last
        }.filterNil()
        .debug("\(Config.prefixDebug) Status")
        .subscribe { [weak self](event) in
            guard let wSelf = self else {
                return
            }
            
            switch event{
            case .next(let command):
                do {
                    let next = try wSelf.checkDriverAccept(command: command)
                    // OK , Move to trip
                    if next {
                        // Ok , not need to listen
                        
                        wSelf.cleanUpListener()
                        wSelf.showDriverAccept()
                    }
                    
                } catch {
                    printDebug(error)
                    wSelf.requestToDriver()
                }
            case .error(let e):
                printDebug(e)
                // Check error ?? can move to next ?
                fatalError("Please Implement")
//                wSelf.requestToDriver()
            default:
                break
            }
        }
        self.add(disposeAble)
    }
    
    // MARK: Begin trip
    private func showDriverAccept() {
        let time = FireBaseTimeHelper.default.currentTime
        let command = FirebaseTrip.BookCommand(status: .clientAgreed, time: time)
        self.updateBook(by: command)
            .debug("\(Config.prefixDebug) client accept")
            .subscribe
        { [weak self](event) in
            guard let wSelf = self else { return }
            switch event {
            case .next:
                let driver = wSelf.currentDriver
                let firebaseId = wSelf.tripInfor.info.driverFirebaseId
                wSelf._eShowDriver.onNext((driver, firebaseId))
            case .error(let e):
                wSelf.checkErrorTrip(from: e)
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func moveToTrip() {
        let tripId = self.tripInfor.info.tripId
        self.listener?.bookChangeToInTrip(by: tripId)
    }
    
    // MARK: check driver decide
    func checkDriverAccept(command: FirebaseTrip.BookCommand) throws -> Bool {
        let status = command.status
        // Check case driver accept , other move to next
        defer {
            updateTrip(with: command)
        }
        
        // Check it exist in list
        let key = command.status.key
        if let c = tripInfor.command[key], c == command {
            return false
        }
        
        guard status == .driverAccepted else {
            throw BookingError.driverNotAccept
        }
        return true
    }
    
    private func updateTrip(with command: FirebaseTrip.BookCommand) {
        defer {
            updateTracking(by: command)
        }
        
        let key = command.status.key
        tripInfor.command[key] = command
    }
    
    // MARK: Check Error Process
    func checkErrorTrip(from error: Error) {
        cleanUpListener()
        if let e = error as? BookingError {
            switch e {
            case .noDriverCoordinate, .driverNotValid, .driverInTrip:
                requestToDriver()
            default:
                _eError.onNext(error)
            }
            
        } else {
            _eError.onNext(error)
        }
    }
    
    private func processCancelRequest() -> Observable<Bool> {
        // Check client has in booking
        // if book write cancel, else cancel
        cleanUpListener()
        guard inBookTrip else {
            return Observable.just(false)
        }
        
        let time = FireBaseTimeHelper.default.currentTime
        let commandCancel = FirebaseTrip.BookCommand.init(status: .clientCancelInBook, time: time)
        
        return self.updateBook(by: commandCancel)
            .timeout(.seconds(15), scheduler: MainScheduler.instance)
            .debug("\(Config.prefixDebug) bookingRequestCancel")
            .flatMap({ _ in return Observable.just(true) })
            .catchErrorJustReturn(true)
    }
    // MARK: Process cancel
    private func checkCancelRequest() {
        processCancelRequest().bind { [weak self] in
            guard let wSelf = self else { return }
            wSelf.listener?.requestBookCancel(revert: $0)
        }.disposeOnDeactivate(interactor: self)
    }
    
    
    func bookingRequestCancel() {
        if let request = self.bookingRequestCreateOrder {
            request.cancel(end_reason: nil, end_reason_id: nil)
        } else {
            checkCancelRequest()
        }
    }

    override func willResignActive() {
        super.willResignActive()
        cleanUpListener()
    }
    
    deinit {
        printDebug("\(#function)")
    }
}
