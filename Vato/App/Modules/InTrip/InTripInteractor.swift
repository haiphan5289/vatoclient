//  File name   : InTripInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FirebaseFirestore
import VatoNetwork

protocol InTripRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToChat()
    func routeToCancel()
    func routeToShortcut()
    func routeToLocationPicker()
    func routeToAddDestinationConfirm(type: AddNewDestinationType, tripId: String)
    
}

protocol InTripPresentable: Presentable {
    var listener: InTripPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func updateUI(by type: InTripUIUpdateType)
    func drawPolyline(p: String)
}

protocol InTripListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func inTripMoveBack()
    func inTripCancel()
    func inTripNewBook()
    func inTripComplete()
}

final class InTripInteractor: PresentableInteractor<InTripPresentable>, ManageListenerProtocol {
    struct Configs {
        static let prefixDebug = "!!! InTripInteractor :"
    }
    
    /// Class's public properties.
    weak var router: InTripRouting?
    weak var listener: InTripListener?
    let tripId: String
    private let ref: DocumentReference
    internal lazy var lock: NSRecursiveLock = NSRecursiveLock()
    internal lazy var listenerManager: [Disposable] = []
    
    /// Class's constructor.
    init(presenter: InTripPresentable, tripId: String, mutableChatStream: MutableChatStream) {
        self.mutableChatStream = mutableChatStream
        self.tripId = tripId
        self.ref = Firestore.firestore().documentRef(collection: .trip, storePath: .custom(path: tripId), action: .read)
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        DispatchQueue.needCheckLatePayment = true
        super.didBecomeActive()
        setupRX()
        loadTrip()
        loadChat()
        listenTrip()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        cleanUpListener()
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    @VariableReplay private var trip: FirebaseTrip?
    
    @Replay(queue: MainScheduler.asyncInstance) private var mPolyline: String?
    @Replay(queue: MainScheduler.asyncInstance) var mDriver: DriverInfo
    @Replay(queue: SerialDispatchQueueScheduler(qos: .default)) var driverFirebaseId: String
    @Replay(queue: MainScheduler.asyncInstance) var mDriverCoordinate: CLLocationCoordinate2D
    @Replay(queue: MainScheduler.asyncInstance) var mDuration: FirebaseTrip.Duration
    @Replay(queue: MainScheduler.asyncInstance) var mStatus: String
    @Replay(queue: MainScheduler.asyncInstance) var mUpdateUI: InTripUIUpdateType
    @Replay(queue: MainScheduler.asyncInstance) var mErrorTrip: Error
    @Replay(queue: MainScheduler.asyncInstance) var mTrip: FirebaseTrip
    @Replay(queue: MainScheduler.asyncInstance) private var currentType: TOShortCutType
    @Replay(queue: MainScheduler.asyncInstance) private var mWayPoints: [TripWayPoint]?
    @Replay(queue: MainScheduler.asyncInstance) private var mFormatText: String?
    private var mServiceId: Int = -1
    private let mutableChatStream: MutableChatStream
    private lazy var databaseRef = Database.database().reference()
    private var currentCommand: Observable<FirebaseTrip.BookCommand> {
        return $trip.map { $0?.lastCommand }.filterNil().distinctUntilChanged()
    }
    private var disposeListenDuration: Disposable?
    internal var disposeRequest: Disposable?
    private var diposeListenLocation: Disposable?
}

// MARK: Load current trip
private extension InTripInteractor {
    func trip(by action: DocumentFirestoreAction,
              source: FirestoreSource = .default) -> Observable<DocumentSnapshot?>
    {
        return ref.find(action: action, source: source)
    }
    
    func loadTrip() {
        trip(by: .get, source: .server)
            .filterNil()
            .map { try FirebaseTrip.create(from: $0) }.debug("\(Configs.prefixDebug)\(#function)")
            .bind(to: $trip)
            .disposeOnDeactivate(interactor: self)
    }
    
    func listenTrip() {
        let dispose = trip(by: .listen).skip(1).map({ (snapshot) -> FirebaseTrip in
            guard let snapshot = snapshot else {
                let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: [NSLocalizedDescriptionKey: "Not exist"])
                throw e
            }
            let result = try FirebaseTrip.create(from: snapshot)
            return result
        }).debug("\(Configs.prefixDebug)\(#function)").subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let new):
                wSelf.trip = new
            case .error(let e):
                wSelf.mErrorTrip = e
            default:
                break
            }
        }))
        add(dispose)
    }
    
    func listenNewChat(node: NodeTable) {
        // Listen new
        let dispose = databaseRef.find(by: node, type: .childAdded, using: {
            $0.keepSynced(true)
            return $0
        }).bind(onNext: weakify({ (snapshot, wSelf) in
            do {
                let new = try ChatMessage.create(from: snapshot)
                wSelf.mutableChatStream.update(newMessage: new)
            } catch {
                print(error.localizedDescription)
            }
        }))
        add(dispose)
    }
    
    func loadChat() {
        // List
        let node = FireBaseTable.chats >>> .custom(identify: tripId)
        databaseRef.find(by: node, type: .value, using: {
            $0.keepSynced(true)
            return $0
        })
        .take(1)
        .map { snapshot -> [ChatMessageProtocol] in
            let childrens = snapshot.children.compactMap({ $0 as? DataSnapshot })
            let chats = try childrens.map({ try ChatMessage.create(from: $0) }).sorted(by: >)
            return chats
        }.bind(onNext: weakify({ (chats, wSelf) in
            wSelf.mutableChatStream.update(listChat: chats)
            wSelf.listenNewChat(node: node)
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Find InFo Driver
private extension InTripInteractor {
    func requestInformationDriver(from firebaseId: String?) -> Observable<FirebaseUser> {
        guard let firebaseId = firebaseId, !firebaseId.isEmpty else {
            return Observable.empty()
        }
        let firebaseDatabaseReference = databaseRef
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        return firebaseDatabaseReference.find(by: node, type: .value, using: {
            $0.keepSynced(true)
            return $0
        }).take(1).map {
            try FirebaseUser.create(from: $0)
        }
    }
    
    func requestServiceDriver(from firebaseId: String) -> Observable<Driver> {
       return databaseRef.findDriver(from: firebaseId).take(1)
    }
    
    static func nodeTableDriver(from firebaseId: String) -> NodeTable {
        let groupId = firebaseId.javaHash() % 10
        let key = "\(groupId)"
        let node = FireBaseTable.driverOnline >>> .custom(identify: key) >>> .custom(identify: firebaseId)
        return node
    }
    
    func generateNode() -> Observable<NodeTable> {
        return $driverFirebaseId.take(1).map(InTripInteractor.nodeTableDriver(from:))
    }
    
    func locationDriver(type: DataEventType) -> Observable<CLLocationCoordinate2D> {
        return generateNode().flatMap { [weak self](node) -> Observable<CLLocationCoordinate2D> in
                guard let wSelf = self else { return Observable.empty() }
                return wSelf.databaseRef.find(by: node, type: type, using: {
                    $0.keepSynced(true)
                return $0
            }).map{ snapshot -> CLLocationCoordinate2D? in
                switch type {
                case .value:
                    return (try? DriverOnlineStatus.create(from: snapshot))?.location?.location.coordinate
                case .childChanged:
                    guard snapshot.key == "location" else {
                        return nil
                    }
                    return (try? Coordinate.create(from: snapshot))?.location.coordinate
                default:
                    return nil
                }
                
            }.filterNil()
        }
    }
}

// MARK: InTripInteractable's members
extension InTripInteractor: InTripInteractable, Weakifiable {
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?, removeCurrent: Bool) {}
    
    static func location(tripId: String, inTrip: Bool) -> Observable<CLLocationCoordinate2D> {
        let p = inTrip ? "IntripDriverLocations" : "ReceiveDriverLocations"
        let tripRef = Firestore.firestore().documentRef(collection: .trip, storePath: .custom(path: tripId), action: .read)
        return Observable.create { (s) -> Disposable in
            let id = tripRef.collection(p).order(by: "timestamp").addSnapshotListener { (snapshot, e) in
                #if DEBUG
                    assert(e == nil, e?.localizedDescription ?? "")
                #endif
                guard let item = snapshot?.documentChanges.last?.document else {
                    return
                }
                
                do {
                    let c = try Coordinate.create(from: item)
                    s.onNext(c.location.coordinate)
                } catch {
                    #if DEBUG
                    print("\(#function): \(error.localizedDescription)")
                    #endif
                }
            }
            
            return Disposables.create {
                id.remove()
            }
        }.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
    }
    
    func updateStatus(_ status: TripDetailStatus) throws {
        let round = UInt64(FireBaseTimeHelper.default.currentTime)
        let command = FirebaseTrip.BookCommand(status: status, time: TimeInterval(round))
        let jsonCommand = [status.key : try command.toJSON()]
        
        let tracking = FirebaseTrip.Tracking()
        tracking.command = status
        tracking.clientLocalTime = Date().string(from: "yyyyMMdd HH:mm:ss")
        let c = VatoLocationManager.shared.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        tracking.clientLocation = Coordinate(from: c.latitude, lng: c.longitude)
        tracking.clientTimestamp = TimeInterval(round)
        let jsonTracking = ["\(status.rawValue)" : try tracking.toJSON()]
        let result: JSON = ["command": jsonCommand,
                            "last_command": status.key,
                            "tracking": jsonTracking]
        
        ref.update(json: result) { (e) in
            guard let e = e else { return }
            assert(false, e.localizedDescription)
        }
    }
    
    func inTripNewBook() {
        listener?.inTripNewBook()
    }
    
    func inTripCancel() {
        listener?.inTripCancel()
    }
    
    func inTripCancel(_ reason: JSON) {
        $mTrip.take(1).bind(onNext: weakify({ (trip, wSelf) in
            wSelf.cleanUpListener()
            let trip = trip
            trip.info.end_reason_id = reason.value("end_reason_id", defaultValue: 0)
            trip.info.end_reason_value = reason.value("end_reason_value", defaultValue: nil)
            do {
                let json = try trip.info.toJSON()
                wSelf.ref.update(path: "info", json: json) { (e) in
                    guard let e = e else { return }
                    assert(false, e.localizedDescription)
                }
                try wSelf.updateStatus(.clientCancelIntrip)
                wSelf.listener?.inTripCancel()
            } catch {
                assert(false, error.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func chatMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func send(message: String) {
        $mTrip.take(1).bind(onNext: weakify({ (trip, wSelf) in
            let clientId = trip.info.clientUserId.orNil(0)
            let driverId = trip.info.driverUserId.orNil(0)
            let time = FireBaseTimeHelper.default.offset + Date().timeIntervalSince1970 * 1000
            let chatMessage = ChatMessage(message: message, sender: "c~\(clientId)", receiver: "d~\(driverId)", id: Int64(time), time: time)
            do {
                defer {
                    wSelf.mutableChatStream.update(newMessage: chatMessage)
                }
                let node = FireBaseTable.chats >>> .custom(identify: wSelf.tripId)
                let ref = Database.database().reference(withPath: node.path).childByAutoId()
                let json = try chatMessage.toJSON()
                ref.setValue(json: json) { (e) in
                    guard let e = e else { return }
                    assert(false, e.localizedDescription)
                }
            } catch {
                assert(false, error.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: InTripPresentableListener's members
extension InTripInteractor: InTripPresentableListener {
    func routeToCancelTrip() {
        router?.routeToCancel()
    }
    
    func inTripMoveBack() {
        listener?.inTripMoveBack()
    }
    
    var formatText: Observable<String> {
        return $mFormatText.filterNil()
    }
    
    var currentTrip: Observable<FirebaseTrip> {
        return $trip.filterNil()
    }
    
    var allAddress: Observable<[String]> {
        return $trip.filterNil().map { t -> [String] in
            var result = [String]()
            result.addOptional(t.info.startName)
            t.info.wayPoints?.forEach({ (p) in
                result.addOptional(p.address)
            })
            result.addOptional(t.info.endAddress)
            
            return result
        }
    }
    
    var driverCooordinate: Observable<CLLocationCoordinate2D> {
        return $mDriverCoordinate.distinctUntilChanged()
    }
    
    var polyline: Observable<String> {
        return $mPolyline.filterNil().distinctUntilChanged().observeOn(MainScheduler.asyncInstance)
    }
    
    var estimate: Observable<FirebaseTrip.Duration> {
        return $mDuration.distinctUntilChanged()
    }
    
    var driver: Observable<DriverInfo> {
        return $mDriver
    }
    
    var serviceId: Observable<Int> {
        return $mTrip.map { $0.info.serviceId }.distinctUntilChanged()
    }
    
    var notifyNewChat: Observable<Int> {
        return mutableChatStream.notifyNewChat
    }
    
    var payment: Observable<InTripPayment> {
        return $mTrip.map { InTripPayment(payment: $0.info.payment, price: $0.info.price, farePrice: $0.info.farePrice, finalPrice: $0.info.fPrice) }.distinctUntilChanged()
    }
    
    var status: Observable<String> {
        return $mStatus.distinctUntilChanged()
    }
    
    var wayPoints: Observable<[TripWayPoint]> {
        return $mTrip
            .map { $0.info.wayPoints }
            .filterNil()
            .observeOn(MainScheduler.asyncInstance)
            .distinctUntilChanged()
    }
    
    var note: String? {
        let trip = self.trip
        return trip?.info.note
    }
    
    func inTripCompleted() {
        defer {
            BookingRequestCreateOrder.clearCurrentOrder()
        }
        let database = Database.database().reference()
        database.removeClientCurrentTrip(clientFirebaseId: Auth.auth().currentUser?.uid)
        listener?.inTripComplete()
    }
    
    func routeToChat() {
        router?.routeToChat()
    }
}



// MARK: Class's private methods
extension InTripInteractor: InTripRequestInfoProtocol {}

private extension InTripInteractor {
    private func requestPolylineInfoTrip(type: InTripDurationRequest) {
        switch type {
        case .started:
            let coordinateDriver = driverCooordinate.take(1)
            let startCoordinate = $mTrip.map { $0.info.coordinateStart }.take(1)
            disposeRequest = InTripInteractor.requestInfo(start: coordinateDriver, end: startCoordinate).bind(onNext: weakify({ (result, wSelf) in
                switch result {
                case .failure(let e):
                    print(e.localizedDescription)
                case .success(let res):
                    let r = res.data
                    let p = r.overviewPolyline
                    let distance = r.distance
                    let duration = r.duration
                    
                    let extra = ["polylineReceive": p]
                    let estimate = ["receiveDistance": distance,
                                    "receiveDuration": duration]
                    let json: JSON = ["extra": extra, "estimate": estimate]
                    wSelf.ref.update(json: json) { (e) in
                        assert(e == nil, e?.localizedDescription ?? "")
                    }
                }
            }))
        case .inTrip:
            let s = $mTrip.map { $0.info.coordinateStart }.take(1)
            let e = $mTrip.map { $0.info.coordinateEnd }.take(1)
            disposeRequest = InTripInteractor.requestInfo(start: s, end: e).bind(onNext: weakify({ (result, wSelf) in
                switch result {
                case .failure(let e):
                    print(e.localizedDescription)
                case .success(let res):
                    let r = res.data
                    let p = r.overviewPolyline
                    let distance = r.distance
                    let duration = r.duration
                    
                    let extra = ["polylineIntrip": p]
                    let estimate = ["intripDistance": distance,
                                    "intripDuration": duration]
                    let json: JSON = ["extra": extra, "estimate": estimate]
                    wSelf.ref.update(json: json) { (e) in
                        assert(e == nil, e?.localizedDescription ?? "")
                    }
                }
            }))
        }
    }
    
    private func updateInTrip() {
        disposeRequest?.dispose()
        diposeListenLocation?.dispose()
        $mTrip.filter { $0.extra?.polylineIntrip == nil }.take(1).bind(onNext: weakify({ (_, wSelf) in
            wSelf.requestPolylineInfoTrip(type: .inTrip)
        })).disposeOnDeactivate(interactor: self)
        
        $mTrip.filter { $0.extra?.polylineIntrip != nil }.take(1).bind(onNext: weakify({ (t, wSelf) in
            guard let p = t.extra?.polylineIntrip else { return }
            wSelf.mPolyline = p
            wSelf.presenter.drawPolyline(p: p)
        })).disposeOnDeactivate(interactor: self)
        
        $mTrip
        .bind(onNext: weakify({ (t, wSelf) in
            wSelf.mFormatText = nil
            let sid = t.info.serviceId
            let d = t.estimate?.inTripDuration ?? FirebaseTrip.Duration(distance: 0, duration: 0)
            wSelf.mStatus = sid >= VatoServiceDelivery.rawValue ? Text.inTripDelivery.localizedText : Text.inTripOnWay.localizedText
            wSelf.mUpdateUI = .showInTripTime(duration: d)
            wSelf.mDuration = d
            
        }))
        .disposeOnDeactivate(interactor: self)
        
        diposeListenLocation = InTripInteractor.location(tripId: tripId, inTrip: true).bind(onNext: weakify({ (coor, wSelf) in
            wSelf.mDriverCoordinate = coor
        }))
    }
    
    func handler(command: FirebaseTrip.BookCommand) {
        switch command.status {
        case ..<TripDetailStatus.started:
            disposeRequest?.dispose()
            diposeListenLocation?.dispose()
            $mTrip.filter { $0.extra?.polylineReceive != nil }.take(1).bind(onNext: weakify({ (t, wSelf) in
                guard let p = t.extra?.polylineReceive else { return }
                wSelf.mPolyline = p
            })).disposeOnDeactivate(interactor: self)
            
            $mTrip.filter { $0.extra?.polylineReceive == nil }.take(1).bind(onNext: weakify({ (_, wSelf) in
                wSelf.requestPolylineInfoTrip(type: .started)
            })).disposeOnDeactivate(interactor: self)
            
            disposeListenDuration = $mTrip.filter { $0.estimate?.takeClientDuration != nil }
            .bind(onNext: weakify({ (t, wSelf) in
                let d = t.estimate?.takeClientDuration ?? FirebaseTrip.Duration(distance: 1, duration: 1)
                let f = wSelf.mServiceId >= VatoServiceType.delivery.rawValue ? Text.inTripDeliveryArrive.localizedText : Text.inTripArrive.localizedText
                wSelf.mStatus = String(format: f, Int(d.duration / 60))
                wSelf.mFormatText = f
                wSelf.mUpdateUI = .showTakeClientTime(duration: d)
                wSelf.mDuration = d
            }))
            
            diposeListenLocation = InTripInteractor.location(tripId: tripId, inTrip: false).bind(onNext: weakify({ (coor, wSelf) in
                wSelf.mDriverCoordinate = coor
            }))
            
        case TripDetailStatus.started...:
            disposeListenDuration?.dispose()
            switch command.status {
            case .completed, .deliveryFail:
                cleanUpListener()
                showReceipt(type: .showReceipt, message: nil)
                //Đang trên đường giao hàng
            case .receivePackageSuccess:
                updateInTrip()
            case .started:
                presenter.updateUI(by: .showAddNewDestination)
                updateInTrip()
            case .driverCancelInBook, .driverCancelIntrip, .adminCancel:
                cleanUpListener()
                diposeListenLocation?.dispose()
                $mTrip.take(1).bind { [weak self] (t) in
                    let message: String
                    let sid = t.info.serviceId
                    message = t.info.end_reason_value ?? {
                        return sid >= VatoServiceDelivery.rawValue ? Text.inTripDeliveryRemove.localizedText : Text.inTripCancel.localizedText
                    }()
                    self?.showReceipt(type: nil, message: message)
                }.disposeOnDeactivate(interactor: self)
            default:
                break
            }
        default:
            break
        }
    }
    
    private func showReceipt(type: InTripUIUpdateType?, message: String?) {
        let action = { [weak self] in
            guard let wSelf = self else { return }
            if let type = type {
                wSelf.mUpdateUI = type
               return
            }
            
            if let message = message {
                wSelf.presenter.updateUI(by: .showAlertBeginNewTrip(message: message))
            }
            
        }
        if router?.children.isEmpty == true {
            action()
        } else {
            router?.dismissCurrentRoute(completion: action)
        }
        
    }
    
    func trackDriverNearBy() {
        let e1 = $trip.map { $0?.info.coordinateStart }.filterNil().take(1)
        let e2 = driverCooordinate
        
        Observable.combineLatest(e1, e2).map { (c1, c2) -> Bool in
            let distance = c2.distance(other: c2)
            return distance < 100
        }.filter { $0 }.take(1).bind(onNext: weakify({ (_, wself) in
            guard let c = wself.trip?.lastCommand, c.status < .started else { return }
            wself.mUpdateUI = .vibrateDriverNearby
        })).disposeOnDeactivate(interactor: self)
    }
    
    func writeTripToClientTrip() {
        let database = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        assert(uid != nil, "Please check")
        database.writeClientCurrentTrip(clientFirebaseId: uid, tripId: tripId)
    }
    
    private func setupRX() {
        // todo: Bind data stream here.
        serviceId.take(1).bind(onNext: weakify({ (id, wSelf) in
            wSelf.mServiceId = id
            wSelf.writeTripToClientTrip()
        })).disposeOnDeactivate(interactor: self)
        
        let dispose = currentCommand.bind(onNext: weakify({ (command, wSelf) in
            wSelf.handler(command: command)
        }))
        add(dispose)
        
        $trip.map { $0?.info.driverFirebaseId }.filterNil().take(1).bind(onNext: weakify({ (fbId, wSelf) in
            wSelf.driverFirebaseId = fbId
        })).disposeOnDeactivate(interactor: self)
        
        $trip.filterNil().bind(onNext: weakify({ (trip, wSelf) in
            wSelf.mTrip = trip
        })).disposeOnDeactivate(interactor: self)
        
        $driverFirebaseId.take(1).flatMap { [weak self] fbId -> Observable<DriverInfo> in
            guard let wSelf = self else { return Observable.empty() }
            let e1 = wSelf.requestInformationDriver(from: fbId)
            let e2 = wSelf.requestServiceDriver(from: fbId)
            return Observable.zip(e1, e2).map { DriverInfo(personal: $0, customer: $1) }
        }.bind(onNext: weakify({ (user, wSelf) in
            wSelf.mDriver = user
        })).disposeOnDeactivate(interactor: self)
        
        let lastLocation = locationDriver(type: .value).take(1)
        let realTimeLocation = locationDriver(type: .childChanged)
        
        let disposeLocation = Observable.merge([lastLocation, realTimeLocation])
            .debug("\(Configs.prefixDebug) location:")
            .bind(onNext: weakify({ (coord, wSelf) in
            wSelf.mDriverCoordinate = coord
        }))
        add(disposeLocation)
        
        $mDriver.bind(onNext: weakify({ (info, wSelf) in
            wSelf.mutableChatStream.update(driver: info.personal)
        })).disposeOnDeactivate(interactor: self)
        
        $mUpdateUI.distinctUntilChanged().bind(onNext: weakify({ (update, wSelf) in
            wSelf.presenter.updateUI(by: update)
        })).disposeOnDeactivate(interactor: self)
        
        $mErrorTrip.take(1).bind(onNext: weakify({ (e, wSelf) in
            wSelf.cleanUpListener()
            wSelf.alertFinishTrip()
        })).disposeOnDeactivate(interactor: self)
        
        trackDriverNearBy()
    }
    
    func alertFinishTrip() {
        $trip.map { $0?.info.serviceId }.take(1).bind { [weak self] (id) in
            let message: String
            if let sid = id {
                message = sid >= VatoServiceDelivery.rawValue ? Text.inTripDeliveryRemove.localizedText : Text.inTripRemove.localizedText
            } else {
                message = Text.inTripRemove.localizedText
            }
            self?.presenter.updateUI(by: .alertTripRemove(message: message))
        }.disposeOnDeactivate(interactor: self)
    }
}

// MARK: -- PickLocation
extension InTripInteractor: LocationRequestProtocol {
    func pickerDismiss(currentAddress: AddressProtocol?) {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func didSelectModel(model: AddressProtocol) {
        updateAddress(model: model, update: weakify({ (new, wSelf) in
            var endAddress = AddDestinationInfo(coordinate: new.coordinate, name: new.name, subLocality: new.subLocality)
            endAddress.placeId = new.placeId
            wSelf.router?.routeToAddDestinationConfirm(type: .new(destination: endAddress), tripId: wSelf.tripId)
        }))
    }
}

// MARK: -- Shortcut
extension InTripInteractor {
    func routeToShortcut() {
        self.router?.routeToShortcut()
    }
    
    func routeToShortcutItem(item: TOShortutModel) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            defer {
                wSelf.currentType = item.type
            }
            switch item.type {
            case .addNewDestination:
                wSelf.router?.routeToLocationPicker()
            default:
                fatalError("Please Implement")
            }
        }))
    }
    
    func shortcutDismiss() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func shortcutRouteToFood() {
        
    }
}

// MARK: -- AddDestination
extension InTripInteractor {
    func dismissAddDestination() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func addDestinationSuccess(points: [DestinationPoint], newPrice: AddDestinationNewPrice) {}
    func routeToAddDestinationConfirm() {}
    func presentAddDestinationConfirm() {}
}
