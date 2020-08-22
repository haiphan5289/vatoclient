//  File name   : VatoMainInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 8/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Firebase
import Alamofire
import VatoNetwork
import FwiCoreRX
import FwiCore
import CoreLocation
import FirebaseInstanceID
import Kingfisher

protocol VatoMainRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToTopup(use config: [TopupLinkConfigureProtocol], paymentStream: MutablePaymentStream?)
    func beginLastTrip(info: [String: Any], history: Bool)
    func routeToInTrip(by tripId: String)
    func routeToScanQR()
    func showRatingView(book: FCBooking)
    func presentLatePayment(with debtInfo: UserDebtDTO)
    func routeToSetLocation()
}

protocol VatoMainPresentable: Presentable, HandlerProtocol {
    var listener: VatoMainPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol VatoMainListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    var ready: Observable<Bool> { get }
    func reloadBalance()
    func moveToBook(data: VatoMainData)
    func routeToPromotionDetail(manifest: PromotionList.Manifest)
    func promotionDetail(predicate: PromotionList.ManifestPredicate, manifest: PromotionList.Manifest)
    func routeToListPromotion()
    func showListWalletHistory()
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?)
    func showTopUp()
    func routeToProfile()
    func routeToWallet()
    func routeToEcomTracking(saleOderId: String)
    func routeToShortcut()
    func routeToHistory(type: HistoryItemType?)
    func routeToShopping()
    func routeToTicket(action: TicketDestinationAction?)
}

final class VatoMainInteractor: PresentableInteractor<VatoMainPresentable> {
    /// Class's public properties.
    weak var router: VatoMainRouting?
    weak var listener: VatoMainListener?
    var previousPush: [String: Any]?
    private var checkedPromotion: Bool = false
    
    /// Class's constructor.
    init(presenter: VatoMainPresentable,
         profileStream: ProfileStream,
         authenticated: AuthenticatedStream,
         firebaseDatabase: DatabaseReference,
         mutablePromotionNows: MutablePromotionNowStream,
         paymentStream: MutablePaymentStream,
         mutableBookingStream: MutableBookingStream)
    {
        self.mutableBookingStream = mutableBookingStream
        self.profileStream = profileStream
        self.authenticated = authenticated
        self.firebaseDatabase = firebaseDatabase
        self.mutablePromotionNows = mutablePromotionNows
        self.paymentStream = paymentStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        self.listener?.ready.take(1).filter { $0 }.bind(onNext: { [weak self](_) in
            self?.prepareData()
        }).disposeOnDeactivate(interactor: self)
        
        ShortcutItemManager.instance.shortcutItem.bind {[weak self] (type) in
            guard let wSelf = self else { return }
            switch type {
            case .barcode:
                wSelf.routeToScanQR()
            
            default:
                break
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func cleanupMemory(_ notification: Notification) {
        UIImageView.cacheOriginal.clearMemoryCache()
        ImageCache.default.clearMemoryCache()
    }
        
    private func prepareData() {
        VatoLocationManager.shared.loadLenghtGeohash()
        checkMigration()
        checkLastTrip()
        loadTopupConfig()
        updateVersion()
        listenPushPromotion()
        listenPushEcom()
        listenDeepLink()
        setupRX()
        checkPromotion()
        loadNapas()
        refreshHomeLanding()
    }
        
    private func getConfig() -> Observable<[TopupLinkConfigureProtocol]> {
        let router = authenticated.firebaseAuthToken.take(1)
            .timeout(.seconds(300), scheduler: MainScheduler.asyncInstance)
            .map({ VatoAPIRouter.userTopupConfig(authToken: $0) })
        
        let request = router.flatMap ({ r -> Observable<(HTTPURLResponse, OptionalMessageDTO<[TopupConfigResponse]>)> in
            Requester.requestDTO(using: r)
        }).map { r -> [TopupLinkConfigureProtocol] in
            r.1.data ?? []
        }.catchErrorJustReturn([])
        return request
    }
    
    private func loadTopupConfig() {
        getConfig().bind { [weak self] in
            self?.eTopupConfig.onNext($0)
        }.disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    let profileStream: ProfileStream
    let authenticated: AuthenticatedStream
    internal let firebaseDatabase: DatabaseReference
    private let mutablePromotionNows: MutablePromotionNowStream
    private lazy var eTopupConfig = ReplaySubject<[TopupLinkConfigureProtocol]>.create(bufferSize: 1)
    private var tripDisposable: Disposable?
    private var currentTripId: String?
    var currenttripAPIDisposable: Disposable?
    private let paymentStream: MutablePaymentStream
    private var action: VatoServiceAction?
    private let mutableBookingStream: MutableBookingStream
    private (set) lazy var network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
    internal var paging: PagingHome = .default
    internal var currentRequestPage: Int = -1
    @Replay(queue: MainScheduler.asyncInstance) private var mGroupServiceOnGoing: [VatoHomeGroupEventGoing]
    @VariableReplay var currentLocation: AddressProtocol?
    internal var diposeLoadLandingPage: Disposable?
    @Replay(queue: MainScheduler.asyncInstance) var mListSections: ListUpdate<VatoHomeLandingItemSection>?
    @Replay(queue: MainScheduler.asyncInstance) var mListBanner: [VatoHomeLandingItem]
    @VariableReplay var mLoadingRequest: Bool = false
    @CacheFile(fileName: "file_cache_section_home") var mCachedItems: [VatoHomeLandingItemSection]
}

// MARK: VatoMainInteractable's members
extension VatoMainInteractor: VatoMainInteractable, Weakifiable, LocationRequestProtocol {
    
    
    func inTripComplete() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func inTripNewBook() {
        router?.dismissCurrentRoute(completion: { [weak self] in
            self?.newTrip()
        })
    }
    
    func inTripCancel() {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.firebaseDatabase.removeClientCurrentTrip(clientFirebaseId: UserManager.instance.info?.firebaseID)
        }))
    }
    
    func inTripMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func handler(action: VatoServiceAction) {
        if let categotyType = action.categoryService {
            checkLocation().bind(onNext: weakify({ (wSelf) in
                wSelf.routeToServiceCategory(type: categotyType, action: nil)
            })).disposeOnDeactivate(interactor: self)
            return
        }
        
        guard let s = action.serice else {
            return
        }
        self.routeToBooking(data: .service(s: s))
    }
    
    private func requestAuthorizeLocation() -> Observable<Void> {
        VatoLocationManager.shared.requestAlwaysAuthorization()
        return VatoLocationManager.shared.rx.didChangeAuthorizationStatus.take(1).flatMap { [weak self](_) -> Observable<Void> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.checkLocation()
        }
    }
    
    func checkLocation() -> Observable<Void> {
        #if targetEnvironment(simulator)
          self.router?.routeToSetLocation()
          return self.$currentLocation.skip(1).take(1).map { _ in }
        #else
          // your real device code
          guard CLLocationManager.locationServicesEnabled() else {
            self.router?.routeToSetLocation()
            return self.$currentLocation.skip(1).take(1).map { _ in }
          }
        
          let status = CLLocationManager.authorizationStatus()
          switch status {
          case .authorizedAlways, .authorizedWhenInUse:
              return Observable.just(())
          case .denied, .restricted:
              // Track
              self.router?.routeToSetLocation()
              return self.$currentLocation.skip(1).take(1).map { _ in }
          default:
              return requestAuthorizeLocation()
          }
        #endif
    }
    
    func setLocationMoveBack(_ address: AddressProtocol?) {
        self.router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            guard let address = address else {
                return
            }
            wSelf.update(model: address)
        }))
    }
    
    private func update(model: AddressProtocol) {
        updateAddress(model: model, update: weakify({ (new, wSelf) in
            wSelf.mutableBookingStream.updateBooking(originAddress: new)
            MapInteractor.Config.defaultMarker = MarkerHistory.init(with: new)
            wSelf.currentLocation = new
        }))
    }
        
    func routeToShortcut() {
        self.listener?.routeToShortcut()
    }
    
    func requestToDismissLatePaymentModule() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func scanQRMoveBack() {
       router?.dismissCurrentRoute(completion: nil)
    }
    
    func resultScanShowPromotions() {
        router?.dismissCurrentRoute(completion: { [weak self] in
            guard let self = self else { return }
            self.routeToListPromotion()
        })
    }
    
    func newTrip() {
        checkLocation().bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.moveToBook(data: .service(s: .car))
        })).disposeOnDeactivate(interactor: self)
    }
    
    func loadTrip(by tripId: String, history: Bool = false) {
        tripDisposable?.dispose()
        currentTripId = tripId
        router?.routeToInTrip(by: tripId)
    }
    
    private func beginLastTrip(info: [String: Any], history: Bool = true) {
        router?.beginLastTrip(info: info, history: history)
    }
    
    func reloadBalance() {
        self.listener?.reloadBalance()
    }
    
    private func findZone(from coordinate: CLLocationCoordinate2D) -> Observable<Zone> {
        return firebaseDatabase.findZone(with: coordinate).take(1)
    }
    
    private func updateVersion() {
        let o1 = authenticated.firebaseAuthToken.take(1)
        let o2 = profileStream.client.take(1)
        let o3 = profileStream.user.take(1)
        
        let o4 = Observable<String>.create { (o) -> Disposable in
            InstanceID.instanceID().instanceID { (result, err) in
                let token = result?.token ?? ""
                o.onNext(token)
            }
            return Disposables.create()
        }
        
        Observable<(String, Client, UserInfo, String)>.combineLatest(o1, o2, o3, o4) { (token, client, user, deviceToken) -> (String, Client, UserInfo, String) in
            return (token, client, user, deviceToken)
            }.flatMap { data -> Observable<(HTTPURLResponse, Data)> in
                /* Condition validation: check app's version */
                guard
                    let info = Bundle.main.infoDictionary,
                    let version = info["CFBundleShortVersionString"] as? String
                    else {
                        return Observable.empty()
                }
                
                let appVersion = "\(version)I"
                return Requester.request(using: VatoAPIRouter.updateDeviceToken(authToken: data.0, firebaseID: data.2.firebaseId, phoneNumber: data.2.phone, deviceToken: data.3, appVersion: appVersion),
                                         method: .post, encoding: JSONEncoding.default)
            }
            .subscribe(
                onNext: { [weak self] (response) in
                    if response.0.statusCode == 200 {
                        printDebug("Success update APNS token.")
                        let user = Auth.auth().currentUser
                        guard let usr = user else {
                            return
                        }
                        
                        InstanceID.instanceID().instanceID { (result, err) in
                            let token = result?.token ?? ""
                            self?.firebaseDatabase.updateDeviceToken(deviceToken: token, firebaseId: usr.uid)
                        }
                    } else {
                        printDebug("Could not update APNS token.")
                    }
                }, onError: { (err) in
                    printDebug("Fail to update APNS token (\(err.localizedDescription)).")
            }
        ).disposeOnDeactivate(interactor: self)
    }
    
    private func loadPromotionNows() {
        guard let coordinate = VatoLocationManager.shared.location?.coordinate, !checkedPromotion else {
            return
        }
        checkedPromotion = true
        let o1 = findZone(from: coordinate)
        let o2 = authenticated.firebaseAuthToken.take(1)
        let o: Observable<(String, Int)> = Observable.zip(o1, o2, resultSelector: { (zone, token) -> (String, Int) in
            return (token, zone.id)
        })
        
        o.take(1).flatMap { (token, zoneID) -> Observable<(HTTPURLResponse, MessageDTO<PromotionNow>)> in
            return Requester.requestDTO(using: VatoAPIRouter.promotionNow(authToken: token, zoneId: zoneID),
                                        method: .get,
                                        block: nil)
            }
            .subscribe(
                onNext: { [weak self] (_, message) in
                    guard message.data.manifestPredicates.count > 0 else {
                        return
                    }
                    let predicates = message.data.manifestPredicates.sorted(by: { (p1, p2) -> Bool in
                        return p1.priority > p2.priority
                    })
                    self?.mutablePromotionNows.update(newManifests: message.data.manifests)
                    self?.mutablePromotionNows.update(newManifestPredicates: predicates)
                },
                onDisposed: {
                    debugPrint("Disposed.")
            }
            ).disposeOnDeactivate(interactor: self)
    }
    
    private func checkUserDebt() {
        authenticated.firebaseAuthToken.take(1)
            .flatMap { (token) -> Observable<(HTTPURLResponse, MessageDTO<UserDebtDTO>)> in
                let api = VatoAPIRouter.getUserDebt(authToken: token)
                return Requester.requestDTO(using: api)
            }
            .observeOn(MainScheduler.instance)
            .trackProgressActivity(self.indicator)
            .subscribe(onNext: { [weak self] (_, message) in
                DispatchQueue.needCheckLatePayment = false
                guard message.data.amount > 0 else {
                    self?.loadPromotionNows()
                    return
                }
                self?.router?.presentLatePayment(with: message.data)
                self?.paymentStream.updateCheckLatePayment(status: true)
                
                }, onError: { [weak self] (err) in
                    self?.loadPromotionNows()
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    private func checkedLatePayment() {
        paymentStream.isCheckedLatePayment
            .bind { [weak self] (isChecked) in
                guard !isChecked else {
                    return
                }
                self?.checkUserDebt()
            }
            .disposeOnDeactivate(interactor: self)
    }
}

// MARK: VatoMainPresentableListener's members
extension VatoMainInteractor: VatoMainPresentableListener, ActivityTrackingProgressProtocol {
    private func prepareBook(service: VatoServiceType, model: AddressProtocol) {
        updateAddress(model: model) { [weak self](address) in
            self?.routeToBooking(data: .destination(s: service, address: address))
        }
    }
    
    func lookingForDestination(service: VatoServiceType, coordinate: Coordinate) {
        lookupAddress(for: coordinate.location.coordinate, maxDistanceHistory: PlacesHistoryManager.Configs.minDistance, isOrigin: false)
            .trackProgressActivity(indicator)
            .bind(onNext: weakify({ (address, wSelf) in
                wSelf.prepareBook(service: service, model: address)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func routeToShopping() {
        listener?.routeToShopping()
    }
    
    func routeToHistory(type: HistoryItemType?, object: Any?) {
        if let type = type, type == .busline {
            if let busline = object as? BusLineHomeItem {
                listener?.routeToTicket(action: .select(item: busline))
            } else {
                listener?.routeToTicket(action: .history)
            }
        } else {
            listener?.routeToHistory(type: type)
        }
    }
    
    func routeToProfile() {
        listener?.routeToProfile()
    }
    
    func routeToWallet() {
        listener?.routeToWallet()
    }
    
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?) {
        listener?.routeToServiceCategory(type: type, action: action)
    }
    
    func routeToScanQR() {
        router?.routeToScanQR()
    }
    
    var loading: Observable<(Bool, Double)> {
        return self.indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    func showListWalletHistory() {
        self.listener?.showListWalletHistory()
    }
    
    func routeToListPromotion() {
        self.listener?.routeToListPromotion()
    }
    
    func routeToTopup() {
        self.listener?.showTopUp()
    }
    
    var cachedItems: Observable<[VatoHomeLandingItemSection]> {
        return $mCachedItems.observeOn(MainScheduler.instance)
    }
    
    var listBanner: Observable<[VatoHomeLandingItem]> {
        return $mListBanner
    }
    
    var listSections: Observable<ListUpdate<VatoHomeLandingItemSection>> {
        return $mListSections.filterNil()
    }
    
    var user: Observable<UserInfo> {
        return profileStream.user.observeOn(MainScheduler.asyncInstance).debug("!!!!UserUpdate")
    }
    
    var homeResponse: Observable<[HomeResponse]> {
        return ConfigManager.shared.items
    }
    
    var servicesOngoing: Observable<[VatoHomeGroupEventGoing]> {
        return $mGroupServiceOnGoing.distinctUntilChanged()
    }
    
    var loadingRequest: Observable<Bool> {
        return $mLoadingRequest.observeOn(MainScheduler.asyncInstance)
    }
    
    func updateCheckLatePayment(status: Bool) {
        paymentStream.updateCheckLatePayment(status: status)
    }
    
    func routeToBooking(data: VatoMainData) {
        checkLocation().bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.moveToBook(data: data)
        })).disposeOnDeactivate(interactor: self)
    }
}

extension VatoMainInteractor: FindTripProtocol {
    private func checkMigration() {
        let appState = AppState.default()
        if appState.isMigratedToV530 == false {
            let migration = MigrationLocationHistory(database: firebaseDatabase)
            migration.execute()
        }
    }
    
    internal func requestEventOnGoing() {
        let router = VatoAPIRouter.customPath(authToken: "", path: "trip/events", header: nil, params: ["onGoing": true], useFullPath: false)
        
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router, decodeTo: OptionalMessageDTO<VatoHomeEventGoingResponse>.self).bind(onNext: weakify({ (result, wSelf) in
            switch result {
            case .success(let res):
                let items = res.data?.loadGroup() ?? []
                wSelf.mGroupServiceOnGoing = items
            case .failure(let e):
                #if DEBUG
                assert(false, e.localizedDescription)
                #endif
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func findDetailPromotion(code: String) {
        let items = PromotionManager.shared.promotionList?.listDisplay()
        let i = items?.first(where: { $0.state.code == code })

        guard let item = i else {
            return
        }
        handleLookupManifestAction(with: "\(item.state.manifestId)")
    }
    
    func handler(new pushData: [String: Any]) {
        self.previousPush = pushData
        guard
            let aps = pushData["aps"] as? [String: Any],
            let type = aps["type"] as? Int,
            let action = ManifestAction(rawValue: type)
            else {
                return
        }
        self.handler(manifest: action, info: aps)
    }
    
    func handler(manifest action: ManifestAction, info: [String: Any]) {
        switch action {
        case .web:
            guard let extra: String = info.value("extra", defaultValue: nil) ,let url = URL(string: extra.trim()) else {
                return
            }
            WebVC.loadWeb(on: router?.viewControllable.uiviewController.tabBarController, url: url, title: "")
            
        case .manifest:
            guard let extra: String = info.value("extra", defaultValue: nil) else {
                return
            }
            handleLookupManifestAction(with: extra)
        case .ecom:
            let key: String? = info.value("key", defaultValue: nil)
            showOrderEcom(orderId: key)
        }
    }
    
    private func showOrderEcom(orderId: String?) {
        guard let orderId = orderId, !orderId.isEmpty else { return }
        listener?.routeToEcomTracking(saleOderId: orderId)
    }
    
    private func handleLookupManifestAction(with extra: String) {
        let params: JSON = ["id": extra]
        let router = VatoAPIRouter.customPath(authToken: "", path: "manifest/get" , header: nil , params: params, useFullPath: false)
                
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<PromotionList.Manifest>.self,
            block: { $0.dateDecodingStrategy = .customDateFireBase })
            .trackProgressActivity(indicator)
            .bind(onNext: weakify({ (result, wSelf) in
                switch result {
                case .success(let res):
                    guard let data = res.data else {
                        return
                    }
                    wSelf.listener?.routeToPromotionDetail(manifest: data)
                case .failure(let e):
                    #if DEBUG
                    assert(false, e.localizedDescription)
                    #endif
                }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func checkPromotion() {
        guard UserDefaults.standard.value(forKey: "push_data") == nil else {
            return
        }
        
        
        Observable<(PromotionList.ManifestPredicate, PromotionList.Manifest)?>.combineLatest(mutablePromotionNows.allPredicates, mutablePromotionNows.allManifests) { (allPredicates, allManifests) -> (PromotionList.ManifestPredicate, PromotionList.Manifest)? in
            guard
                let predicate = allPredicates.first,
                let manifest = allManifests.first(where: { predicate.manifestId == $0.id }),
                predicate.active && manifest.active
                else {
                    return nil
            }
            return (predicate, manifest)
            }
            .filterNil()
            .take(1)
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (predicate, manifest) in
                let userDefaults = UserDefaults.standard
                if
                    let startDate = userDefaults.value(forKey: "promotion_now_start_date") as? TimeInterval,
                    let endDate = userDefaults.value(forKey: "promotion_now_end_date") as? TimeInterval,
                    let counter = userDefaults.value(forKey: "promotion_now_counter") as? Int,
                    let predicateID = userDefaults.value(forKey: "promotion_now_id") as? Int,
                    predicateID == predicate.id && startDate == predicate.startDate && endDate == predicate.endDate
                {
                    if counter < predicate.timesPerDay {
                        userDefaults.setValue((counter + 1), forKey: "promotion_now_counter")
                        userDefaults.synchronize()
                        
                        self?.listener?.promotionDetail(predicate: predicate, manifest: manifest)
                    } else {
                        // Reach maximum number of display per day
                    }
                } else {
                    userDefaults.setValue(predicate.startDate, forKey: "promotion_now_start_date")
                    userDefaults.setValue(predicate.endDate, forKey: "promotion_now_end_date")
                    userDefaults.setValue(1, forKey: "promotion_now_counter")
                    userDefaults.setValue(predicate.id, forKey: "promotion_now_id")
                    userDefaults.synchronize()
                    self?.listener?.promotionDetail(predicate: predicate, manifest: manifest)
                }
            }
            .disposeOnDeactivate(interactor: self)
    }
    
    func loadNapas() {
        fetchData().trackProgressActivity(self.indicator).observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] (list) in
            guard let wSelf = self else { return }
            wSelf.paymentStream.update(source: list)
            wSelf.checkedLatePayment()
        }, onError: { [weak self] (e) in
            guard let wSelf = self else { return }
            wSelf.loadPromotionNows()
            wSelf.paymentStream.update(source: [])
        }).disposeOnDeactivate(interactor: self)
    }

    private func fetchData() -> Observable<[PaymentCardDetail]> {
        let router = authenticated.firebaseAuthToken.take(1).map { VatoAPIRouter.listCard(authToken: $0) }
        return router.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<[PaymentCardDetail]>.self, using: $0)
            }.map { r -> [PaymentCardDetail] in
                if let e = r.response.error {
                    throw e
                } else {
                    let list = r.response.data.orNil([])
                    return list
                }
            }.catchError { (e) -> Observable<[PaymentCardDetail]> in
            return Observable.error(e)
        }
    }
}

// MARK: Class's private methods
private extension VatoMainInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        NotificationCenter.default.rx
        .notification(UIApplication.didReceiveMemoryWarningNotification)
        .bind(onNext: cleanupMemory)
        .disposeOnDeactivate(interactor: self)
        mutableBookingStream.booking.bind(onNext: weakify({ (b, wSelf) in
            wSelf.currentLocation = b.originAddress
        })).disposeOnDeactivate(interactor: self)
        
    }
    
}
