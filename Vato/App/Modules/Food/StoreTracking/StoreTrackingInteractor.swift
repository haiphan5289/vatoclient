//  File name   : StoreTrackingInteractor.swift
//
//  Author      : khoi tran
//  Created date: 12/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCore
import VatoNetwork
import Alamofire
import FwiCoreRX
import FirebaseFirestore

protocol StoreTrackingRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToChat()
}

protocol StoreTrackingPresentable: Presentable {
    var listener: StoreTrackingPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
    func updateUI(by type: InTripUIUpdateType)

}

protocol StoreTrackingListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func dismissStoreTracking()
    func trackingRouteToFood()
    func showReceipt(salesOrder: SalesOrder)
}

final class StoreTrackingInteractor: PresentableInteractor<StoreTrackingPresentable>, Weakifiable, RequestInteractorProtocol, ActivityTrackingProtocol, ManageListenerProtocol  {
    
    struct Configs {
        static let prefixDebug = "!!! StoreTrackingInteractor :"
    }
    /// Class's public properties.
    weak var router: StoreTrackingRouting?
    weak var listener: StoreTrackingListener?
    internal lazy var lock: NSRecursiveLock = NSRecursiveLock()
    internal lazy var listenerManager: [Disposable] = []
    private var diposeListenLocation: Disposable?
    
    var token: Observable<String> {
        return authenticated.firebaseAuthToken.take(1)
    }
    /// Class's constructor.
    init(presenter: StoreTrackingPresentable, order: SalesOrder?, authenticated: AuthenticatedStream, mutableStoreStream: MutableStoreStream?, orderId: String?, mutableChatStream: MutableChatStream, profile: ProfileStream) {
        self.item = order
        self.authenticated = authenticated
        self.mutableStoreStream = mutableStoreStream
        self.orderId = order?.id ?? orderId
        self.mutableChatStream = mutableChatStream
        self.profile = profile
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        if let order = self.item {
            mOrder.onNext(order)
        } else {
            self.getOrder()
        }
        requestStoreDetail()
        // todo: Implement business logic here.
        listenPushChange()
    }

    override func willResignActive() {
        cleanUpListener()
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private let profile: ProfileStream
    private let authenticated: AuthenticatedStream
    private let mutableStoreStream: MutableStoreStream?
    private var item: SalesOrder?
    private let mOrder = ReplaySubject<SalesOrder>.create(bufferSize: 1)
    private lazy var trackProgress: ActivityProgressIndicator = ActivityProgressIndicator()
    private var orderId: String?
    private var diposeRequest: Disposable?
    private let mutableChatStream: MutableChatStream
    private var tripId: String = ""
    @Replay(queue: MainScheduler.asyncInstance) private var mTripId: String?
    @Replay(queue: MainScheduler.asyncInstance) private var errorSubject: MerchantState
    
    @Replay(queue: MainScheduler.asyncInstance) private var mTrip: FirebaseTrip
    @VariableReplay private var trip: FirebaseTrip?
    @Replay(queue: SerialDispatchQueueScheduler(qos: .default)) var driverFirebaseId: String
    @Replay(queue: MainScheduler.asyncInstance) private var mDriver: DriverInfo
    @Replay(queue: MainScheduler.asyncInstance) private var mPolyline: String?
    @Replay(queue: MainScheduler.asyncInstance) private var mDriverCoordinate: CLLocationCoordinate2D
    @Replay(queue: MainScheduler.asyncInstance) private var mDuration: FirebaseTrip.Duration
    @Replay(queue: MainScheduler.asyncInstance) private var mUpdateUI: InTripUIUpdateType
    @Replay(queue: MainScheduler.asyncInstance) var mErrorTrip: Error
    @Replay(queue: MainScheduler.asyncInstance) var mShopDetail: FoodExploreItem?
    
    private var currentCommand: Observable<FirebaseTrip.BookCommand> {
        return $trip.map { $0?.lastCommand }.filterNil().distinctUntilChanged()
    }
    private lazy var ref: DocumentReference = Firestore.firestore().documentRef(collection: .trip, storePath: .custom(path: tripId), action: .read)
    private lazy var databaseRef = Database.database().reference()
    private var disposeRequest: Disposable?
}

// MARK: Chat
extension StoreTrackingInteractor {
    private func listenPushChange() {
        mutableStoreStream?.stateOrder.bind(onNext: weakify({ (s, wSelf) in
            wSelf.refresh()
        })).disposeOnDeactivate(interactor: self)
    }
    
    func chatMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func send(message: String) {
        let uId = profile.user.map { $0.userID }.take(1)
        let trip = $mTrip.take(1)
        Observable.zip(uId, trip, resultSelector: { uid, trip -> (Int64, FirebaseTrip) in
            return (uid, trip)
        }).bind(onNext: weakify({ (info, wSelf) in
            let clientId = info.0
            let driverId = info.1.info.driverUserId.orNil(0)
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
    
    func routeToChat() {
        router?.routeToChat()
    }
    
    private func requestStoreDetail() {
        guard let id = item?.storeId else { return }
        let host = VatoFoodApi.host
        let p = "\(host)" + "/ecom/\(id)/store"
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<FoodExploreItem>.self).bind(onNext: weakify({ (r, wSelf) in
            switch r {
            case .success(let res):
                wSelf.mShopDetail = res.data
            case .failure(let e):
                print(e.localizedDescription)
            }
        })).disposeOnDeactivate(interactor: self)
    }
}


// MARK: StoreTrackingInteractable's members
extension StoreTrackingInteractor: StoreTrackingInteractable {}

// MARK: StoreTrackingPresentableListener's members
extension StoreTrackingInteractor: StoreTrackingPresentableListener {
    var shopDetail: Observable<FoodExploreItem> {
        return $mShopDetail.filterNil()
    }
    
    var currentTrip: Observable<FirebaseTrip> {
        return $mTrip
    }
    
    var driverCooordinate: Observable<CLLocationCoordinate2D> {
        return $mDriverCoordinate.distinctUntilChanged()
    }
    
    var polyline: Observable<String> {
        return $mPolyline.filterNil().distinctUntilChanged().observeOn(MainScheduler.asyncInstance)
    }
    
    var serviceId: Observable<Int> {
        return $trip.map { $0?.info.serviceId }.filterNil().distinctUntilChanged()
    }
    
    var notifyNewChat: Observable<Int> {
        return mutableChatStream.notifyNewChat
    }
    
    var driver: Observable<DriverInfo> {
        return $mDriver
    }
    
    var errorObserable: Observable<MerchantState> {
        return $errorSubject
    }
    
    var order: Observable<SalesOrder> {
        return mOrder.asObservable()
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return trackProgress.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    private func validMoveShowReceipt(item: SalesOrder) {
        self.mutableStoreStream?.showingAlert.take(1).filter { !$0 }.bind(onNext: weakify({ (_, wSelf) in
            wSelf.listener?.showReceipt(salesOrder: item)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func showReceipt() {
        cleanUpListener()
        requestOrder().filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.validMoveShowReceipt(item: item)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func storeTrackingMoveBack() {
        if let storeStream = self.mutableStoreStream {
            storeStream.reset()
            storeStream.update(bookingState: .NEW)
        } else {
            self.listener?.dismissStoreTracking()
        }
    }
    
    func refresh() {
        self.getOrder()
    }
    
    func cancelOrder() {
        guard let id = self.orderId else { return }
        let param:JSON = ["idOrder":id]
        self.request {
            key -> Observable<(HTTPURLResponse, OptionalMessageDTO<SalesOrder>)>  in
        return Requester.requestDTO(using: VatoFoodApi.cancelOrder(authToken: key, id: id, params: param ),
                                    method: .put,
                                    encoding: JSONEncoding.default)
        }
        .trackProgressActivity(self.trackProgress)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                if res.1.fail == true {
                guard let message = res.1.message else { return }
                let errType = MerchantState.generalError(status: res.1.status,
                                                             message: message)
                    wSelf.errorSubject =  errType
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name.topupSuccess, object: nil)
                    wSelf.refresh()
                    
                }
            case .error(let e):
                wSelf.errorSubject = .errorSystem(err: e)
                print(e.localizedDescription)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func createNewOrder() {
        if let storeStream = self.mutableStoreStream {
            storeStream.reset()
            storeStream.update(bookingState: .NEW)
        } else {
            self.listener?.trackingRouteToFood()
        }
    }
}

// MARK: Class's private methods
private extension StoreTrackingInteractor {
    func requestTripId(from code: String) {
        guard tripId.isEmpty else { return }
        let host = VatoFoodApi.host
        let p = "\(host)" + "/ecom/sale-order/delivery/\(code)/trip-firebase"
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: nil, useFullPath: true)
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        diposeRequest = network.request(using: router, decodeTo: OptionalIgnoreMessageDTO<String>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let r):
                wSelf.mTripId = r.data
            case .failure(let e):
                print(e.localizedDescription)
            }
        }))
    }
    
    private func setupRX() {
        // todo: Bind data stream here.
        mOrder.bind(onNext: weakify({ (order, wSelf) in
            guard let status = order.status else { return}
            switch status {
            case StoreOrderStatus.DRIVER_ACCEPTED..<StoreOrderStatus.COMPLETE:
                guard let shipCode = order.codeShip else { return }
                wSelf.requestTripId(from: shipCode)
            default: break
            }
            guard order.completed else { return }
            wSelf.cleanUpListener()
            wSelf.presenter.updateUI(by: .showReceipt)
        })).disposeOnDeactivate(interactor: self)
        
        $mTripId.filterNil().take(1).bind(onNext: weakify({ (tripId, wSelf) in
            wSelf.tripId = tripId
            wSelf.prepareTrip()
        })).disposeOnDeactivate(interactor: self)
        
        $mErrorTrip.take(1).bind(onNext: weakify({ (e, wSelf) in
            wSelf.cleanUpListener()
            wSelf.alertFinishTrip()
        })).disposeOnDeactivate(interactor: self)
    }
    
    func alertFinishTrip() {
        self.presenter.updateUI(by: .alertTripRemove(message: "Đơn giao hàng của bạn đã kết thúc. Vui lòng kiểm tra lại."))
    }
    
    private func prepareTrip() {
        loadTrip()
        handlerInTrip()
    }
    
    private func requestOrder() -> Observable<SalesOrder?> {
        guard let id = self.orderId else { return Observable.empty() }
        return self.request { key in
            return Requester.responseDTO(decodeTo: OptionalMessageDTO<SalesOrder>.self,
                                             using: VatoFoodApi.getOrder(authToken: key, id: id, params: nil))
            }
        .trackProgressActivity(self.trackProgress)
        .observeOn(MainScheduler.asyncInstance).do(onNext: weakify({ (res, wSelf) in
            if let e = res.response.error {
                wSelf.errorSubject = .errorSystem(err: e)
            } else {
                guard res.response.data == nil else {
                    return
                }
                guard let message = res.response.message else { return }
                let errType = MerchantState.generalError(status: res.response.status,
                                                         message: message)
                wSelf.errorSubject =  errType
            }
        }), onError: weakify({ (e, wSelf) in
            wSelf.errorSubject = .errorSystem(err: e)
        })).map { $0.response.data }
        .catchErrorJustReturn(nil)
    }
    
    private func getOrder() {
        diposeRequest?.dispose()
        diposeRequest = requestOrder().filterNil().bind(onNext: weakify({ (order, wSelf) in
            wSelf.item = order
            wSelf.mOrder.onNext(order)
        }))
    }
}

// MARK: -- Find Driver Info
private extension StoreTrackingInteractor {
    func requestInformationDriver(from firebaseId: String?) -> Observable<FirebaseUser> {
        guard let firebaseId = firebaseId, !firebaseId.isEmpty else {
            return Observable.empty()
        }
        let firebaseDatabaseReference = Database.database().reference()
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        return firebaseDatabaseReference.find(by: node, type: .value, using: {
            $0.keepSynced(true)
            return $0
        }).take(1).map {
            try FirebaseUser.create(from: $0)
        }
    }
    
    func requestServiceDriver(from firebaseId: String) -> Observable<Driver> {
        let databaseRef = Database.database().reference()
        return databaseRef.findDriver(from: firebaseId).take(1)
    }
    
    static func nodeTableDriver(from firebaseId: String) -> NodeTable {
        let groupId = firebaseId.javaHash() % 10
        let key = "\(groupId)"
        let node = FireBaseTable.driverOnline >>> .custom(identify: key) >>> .custom(identify: firebaseId)
        return node
    }
    
    func generateNode() -> Observable<NodeTable> {
        return $driverFirebaseId.take(1).map(StoreTrackingInteractor.nodeTableDriver(from:))
    }
    
    func locationDriver(type: DataEventType) -> Observable<CLLocationCoordinate2D> {
        let databaseRef = Database.database().reference()
        return generateNode().flatMap { (node) -> Observable<CLLocationCoordinate2D> in
                return databaseRef.find(by: node, type: type, using: {
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

// MARK: -- Handler Trip
private extension StoreTrackingInteractor {
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
    
    private func loadPolyline(type: InTripDurationRequest) {
        switch type {
        case .started:
            $mTrip.filter { $0.extra?.polylineReceive == nil }.take(1).bind(onNext: weakify({ (_, wSelf) in
                wSelf.requestPolylineInfoTrip(type: .started)
            })).disposeOnDeactivate(interactor: self)
            
            $mTrip.filter { $0.extra?.polylineReceive != nil }
            .take(1)
            .bind(onNext: weakify({ (t, wSelf) in
                guard let p = t.extra?.polylineReceive, let d = t.estimate?.takeClientDuration else {
                    return
                }
                wSelf.mPolyline = p
                wSelf.mDuration = d
                wSelf.mUpdateUI = .showTakeClientTime(duration: d)
            }))
            .disposeOnDeactivate(interactor: self)
        case .inTrip:
            $mTrip.filter { $0.extra?.polylineIntrip == nil }.take(1).bind(onNext: weakify({ (_, wSelf) in
                wSelf.requestPolylineInfoTrip(type: .inTrip)
            })).disposeOnDeactivate(interactor: self)
            
            $mTrip.filter { $0.extra?.polylineIntrip != nil }
            .take(1)
            .bind(onNext: weakify({ (t, wSelf) in
                guard let p = t.extra?.polylineIntrip, let d = t.estimate?.inTripDuration else {
                    return
                }
                wSelf.mPolyline = p
                wSelf.mDuration = d
                wSelf.mUpdateUI = .showInTripTime(duration: d)
            }))
            .disposeOnDeactivate(interactor: self)
        }
    }
    
    func handler(command: FirebaseTrip.BookCommand) {
        diposeListenLocation?.dispose()
        switch command.status {
        case ..<TripDetailStatus.started:
            diposeListenLocation = InTripInteractor.location(tripId: tripId, inTrip: false).bind(onNext: weakify({ (coor, wSelf) in
                wSelf.mDriverCoordinate = coor
            }))
        case TripDetailStatus.started...:
            switch command.status {
            case .completed...:
                cleanUpListener()
                mUpdateUI = .showReceipt
            default:
                diposeListenLocation = InTripInteractor.location(tripId: tripId, inTrip: true).bind(onNext: weakify({ (coor, wSelf) in
                    wSelf.mDriverCoordinate = coor
                }))
            }
        default:
            break
        }
    }
    
    func trackDriverNearBy() {
        let e1 = $trip.map { $0?.info.coordinateStart }.filterNil().take(1)
        let e2 = driverCooordinate
        
        Observable.combineLatest(e1, e2).map { (c1, c2) -> Bool in
            let distance = c2.distance(other: c2)
            return abs(distance) < 100
        }.filter { $0 }.take(1).bind(onNext: weakify({ (_, wself) in
            wself.mUpdateUI = .vibrateDriverNearby
        })).disposeOnDeactivate(interactor: self)
    }
    
    func handlerInTrip() {
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
        
        loadPolyline(type: .inTrip)
        
        trackDriverNearBy()
    }
}

// MARK: -- Load Trip
private extension StoreTrackingInteractor {
    func trip(by action: DocumentFirestoreAction,
              source: FirestoreSource = .default) -> Observable<DocumentSnapshot?>
    {
        return ref.find(action: action, source: source)
    }
    
    func loadTrip() {
        trip(by: .get, source: .server)
            .filterNil()
            .map { try FirebaseTrip.create(from: $0) }.subscribe(weakify({ (event, wSelf) in
                switch event {
                case .next(let trip):
                    wSelf.trip = trip
                    wSelf.listenTrip()
                    wSelf.loadChat()
                case .error(let e):
                    wSelf.mErrorTrip = e
                default:
                    break
                }
            })).disposeOnDeactivate(interactor: self)
    }
    
    func listenTrip() {
        let dispose = trip(by: .listen).map({ (snapshot) -> FirebaseTrip in
            guard let snapshot = snapshot else {
                let e = NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: [NSLocalizedDescriptionKey: "Not exist"])
                throw e
            }
            let result = try FirebaseTrip.create(from: snapshot)
            return result
        }).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let new):
                wSelf.trip = new
            case .error(let e):
                #if DEBUG
                   print(e.localizedDescription)
                #endif
    
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
                #if DEBUG
                   print(error.localizedDescription)
                #endif
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
