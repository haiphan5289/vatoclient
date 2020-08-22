//  File name   : HomeBridgeVC.swift
//
//  Author      : Vato
//  Created date: 9/13/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import CoreLocation
import KYDrawerController_ObjC
import FwiCore
import Firebase
import Alamofire
import RIBs
import RxSwift
import VatoNetwork
import FirebaseInstanceID

// dependency: VatoDependencyMainServiceProtocol, data: VatoMainData
final class HomeBridgeVC: UIViewController {
    /// Class's public properties.
    struct Config {
        static let timeRefreshToken: TimeInterval = 900
    }

    /// Class's destructor
    deinit {
        if let handler = handler {
            Auth.auth().removeIDTokenDidChangeListener(handler)
        }
    }
    
    // New
    weak var dependency: VatoDependencyMainServiceProtocol?
    var data: VatoMainData?
    
    private lazy var disposeBag = DisposeBag()
    private var userInfoError: Error?
    private var currentTripId: String?
    
    struct Tracking {
        static let tripStarted = "TripStarted"
        static let tripCompleted = "TripCompleted"
    }
    
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
    
    private func requestInformationUser() {
        self.getUser().filterNil().subscribe { [weak self](event) in
            switch event {
            case .next(let u):
                self?.getFirebaseAuthToken(user: u)
            case .error(let e):
                printDebug(e.localizedDescription)
            default:
                break
            }
        }.disposed(by: disposeBag)
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()

        if let controller = parent as? KYDrawerController {
            menuVC = controller
            controller.isScreenEdgePanGestreEnabled = false
            setMenuDegegate()
        }

        mapBuilder = MapBuilder(dependency: component)
        routing = mapBuilder?.build(withListener: self, data: self.data)

        guard let controller = routing?.viewControllable.uiviewController else {
            return
        }
        addChild(controller)
        controller.willMove(toParent: self)

        controller.view >>> view >>> { $0.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }}
        controller.didMove(toParent: self)

        routing?.interactable.activate()
//        routing?.load()

        // Register authentication
        if dependency == nil {
            requestInformationUser()
            checkMigration()
            checkLastTrip()
            loadPromotionNows()
            updateVersion()
            autoUpdateInforUser()
        }
        setupRX()
    }
    
    private func updateVersion() {
        let o1 = component.mutableAuthenticated.firebaseAuthToken.take(1)
        let o2 = component.profile.client.take(1)
        let o3 = component.profile.user.take(1)
        
        let o4 = Observable<String>.create { (o) -> Disposable in
            InstanceID.instanceID().instanceID { (result, err) in
                let token = result?.token ?? ""
                o.onNext(token)
            }
            return Disposables.create()
        }
        
        _ = Observable<(String, Client, UserInfo, String)>.combineLatest(o1, o2, o3, o4) { (token, client, user, deviceToken) -> (String, Client, UserInfo, String) in
            return (token, client, user, deviceToken)
            }
            .takeUntil(self.rx.deallocated)
            .flatMap { data -> Observable<(HTTPURLResponse, Data)> in
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
                            self?.component.firebaseDatabase.updateDeviceToken(deviceToken: token, firebaseId: usr.uid)
                        }
                    } else {
                        printDebug("Could not update APNS token.")
                    }
                }, onError: { (err) in
                    printDebug("Fail to update APNS token (\(err.localizedDescription)).")
            }
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visualize()
    }

    /// Class's private properties.
    private weak var menuVC: KYDrawerController?
    private var mapBuilder: MapBuildable?
    private var routing: MapRouting?

    private lazy var model = FCHomeViewModel()
    private lazy var component = HomeBridgeComponent(dependency: self.dependency)

    private var handler: IDTokenDidChangeListenerHandle?
    private var balanceDisposable: Disposable?
    private var tripDisposable: Disposable?
    private var user: User?
}

// MARK: View's event handlers
extension HomeBridgeVC {
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return .all
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // todo: Transfer data between views during presentation here.
    }

//    @IBAction func unwindTo(HomeBridgeVC segue: UIStoryboardSegue) {
//    }
}

// MARK: View's key pressed event handlers
extension HomeBridgeVC {
    @IBAction func handleMenuButtonOnPressed(_ sender: Any) {
    }
}

// MARK: Class's public methods
extension HomeBridgeVC {
}

// MARK: Class's private methods
extension HomeBridgeVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        UIApplication.setStatusBar(using: .default)
        
        let btn = UIButton.create {
            $0.backgroundColor = Color.orange
            $0.cornerRadius = 20
            $0.setTitle("Xe hợp đồng/ liên tỉnh", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            $0.setImage(UIImage(named: "ic_car"), for: .normal)
            $0.contentHorizontalAlignment = .left
            } >>> view >>> {
                $0.snp.makeConstraints({ (make) in
                    make.size.equalTo(CGSize(width: 230, height: 40))
                    make.left.equalTo(16)
                    make.top.equalTo(400)
                })
        }
        
        btn.rx.tap.bind(onNext: {[weak self] in
            self?.routing?.routeToContract()
        }).disposed(by: disposeBag)
    }
    
    private func autoUpdateInforUser() {
        Observable<Int>.interval(Config.timeRefreshToken, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self](_) in
                self?.requestInformationUser()
            }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(Notification.Name("kNotificationNetworkConnected"))
            .bind { [weak self] (_) in
                guard self?.user == nil else {
                    return
                }
                self?.requestInformationUser()
            }.disposed(by: disposeBag)
    }
    
    private func setupRX() {}

    private func retriveUserInfoIfNeccessary() {
        guard userInfoError != nil else {
            return
        }
        getUserInfo()
    }
    
    private func getFirebaseAuthToken(user: User?) {
        guard let user = user else {
            return
        }
        self.user = user
        user.getIDTokenForcingRefresh(true) { [weak self](token, err) in
            guard err == nil, let token = token else {
                return
            }
            self?.component.mutableAuthenticated.update(firebaseAuthToken: token)
            self?.getUserInfo()
        }

//        user.getIDToken { [unowned self] (token, err) in
//            guard err == nil, let token = token else {
//                return
//            }
//            self.component.mutableAuthenticated.update(firebaseAuthToken: token)
//        }
    }
    private func loadPromotionNows() {
        guard let coordinate = VatoLocationManager.shared.location?.coordinate else {
            return
        }

        let o1 = findZone(from: coordinate)
        let o2 = component.authenticated.firebaseAuthToken.take(1)
        let o: Observable<(String, Int)> = Observable.zip(o1, o2, resultSelector: { (zone, token) -> (String, Int) in
            return (token, zone.id)
//            return (token, service?.id ?? 0)
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
                self?.component.mutablePromotionNows.update(newManifests: message.data.manifests)
                self?.component.mutablePromotionNows.update(newManifestPredicates: predicates)
            },
            onDisposed: {
                debugPrint("Disposed.")
            }
        ).disposed(by: disposeBag)
    }

    private func getUserInfo() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let router = component.authenticated.firebaseAuthToken.take(1)
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
            }.observeOn(MainScheduler.asyncInstance).subscribe { [weak self] (e) in
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
            }.disposed(by: disposeBag)
    }

    private func getClientInfo(user: UserInfo) {
        _ = component.firebaseDatabase.findClient(firebaseId: user.firebaseId)
            .take(1)
            .subscribe(
                onNext: { [weak self] (client) in
                    var nextClient = client
                    nextClient.update(user: user)
                    self?.component.mutableProfile.updateClient(client: nextClient)
                },
                onError: { (err) in
//                    FwiLog.error(err)
                },
                onDisposed: {
//                    FwiLog.debug("Event had been disposed!")
                }
            )
    }
    
    func getBalance() {
        balanceDisposable?.dispose()
        balanceDisposable = nil

        balanceDisposable = self.component.authenticated.firebaseAuthToken
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
    
    private func updateUserBalance(cash: Double, coin: Double) {
        self.component.profile.user.subscribe(onNext: { [weak self] (user) in
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
            
        }).dispose()
    }

    private func checkMigration() {
        let appState = AppState.default()

        if appState.isMigratedToV530 == false {
            let migration = MigrationLocationHistory(database: component.firebaseDatabase)
            migration.execute()
        }
    }
    
    private func checkLastTrip() {
        let lastTripId = UserDataHelper.shareInstance().getLastestTripbookId()
        guard let tripId = lastTripId else {
            return
        }
        loadTrip(by: tripId, history: true)
    }
    
    func loadTrip(by tripId: String, history: Bool = false) {
        tripDisposable?.dispose()
        tripDisposable = nil
        currentTripId = tripId
        
        tripDisposable = self.findTripJSON(by: tripId)
            .subscribe(onNext: { [weak self] (tripInfo) in
                guard let _ = tripInfo["info"] as? [String : Any] else {
                    return
                }
                
                self?.beginLastTrip(info: tripInfo, history: history)
                self?.tripDisposable?.dispose()
                }, onError: { [weak self] (error) in
                    let err = error as NSError
                    printDebug(err.localizedDescription)
                    self?.tripDisposable?.dispose()
            })
    }
    
    private func beginLastTrip(info: [String: Any], history: Bool = true) {
        defer {
            if !history {
                trackingTrip(by: Tracking.tripStarted)
            }
        }
        let controller = TripMapsViewController()
        controller.bookSnapshot = info
        controller.fromHistory = history
        controller.delegate = self
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
        menuVC?.present(controller, animated: true, completion: nil)
    }

    private func findZone(from coordinate: CLLocationCoordinate2D) -> Observable<Zone> {
        return component.firebaseDatabase.findZone(with: coordinate).take(1)
    }

    private func findServices(by zone: Zone) -> Observable<[Service]> {
        return component.firebaseDatabase.findServices(by: zone.id).flatMap { [weak self] (s) -> Observable<[Service]> in
            guard s.count > 0 else {
                if let wSelf = self {
                    return wSelf.component.firebaseDatabase.findServices(by: ZoneConstant.vn)
                }
                return Observable.empty()
            }
            return Observable.just(s)
        }
    }
}

// MARK: MapListener's members
extension HomeBridgeVC: MapListener, FindTripProtocol {
    var firebaseDatabase: DatabaseReference {
        return self.component.firebaseDatabase
    }
    
    func bookChangeToInTrip(by tripId: String) {
        loadTrip(by: tripId)
    }
    
    func closeMenu() {
        menuVC?.setDrawerState(.closed, animated: true)
    }
    func showMenu() {
        guard let menu = self.menuVC else {
            routing?.interactable.deactivate()
            self.dismiss(animated: false, completion: nil)
            return
        }
        menu.setDrawerState(.opened, animated: true)
        setMenuDegegate()
    }
    
    func setMenuDegegate() {
        if let controller = parent as? KYDrawerController {
            if let menu = controller.drawerViewController as? MenusTableViewController {
                menu.delegate = self
            }
        }
    }

    func showWallet() {
        guard let controller: FCWalletViewController = FCWalletViewController.init(view: model) else {
            return
        }
        let navigationController = FacecarNavigationViewController(rootViewController: controller)
        menuVC?.present(navigationController, animated: true, completion: nil)
        controller.delegate = self
    }

    func beginBooking(with info: [String : Any], completion: @escaping () -> Void) {
        let controller = FCBookingRequestViewController()
        controller.bookInfo = info
        controller.delegate = self
        let navi = UINavigationController(rootViewController: controller)
        
        menuVC?.present(navi, animated: true, completion: completion)
    }
}

extension HomeBridgeVC: FCBookingRequestViewControllerDelegate {
    
    func onBookingFailed() {
        if let i = routing?.interactable as? MapInteractor {
            i.reloadPromotionModel()
        }
    }
    
    func onBookingCompleted() {
        // TODO: trip completed
        if let i = routing?.interactable as? MapInteractor {
            i.finishTrip()
        } else {
            let nextService: VatoServiceType
            if let data = self.data, case .service(let s) = data {
                nextService = s
            } else {
                nextService = .car
            }
            routing?.routeToHome(service: nextService)
        }
        guard self.data == nil else {
            return
        }
        getUserInfo()
    }
    
    private func trackingTrip(by eventName: String) {
        guard let cTrip = self.currentTripId, !cTrip.isEmpty else {
            return
        }
        let time = Date().timeIntervalSince1970
        var json = [String: Any]()
        json["TripID"] = cTrip
        json["Time"] = time
        guard let location = VatoLocationManager.shared.location else {
            return TrackingHelper.trackEvent(eventName, value: json)
        }
        let coordinate = location.coordinate
        json["Lat"] = coordinate.latitude
        json["Long"] = coordinate.longitude
        TrackingHelper.trackEvent(eventName, value: json)
    }
}

extension HomeBridgeVC: FCTripMapViewControllerDelegate {
    
    func onTripFailed() {
        getUserInfo()
    }
    
    func onTripCompleted() {
        getUserInfo()
        trackingTrip(by: Tracking.tripCompleted)

        guard let mapInteractor = routing?.interactable as? MapInteractor else {
            return
        }
        mapInteractor.resetLatePayment(status: false)
    }
    
    func onTripClientCancel() {
        getUserInfo()
    }
}

extension HomeBridgeVC: FCWalletDelegate {
    func onReceiveBalance(_ cash: Double, coin: Double) {
        self.updateUserBalance(cash: cash, coin: coin)
    }
}

extension HomeBridgeVC: FCMenuViewControllerDelegate {
    func onSelectedMenu(_ menu: FCMainMenu) {
        switch menu {
        case Wallet:
            guard let homeRouter = self.routing?.children.compactMap({ $0 as? HomeRouter}).first else {
                return
            }
            homeRouter.showWallet()
        case Promotion:
            guard menu == Promotion, let interactor = routing?.interactable as? MapInteractable else {
                return
            }
            interactor.handlePromotionAction()
        case Invite:
            guard let homeRouter = self.routing?.children.compactMap({ $0 as? HomeRouter}).first else {
                return
            }
            homeRouter.showReferral()
        default:
            break
        }
    }
    
    func onSelectedNotification(_ data: FCNotification?) {
        guard
            let extra = data?.rawData["extra"] as? String,
            let type = data?.rawData["type"] as? Int,
            let action = ManifestAction(rawValue: type),
            let interactor = routing?.interactable as? MapInteractor
        else {
            return
        }
        interactor.handlePromotionNotification(with: action, extra: extra)
    }
}
