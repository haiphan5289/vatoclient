//  File name   : VatoTabbarInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Firebase
import Alamofire
import VatoNetwork
import FwiCore
import FirebaseFirestore
import FwiCoreRX
import CoreLocation

enum VatoMainData: Equatable {
    case service(s: VatoServiceType)
    case promotion(model: PromotionModel)
    case destination(s: VatoServiceType, address: AddressProtocol)
    
    static func == (lhs: VatoMainData, rhs: VatoMainData) -> Bool {
        switch (lhs, rhs) {
        case (.service(let s1), .service(let s2)):
            return s1 == s2
        default:
            return false
        }
    }
    
    var isDelivery: Bool {
        switch self {
        case .service(let s):
            return s == .delivery
        case .promotion(let model):
            let p = model.data?.data?.promotionPredicates.first
            return p?.service == VatoServiceType.delivery.rawValue
        default:
            return false
        }
    }
    
    var isByTicket: Bool {
        switch self {
        case .service(let s):
            return s == .buyTicket
        case .promotion(let model):
            let p = model.data?.data?.promotionPredicates.first
            return p?.service == VatoServiceType.buyTicket.rawValue
        default:
            return false
        }
    }
    
    var isTaxiService: Bool {
        switch self {
        case .service(let s):
            return s == .taxi
                || s == .taxi7
        case .promotion(let model):
            let p = model.data?.data?.promotionPredicates.first
            return p?.serviceCanUse().contains(where: { $0 == .taxi || $0 == .taxi7 }) == true
        case .destination(let s, _):
            return s == .taxi || s == .taxi7
        }
    }
}

enum ServiceCategoryType: Int, CaseIterable {
    case food = 0
    case beauty
    case medicine
    case shop
    case hotel
    case market
    case more
    case supply
    
    var categoryId: Int {
        switch self {
        case .food:
            return 2
        case .beauty:
            return 4
        case .medicine:
            return 324
        case .shop:
            return 315
        case .hotel:
            return 422
        case .market:
            return 355
        case .supply:
            return -1000
        default:
            return -1
        }
    }
    
    static func loadEcom(category: Int?) -> ServiceCategoryType? {
        guard let category = category else { return nil }
        return ServiceCategoryType.allCases.first(where: { $0.categoryId == category })
    }
}

protocol VatoTabbarRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func presentAlert(message: String)
    func presentAlert(title: String, message: String, cancelAction: String)
    func routeToBooking(dependency: VatoDependencyMainServiceProtocol , data: VatoMainData)
    func routeToPromotionDetail(manifest: PromotionList.Manifest)
    func routeToPromotionDetail(predicate: PromotionList.ManifestPredicate, manifest: PromotionList.Manifest)
    func routeToPromotionDetail(with action: ManifestAction, extra: String)
    func routeToNotifySignedOtherDevice()
    func routeToListPromotion()
    func routeToDelivery()
    func routeToTicket(action: TicketDestinationAction?)
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?)
    func showListWalletHistory()
    func doSignOut()
    func routeToMainMerchant()
    func routeToQuickSupport()
    func routeToTopup()
    func routeToProfile()
    func routeToWallet()
    func selectNotification(notify: NotificationModel?)
    func routeToEcomTracking(saleOderId: String)
    func routeToShortcut()
    func routeToHistory(selected: HistoryItemType?)
    func routeToShopping()
}

protocol VatoTabbarPresentable: Presentable {
    var listener: VatoTabbarPresentableListener? { get set }
    func cleanUp()

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol VatoTabbarListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class VatoTabbarInteractor: PresentableInteractor<VatoTabbarPresentable>, ActivityTrackingProgressProtocol, LocationRequestProtocol {
    /// Class's public properties.
    weak var router: VatoTabbarRouting?
    weak var listener: VatoTabbarListener?
    private var balanceDisposable: Disposable?
    private var userInfoError: Error?
    
    /// Class's constructor.
    init(presenter: VatoTabbarPresentable, component: VatoDependencyMainServiceProtocol, mutableBooking: MutableBookingStream) {
        self.mutableBooking = mutableBooking
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self

    }
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        FirebaseTokenHelper.instance.startUpdate()
        ConfigManager.shared.loadConfig()
        setupFavorite()
        super.didBecomeActive()
        PlacesHistoryManager.instance.initialize()
        setupRX()
        getPointsTicket()
        getDefautConfig()
        
        ThemeManager.instance.findThemeConfig()
        guard let userInfo = UserManager.instance.info else {
            return
        }
        
        self.component.mutableProfile.updateUserInfo(user: userInfo)
        // todo: Implement business logic here.
        
        ShortcutItemManager.instance.shortcutItem.bind(onNext: weakify({ (type, wSelf) in
            switch type {
            case .quickBooking:
                if wSelf.router?.viewControllable.uiviewController.presentedViewController is HomeBridgeVC {
                    return
                }
                                
                wSelf.moveToBook(data: .service(s: .car))
            case .food:
                wSelf.router?.routeToServiceCategory(type: .food, action: nil)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
        
        QuickSupportManager.instance.getListRequest()
    }

    override func willResignActive() {
        presenter.cleanUp()
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private func setupFavorite() {
        FavoritePlaceManager.shared.listener = self
    }

    /// Class's private properties.
    private let component: VatoDependencyMainServiceProtocol
    private lazy var mReady: PublishSubject<Bool> = PublishSubject()
    private let mutableBooking: MutableBookingStream
    @UserDefault("appIconCurrent", defaultValue: 0) private var appIconCurrent: Int
    var token: Observable<String> {
        return component.mutableAuthenticated.firebaseAuthToken.take(1)
    }
}

// MARK: VatoTabbarInteractable's members
extension VatoTabbarInteractor: VatoTabbarInteractable {
    func routeToTicket(action: TicketDestinationAction?) {
        router?.routeToTicket(action: action)
    }
    
    func routeToHistory(type: HistoryItemType?) {
        router?.routeToHistory(selected: type)
    }
    
    func inTripNewBook() {
        router?.dismissCurrentRoute(completion:{ [weak self] in
            self?.moveToBook(data: .service(s: .car))
        })
    }
    
    func showReceipt(salesOrder: SalesOrder) {
        fatalError("Please Implement")
    }
    
    func shoppingMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToAddDestinationConfirm() {
    }
    
    func setLocationMoveBack(_ address: AddressProtocol?) {}
    
    func historyMoveHome() {
        
    }
    
    func notificationDismiss() {
        
    }
    
    func setLocationMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }      
    
    func shortcutRouteToFood() {
        self.router?.dismissCurrentRoute(completion: {[weak self] in
            self?.routeToFood()
        })
    }
        
    func shortcutDismiss() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func historyDismiss() {
        router?.dismissCurrentRoute(completion: nil)    }
    
    func routeToShortcutItem(item: TOShortutModel) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.routeToItem(item: item)
        })
    }
    
    private func routeToItem(item: TOShortutModel) {
        switch item.type {
        case .paymentHistory:
            router?.showListWalletHistory()
        case .history:
            router?.routeToHistory(selected: nil)
            break
        case .quickSupport:
            router?.routeToQuickSupport()
        case .sos:
            break
        case .merchant:
            router?.routeToMainMerchant()
        case .inviteFriend:
            break
        case .uniform:
            break
        case .booking:
            break
        case .topup:
            router?.routeToTopup()
        default:
            break
        }
    }
    
    func routeToProfile() {
        router?.routeToProfile()
    }
    
    func routeToWallet() {
        router?.routeToWallet()
    }
    
    func profileMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToShortcut() {
        router?.routeToShortcut()
    }
    
    func routeToEcomTracking(saleOderId: String) {
        router?.routeToEcomTracking(saleOderId: saleOderId)
    }
    
    func trackingRouteToFood() {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.routeToFood()
        }))
    }
    
    
    func dismissStoreTracking() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func showTopUp() {
        router?.routeToTopup()
    }
    func topUpMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func quickSupportMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func selectNotification(notify: NotificationModel?) {
        self.router?.selectNotification(notify: notify)
    }
    
    func routeToFood() {
        self.routeToServiceCategory(type: .food, action: nil)
    }
    
    func foodMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func merchantMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    
    func ticketMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToShopping() {
        findAddress().bind(onNext: weakify({ (marker, wSelf) in
            wSelf.mutableBooking.updateBooking(originAddress: marker)
            wSelf.router?.routeToShopping()
        })).disposeOnDeactivate(interactor: self)
    }
    
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?, removeCurrent: Bool) {
        let actionHandler: () -> Void = { [weak self] in
            self?.routeToServiceCategory(type: type, action: action)
        }
        if removeCurrent {
            router?.dismissCurrentRoute(completion: actionHandler)
        } else {
            actionHandler()
        }
    }
    
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?) {
        findAddress().trackProgressActivity(self.indicator).observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (marker, wSelf) in
            wSelf.mutableBooking.updateBooking(originAddress: marker)
            if type == .supply {
                wSelf.router?.routeToShopping()
            } else {
                wSelf.router?.routeToServiceCategory(type: type, action: action)
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    func updateUserBalance(cash: Double, coin: Double) {
        self.component.mutableProfile.user.take(1).subscribe(onNext: { [weak self] (user) in
            var nextUser = user
            nextUser.cash = cash
            nextUser.coin = coin
            
            self?.component.mutableProfile.updateUserInfo(user: nextUser)
            
            let user = Auth.auth().currentUser
            guard let usr = user else {
                return
            }
            self?.component.firebaseDatabase.updateBalance(cash: cash, coin: coin, firebaseId: usr.uid)
            
            }, onError: { (error) in
                let e = error as NSError
                printDebug("update balance error: \(e)")
                
        }).disposeOnDeactivate(interactor: self)
    }
    
    func deliveryMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func onTripCompleted() {
        getBalance()
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func booking(use: JSON) {
        let instance = PlacesHistoryManager.instance
        mutableBooking.booking.take(1).observeOn(MainScheduler.asyncInstance).subscribe(onNext: { (book) in
            var origin = book.originAddress
            origin.update(isOrigin: true)
            instance.add(value: book.originAddress)
            guard var destination = book.destinationAddress1 else {
                return
            }
            destination.update(isOrigin: false)
            instance.add(value: destination)
        }).disposeOnDeactivate(interactor: self)
    }
    
    func doSignOut() {
        router?.doSignOut()
    }
    
    func showListWalletHistory() {
        router?.showListWalletHistory()
    }
    
    func listDetailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToListPromotion() {
        router?.routeToListPromotion()
    }
    
    func promotionMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func update(model: PromotionModel?) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            guard let model = model else {
                return
            }
            wSelf.moveToBook(data: .promotion(model: model))
        }))
    }
    
    func reloadBalance() {
//        getBalance()
    }
    
    func routeToMainMerchant() {
        router?.routeToMainMerchant()
    }
    
    var ready: Observable<Bool> {
        return mReady.observeOn(MainScheduler.asyncInstance)
    }
    
    func promotionDetail(predicate: PromotionList.ManifestPredicate, manifest: PromotionList.Manifest) {
        self.router?.routeToPromotionDetail(predicate: predicate, manifest: manifest)
    }
    
    func routeToPromotionDetail(manifest: PromotionList.Manifest) {
        router?.routeToPromotionDetail(manifest: manifest)
    }
    
    func dismissDetail() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func moveToBook(data: VatoMainData) {
        findAddress().trackProgressActivity(self.indicator).observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (marker, wSelf) in
            wSelf.mutableBooking.updateBooking(originAddress: marker)
            MapInteractor.Config.defaultMarker = MarkerHistory.init(with: marker)
            guard !data.isDelivery else {
                wSelf.routeToDelivery(use: data)
                return
            }
            guard !data.isByTicket else {
                wSelf.router?.routeToTicket(action: nil)
                return
            }
            wSelf.router?.routeToBooking(dependency: wSelf.component, data: data)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func wallet(handle action: WalletAction) {
        switch action {
        case .moveBack:
            router?.dismissCurrentRoute(completion: nil)
        }
    }
    
    func routeToQuickSupport() {
        router?.routeToQuickSupport()
    }
    
}

// MARK: VatoTabbarPresentableListener's members
extension VatoTabbarInteractor: VatoTabbarPresentableListener, Weakifiable {
    var loading: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
}

// MARK: Class's private methods
private extension VatoTabbarInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        mReady.filter { !$0 }.bind(onNext: weakify({ (r, wSelf) in
            wSelf.router?.routeToNotifySignedOtherDevice()
        })).disposeOnDeactivate(interactor: self)
        
        component.mutableProfile.client.take(1).bind(onNext: weakify({ (client, wSelf) in
            wSelf.checking(deviceInfo: client.deviceInfo)
        })).disposeOnDeactivate(interactor: self)
        
        self.mReady.filter { $0 }.bind {[weak self] (_) in
            self?.addListenerDeviceInfo()
        }.disposeOnDeactivate(interactor: self)
        
        NotificationCenter.default.rx.notification(.profileUpdated).bind(onNext: weakify({ (_, wSelf) in
            wSelf.updateProfile()
        })).disposeOnDeactivate(interactor: self)
        
        NotificationCenter.default.rx.notification(.profileUpdatedAvatar).map { $0.object as? String }.bind(onNext: weakify({ (url, wSelf) in
            var user = UserManager.instance.info
            user?.avatarUrl = url
            wSelf.component.mutableProfile.updateUserInfo(user: user)
        })).disposeOnDeactivate(interactor: self)
        
        FirebaseTokenHelper.instance.eToken.filterNil().bind { [weak self](token) in
            self?.component.mutableAuthenticated.update(firebaseAuthToken: token)
            self?.getUserInfo()
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func updateProfile() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let userInfor = component.firebaseDatabase.findUser(firebaseId: user.uid).take(1)
        userInfor.bind(onNext: weakify({ (user, wSelf) in
            wSelf.component.mutableProfile.updateUserInfo(user: user)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func checking(deviceInfo: DeviceInfo?) {
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        guard let deviceInfo = deviceInfo else {
            return mReady.onNext(false)
        }
        // Compare uuid
        guard let id = deviceInfo.id, id == uuid else {
            return mReady.onNext(false)
        }
        self.mReady.onNext(true)
    }
}

private extension VatoTabbarInteractor {
    func routeToDelivery(use data: VatoMainData) {
        switch data {
        case .promotion(let model):
            mutableBooking.updatePromotion(promotion: model)
        default:
            break
        }
        
        findAddress().trackProgressActivity(self.indicator).observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (marker, wSelf) in
            wSelf.mutableBooking.updateBooking(originAddress: marker)
            wSelf.router?.routeToDelivery()
        })).disposeOnDeactivate(interactor: self)
    }
    
    func findAddress() -> Observable<AddressProtocol> {
        #if targetEnvironment(simulator)
          // your simulator code
          return mutableBooking.booking.take(1).map { $0.originAddress }
        #else
          // your real device code
          let status = CLLocationManager.authorizationStatus()
          switch status {
          case .authorizedWhenInUse, .authorizedAlways:
              return VatoLocationManager.shared.$locations.map { $0.last }.filterNil().take(1).flatMap { [weak self] location -> Observable<AddressProtocol> in
                  guard let wSelf = self else { return Observable.empty() }
                return wSelf.lookupAddress(for: location.coordinate, maxDistanceHistory: PlacesHistoryManager.Configs.defaultRadius, isOrigin: true)
              }
          default:
              return mutableBooking.booking.take(1).map { $0.originAddress }
          }
        #endif
    }
}

// MARK: - Promotion
extension VatoTabbarInteractor {
    func handleLookupManifestAction(with extra: String) {
        let params: JSON = ["id": extra]
        let router = VatoAPIRouter.customPath(authToken: "", path: "manifest/get" , header: nil , params: params, useFullPath: false)
                
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        network.request(using: router,
                        decodeTo: OptionalMessageDTO<PromotionList.Manifest>.self,
                        block: { $0.dateDecodingStrategy = .customDateFireBase })
            .bind(onNext: weakify({ (result, wSelf) in
                switch result {
                case .success(let res):
                    guard let data = res.data else {
                        return
                    }
                    wSelf.router?.routeToPromotionDetail(manifest: data)
                case .failure(let e):
                    #if DEBUG
                    assert(false, e.localizedDescription)
                    #endif
                }
        })).disposeOnDeactivate(interactor: self)
    }
    
    
    func apply(promotion: PromotionModel) {
        self.moveToBook(data: .promotion(model: promotion))
    }
    
    func usePromotion(code: String, from manifest: PromotionList.Manifest) {
        requestPromotionData(from: code)
            .observeOn(MainScheduler.instance)
            .map({ data -> PromotionModel in
                let model = PromotionModel(with: code)
                model.data = data
                model.mainfest = manifest
                return model
            })
            .subscribe(
                onNext: { [weak self] (model) in
                    model.promotionFrom = .manifest
                    self?.apply(promotion: model)
                },
                onError: { [weak self] (e) in
                    self?.router?.presentAlert(title: Text.notification.localizedText, message: "Không thể sử dụng mã khuyến mãi, vui lòng thử lại sau.", cancelAction: "Đóng")
                }
            )
            .disposeOnDeactivate(interactor: self)
    }
    
    private func requestPromotionData(from code: String) -> Observable<PromotionData> {
        return component.mutableAuthenticated
            .firebaseAuthToken.take(1)
            .flatMap { key -> Observable<(HTTPURLResponse, PromotionData)> in
                Requester.requestDTO(using: VatoAPIRouter.promotion(authToken: key, code: code), method: .post, encoding: JSONEncoding.default, block: { $0.dateDecodingStrategy = .customDateFireBase })
            }.map {
                let data = $0.1
                guard data.status == 200 else {
                    throw NSError(domain: NSURLErrorDomain, code: data.status, userInfo: [NSLocalizedDescriptionKey: data.message ?? ""])
                }
                return data
        }
    }
}

// MARK: - User
extension VatoTabbarInteractor {
    private func getUser() -> Observable<User?> {
        return Observable.create({ (s) -> Disposable in
            let handle = Auth.auth().addIDTokenDidChangeListener { (_, user) in
                s.onNext(user)
                if user != nil {
                    s.onCompleted()
                }
            }
            
            return Disposables.create {
                Auth.auth().removeIDTokenDidChangeListener(handle)
            }
        })
    }
    
    private func getUserInfo() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let router = component.mutableAuthenticated.firebaseAuthToken.take(1)
            .map({
                VatoAPIRouter.getBalance(authToken: $0)
            })
        
        // balance
        let request = router.flatMap {
            Requester.responseDTO(decodeTo: OptionalMessageDTO<WalletResponse>.self, using: $0)
        }
        
        // userinfor
        let userInfor = component.firebaseDatabase.findUser(firebaseId: user.uid).take(1)
        
        Observable.zip(userInfor, request) { (u, v2) -> UserInfo in
            if let e = v2.response.error {
                throw e
            }
            var user = u
            let response = v2.response.data
            user.cash = response?.cash ?? 0
            user.coin = response?.coin ?? 0
            return user
        }
        .observeOn(MainScheduler.asyncInstance)
        .timeout(.seconds(10), scheduler: MainScheduler.asyncInstance)
        .catchError({ (e) -> Observable<UserInfo> in
            if let u = UserManager.instance.info {
                return Observable.just(u)
            } else {
                return Observable.error(e)
            }
        })
        .subscribe { [weak self] (e) in
            switch e {
            case .next(let userInfo):
                self?.component.mutableProfile.updateUserInfo(user: userInfo)
                self?.getClientInfo(user: userInfo)
                self?.userInfoError = nil
                
            case .error(let error):
                self?.userInfoError = error
                printDebug(error.localizedDescription)
                
            case .completed:
                printDebug("Completed!!!")
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func getClientInfo(user: UserInfo) {
        component.firebaseDatabase.findClient(firebaseId: user.firebaseId)
            .take(1)
            .subscribe(
                onNext: { [weak self] (client) in
                    var nextClient = client
                    nextClient.update(user: user)
                    self?.component.mutableProfile.updateClient(client: nextClient)
                },onError: { (err) in
                    
            }, onDisposed: {
            }
        ).disposeOnDeactivate(interactor: self)
    }
    
    internal func getBalance () {
        balanceDisposable?.dispose()
        balanceDisposable = nil
        
        balanceDisposable = self.component.mutableAuthenticated.firebaseAuthToken
            .take(1)
            .flatMap { (token) -> Observable<(HTTPURLResponse, Message<Balance>)> in
                return Requester.requestDTO(using: VatoAPIRouter.getBalance(authToken: token))
            }
            .subscribe(onNext: { [weak self] (response, message) in
                if message.status == .success {
                    self?.updateUserBalance(cash: message.data.cash, coin: message.data.coin)
                } else {
                    self?.updateUserBalance(cash: 0, coin: 0)
                }
            })
    }
    
    private func addListenerDeviceInfo() {
        self.component.mutableProfile.user.take(1).flatMap { (userInfo) in
            self.component.firebaseDatabase.addListenerDeviceInfo(from: userInfo.firebaseId)
            }.subscribe(onNext: {[weak self] (deviceInfo) in
                self?.checking(deviceInfo: deviceInfo)
            }).disposeOnDeactivate(interactor: self)
    }

    func getPointsTicket() {
        component.mutableAuthenticated.firebaseAuthToken.take(1).map {
            VatoTicketApi.listOriginPoint(authToken: $0)
            }.flatMap {
                Requester.responseCacheDTO(decodeTo: OptionalMessageDTO<[TicketDestinationPoint]>.self, using: $0)
            }.subscribe(onNext: {(r) in
            }).disposeOnDeactivate(interactor: self)
    }
    
    func getDefautConfig() {
        FireStoreConfigDataManager.shared.getDefautConfig()
        BuslineConfigDataManager.shared.load()
    }
}

// MARK: - App Icon
extension VatoTabbarInteractor {
    // Hiding not use in present
//    func listenAppIconChange() {
//        let documentRef = Firestore.firestore().documentRef(collection: .theme, storePath: .custom(path: "AppIcon") , action: .read)
//        let eventChange = documentRef.find(action: .listen).filterNil().map { [weak self] (snapshot) -> AppIconType? in
//            guard let wSelf = self else { return nil }
//            guard let value: Int = snapshot.data()?.value("type", defaultValue: nil), value != wSelf.appIconCurrent else {
//                return nil
//            }
//            return AppIconType(rawValue: value) ?? .default
//        }.filterNil().observeOn(MainScheduler.asyncInstance)
//
//        /*
//        let eventChange = Observable<Int>.interval(RxTimeInterval.seconds(5), scheduler: MainScheduler.asyncInstance).map { (_) -> AppIconType? in
//            let v = Int.random(in: 0...1)
//            return AppIconType(rawValue: v)
//        }.filterNil()
//        */
//        eventChange.subscribe {(event) in
//            switch event {
//            case .next(let type):
//                VatoChangeAppIcon.changeAppIcon(withName: type.iconName) { [weak self](changed) in
//                    guard changed else { return }
//                    self?.appIconCurrent = type.rawValue
//                }
//                /*
//                guard UIApplication.shared.supportsAlternateIcons else {
//                  return
//                }
//                UIApplication.shared.setAlternateIconName(type.iconName) { [weak self] (e) in
//                    if let e = e {
//                        print(e.localizedDescription)
//                        return
//                    }
//                    self?.appIconCurrent = type.rawValue
//                }
//                */
//            case .error(let e):
//                print(e.localizedDescription)
//            default:
//                break
//            }
//        }.disposeOnDeactivate(interactor: self)
//    }
}

//enum AppIconType: Int, CaseIterable {
//    case `default` = 0
//    case tet = 1
//
//    var iconName: String {
//        switch self {
//        case .default:
//            #if DEBUG
//                return "appDEVDefault"
//            #else
//                return "appDefault"
//            #endif
//        case .tet:
//            return "appTet"
//        }
//    }
//}



