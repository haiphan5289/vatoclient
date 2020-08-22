//  File name   : MapInteractor.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Firebase
import RealmSwift
import RIBs
import RxSwift
import Alamofire
import VatoNetwork

protocol MapRouting: ViewableRouting {
    func routeToHome(service: VatoServiceType)
    func routeToSearchLocation()
    func routeToPickLocation()
    func routeToConfirmBooking()
    func routeToSetLocation()
    func routeToPromotion(coordinate: CLLocationCoordinate2D?)
    func routeToPromotionDetail(manifest: PromotionList.Manifest)
    func routeToPromotionDetail(predecate: PromotionList.ManifestPredicate, manifest: PromotionList.Manifest)
    func routeToDelivery()
    func routeToVatoTaxi()
    func routeToLocationPicker(type: SearchType, address: AddressProtocol?)
    func routeToContract()
    
    func presentAlert(message: String)
    func presentAlert(title: String, message: String, cancelAction: String)
}

protocol MapPresentable: Presentable {
    var listener: MapPresentableListener? { get set }

    func moveCamera(to location: CLLocationCoordinate2D)
}

protocol MapListener: class {
    func closeMenu()
    func showMenu()
    func showWallet()
    func bookChangeToInTrip(by tripId: String)
    func beginBooking(with info: [String: Any], completion: @escaping () -> Void)
    func onTripCompleted()
    func getBalance()
}

final class MapInteractor: PresentableInteractor<MapPresentable>, MapInteractable, MapPresentableListener, Weakifiable, LocationRequestProtocol {
    private (set)var stopListenUpdateLocation: PublishSubject<Void> = PublishSubject()
    weak var router: MapRouting?
    weak var listener: MapListener?
    private let paymentStream: MutablePaymentStream
    var data: VatoMainData?
    var checked: Bool = false
    struct Config {
        static var defaultMarker : MarkerHistory = {
            let marker = MarkerHistory()
            marker.lat = 10.7664067
            marker.lng = 106.6935349
            marker.name = "Tập Đoàn Phương Trang"
            marker.thoroughfare = "80 Trần Hưng Đạo"
            marker.locality = "Phường Phạm Ngũ Lão"
            marker.subLocality = "Quận 1"
            marker.administrativeArea = ""
            marker.country = "Việt Nam"
            return marker
        }()
    }

    /// Class's constructor.
    init(presenter: MapPresentable,
         mutableAuthenticated: MutableAuthenticatedStream,
         mutableBooking: MutableBookingStream,
         firebaseDatabase: DatabaseReference,
         googleAPIKey: String,
         mutableDisplayPromotionNow: MutableDisplayPromotionNowStream,
         paymentStream: MutablePaymentStream,
         data: VatoMainData?)
    {
        self.data = data
        self.mutableAuthenticated = mutableAuthenticated
        self.mutableBooking = mutableBooking
        self.firebaseDatabase = firebaseDatabase
        self.googleAPIKey = googleAPIKey
        self.mutableDisplayPromotionNow = mutableDisplayPromotionNow
        self.paymentStream = paymentStream
        super.init(presenter: presenter)
        presenter.listener = self
    }
    var token: Observable<String> {
        return mutableAuthenticated.firebaseAuthToken.take(1)
    }

    private var notification: AnyObject?
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
    }
    
    func moveToDefaultSelect() {
        guard let data = self.data else {
            return
        }
        let state = self.mutableBooking.mode.filter { $0 == .home }.take(1)
        let book = self.mutableBooking.booking.take(1)
        Observable.zip(state, book) { (_, b) -> Booking in
            return b
        }.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance).bind { [weak self](b) in
                guard let wSelf = self else { return }
                switch data {
                case .promotion(let model):
                    wSelf.update(model: model)
                case .service(let s):
                    switch s {
                    case .delivery:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            wSelf.presentDelivery()
                        }
                    default:
                        let new = b
                        b.defaultSelect.service = s
                        wSelf.mutableBooking.updateBookByService(book: new)
//                        self?.mutableBooking.changeMode(mode: .searchLocation(suggestMode: .destination1))
                    }
                case .destination(let s, let coordinate):
                    switch s {
                        case .delivery:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self?.presentDelivery()
                            }
                        default:
                            var new = b
                            new.defaultSelect.service = s
                            new.destinationAddress1 = coordinate
                            wSelf.mutableBooking.updateBookByService(book: new)
                            wSelf.mutableBooking.changeMode(mode: .bookingConfirm)
                            
                    }
                }
            }.disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    func moveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }

    func bookChangeToInTrip(by tripId: String) {
        displayToHome()
        self.listener?.bookChangeToInTrip(by: tripId)
    }
    
    func getBalance() {
        listener?.getBalance()
    }
    
    func presentDelivery() {
        router?.routeToDelivery()
    }

    func beginQuickBooking() {
        router?.routeToConfirmBooking()
    }
    
    func deliveryMoveBack() {
        if let data = self.data,  case .service(let s) = data, s == .delivery {
            router?.dismissCurrentRoute(true, completion: { [weak self] in
                self?.beginMenu()
            })
        } else {
            router?.dismissCurrentRoute(completion: { [weak self] in
                // Check
                guard let wSelf = self else {
                    return
                }
                 wSelf.moveHomeIfNeed()
            })
        }
    }
    
    private func moveHomeIfNeed() {
        guard self.router?.children.compactMap ({ $0 as? HomeRouter }).first == nil else {
            return
        }
        self.mutableBooking.changeMode(mode: .home)
    }

    func beginConfirmBooking() {
        mutableBooking.booking.take(1).bind { [weak self] in
            self?.book(with: $0)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func pickerDismiss(currentAddress: AddressProtocol?) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            wSelf.handlerPickerLocationBack()
        }))
    }
    
    func handlerPickerLocationBack() {
        self.mutableBooking.mode.take(1).bind(onNext: weakify({ (mode, wSelf) in
            guard let next = mode.previous else { return }
            wSelf.mutableBooking.changeMode(mode: next)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func didSelectModel(model: AddressProtocol) {
        self.router?.dismissCurrentRoute(completion: { [weak self] in
            self?.updateAddress(model: model)
        })
    }
    
    private func updateAddress(model: AddressProtocol) {
        let mode = mutableBooking.mode.take(1)
        let valid = validate(address: model)
        
        Observable.zip(mode, valid) {
            return ($0, $1)
        }.bind(onNext: weakify({ (i, wSelf) in
            guard let next = i.0.next else { return }
            switch next {
            case .home:
                wSelf.mutableBooking.updateBooking(originAddress: i.1)
                wSelf.mutableBooking.changeMode(mode: next)
            case .bookingConfirm:
                if model.isOrigin {
                    wSelf.mutableBooking.updateBooking(originAddress: i.1)
                } else {
                    wSelf.mutableBooking.updateBooking(destinationAddress1: i.1)
                }
                wSelf.mutableBooking.changeMode(mode: next)
            default:
                break
            }
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func book(with booking: Booking) {
        // Destination must be defined
        guard let d1 = booking.destinationAddress1 else {
            router?.presentAlert(message: "Bạn chưa chọn điểm đến, xin vui lòng thử lại.")
            return
        }
        
        // Distance must be greater than or equal to 50 meters
        let c1 = booking.originAddress.coordinate
        let c2 = d1.coordinate
        let distance = round(c1.distance(to: c2))
        guard distance >= 50.0 else {
            router?.presentAlert(message: Text.minDistanceBetweenOriginAndDestination.localizedText)
            self.mutableBooking.mode.take(1).bind { [weak self] state in
                if state != .home {
                    self?.displayToHome()
                }
            }.disposeOnDeactivate(interactor: self)
            
            return
        }
        if self.data?.isTaxiService == true {
            router?.routeToVatoTaxi()
        } else {
            router?.routeToConfirmBooking()
        }
    }

    func displayToHome() {
        mutableBooking.changeMode(mode: .home)
    }

    func finishTrip() {
        mutableBooking.booking.map { $0.destinationAddress1 }
            .filterNil()
            .subscribe(onNext: { [weak self] address in
                self?.mutableBooking.updateBooking(originAddress: address)
                let appState = AppState.default()
                do {
                    try appState.realm?.write {
                        appState.lastLatitude = address.coordinate.latitude
                        appState.lastLongitude = address.coordinate.longitude
                    }
                } catch let err as NSError {
                    debugPrint(err.localizedDescription)
                }
            })
            .dispose()

        mutableBooking.reset()
        mutableBooking.changeMode(mode: .home)
    }

    func resetLatePayment(status: Bool) {
        paymentStream.updateCheckLatePayment(status: status)
    }

    func onTripCompleted() {
        self.listener?.onTripCompleted()
    }
    
    func pickerLocation(type: SearchType) {
        mutableBooking.booking.take(1).observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (booking, wSelf) in
            switch type {
            case .booking(let origin, _ , _, _):
                let address = origin ? booking.originAddress : booking.destinationAddress1
                
//                if origin == false && booking.destinationAddress1 == nil {
//                    address = Address(placeId: nil, coordinate: booking.originAddress.coordinate, name: "", thoroughfare: "", locality: "", subLocality: "", administrativeArea: "", postalCode: "", country: "", lines: [], favoritePlaceID: 0, zoneId: 0, isOrigin: false, counter: 0, distance: nil)
//                }
                
                wSelf.router?.routeToLocationPicker(type: type, address: address ?? MapInteractor.Config.defaultMarker.address)
            default:
                assert(false, "Check logic!!!!")
            }
        })).disposeOnDeactivate(interactor: self)
    }

    func beginMenu() {
        listener?.showMenu()
    }

    func beginWallet() {
        listener?.showWallet()
    }

    func handlePromotionAction() {
        mutableBooking.booking.map { $0.originAddress.coordinate }.take(1).bind(onNext: weakify({ (coord, wSelf) in
            wSelf.router?.routeToPromotion(coordinate: coord)
        })).disposeOnDeactivate(interactor: self)
    }

    func booking(use json: [String: Any]) {
        let instance = PlacesHistoryManager.instance
        mutableBooking.booking.take(1).observeOn(MainScheduler.asyncInstance).subscribe(onNext: { (book) in
            var origin = book.originAddress
            origin.update(isOrigin: true)
            instance.add(value: origin)
            guard var destination = book.destinationAddress1 else {
                return
            }
            destination.update(isOrigin: false)
            instance.add(value: destination)
        }).disposeOnDeactivate(interactor: self)
    }

    // MARK: Promotion
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
                    let p = model.data?.data?.promotionPredicates.first
                    if p?.service == VatoServiceType.delivery.rawValue {
                        self?.presentDelivery()
                    } else {
                        self?.mutableBooking.updatePromotion(promotion: model)
                        self?.mutableBooking.changeMode(mode: .searchLocation(suggestMode: .destination1))
                    }
                },
                onError: { [weak self] (e) in
                    self?.router?.presentAlert(title: Text.notification.localizedText, message: "Không thể sử dụng mã khuyến mãi, vui lòng thử lại sau.", cancelAction: "Đóng")
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    func cancel(promotion: PromotionModel) {
        mutableAuthenticated.firebaseAuthToken
            .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .take(1)
            .flatMap { (authToken) -> Observable<(HTTPURLResponse, Data)> in
                guard let promotionToken = promotion.data?.data?.promotionToken else {
                    return Observable.empty()
                }
                return Requester.request(using: VatoAPIRouter.promotionCancel(authToken: authToken, promotionToken: promotionToken),
                                         method: .post, encoding: JSONEncoding.default)
            }
            .subscribe(
                onNext: { (response, _) in
                    if response.statusCode == 200 {
                        debugPrint("Success to cancel promotion token.")
                    } else {
                        debugPrint("Could not cancel promotion token: \(promotion.code).")
                    }
                },
                onError: { (err) in
                    printDebug(err)
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    func handleLookupManifestAction(with extra: String) {
        guard let manifestID = Int(extra) else {
            return
        }

        _ = mutableAuthenticated.firebaseAuthToken
            .take(1)
            .flatMap({ (token) -> Observable<(HTTPURLResponse, MessageDTO<PromotionList.Manifest>)> in
                return Requester.requestDTO(using: VatoAPIRouter.promotionDetail(authToken: token, promotionId: manifestID),
                                            method: .get,
                                            block: { $0.dateDecodingStrategy = .customDateFireBase })
            })
            .observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self](response) in
                self?.router?.routeToPromotionDetail(manifest: response.1.data)
            })
        
    }

    func handlePromotionNotification(with action: ManifestAction, extra: String) {
//        guard
//            let presentedController = router?.viewControllable.uiviewController.presentedViewController,
//            (presentedController is LatePaymentVC) == false
//        else {
//            return
//        }
        listener?.closeMenu()

        switch action {
        case .web:
            guard let url = URL(string: extra.trim()) else {
                return
            }
            WebVC.loadWeb(on: router?.viewControllable.uiviewController, url: url, title: "")

        case .manifest:
            handleLookupManifestAction(with: extra)
        default:
            break
        }
    }

    func reloadPromotionModel() {
        mutableBooking.reloadPromotion()
    }

    func promotionMoveBack() {
        router?.dismissCurrentRoute(completion: { [weak self] in
            // Check
            self?.moveHomeIfNeed()
        })
        UIApplication.setStatusBar(using: .default)
    }

    func update(model: PromotionModel?) {
        listener?.closeMenu()
        router?.dismissCurrentRoute(completion: nil)
        let promotionModel = model
        promotionModel?.promotionFrom = .menu
        mutableBooking.updatePromotion(promotion: promotionModel)
        // Check
        let p = model?.data?.data?.promotionPredicates.first
        if p?.service == VatoServiceType.delivery.rawValue {
            router?.routeToDelivery()
        } else {
            mutableBooking.changeMode(mode: .searchLocation(suggestMode: .destination1))
        }
        
    }

    // MARK: Promotion detail
    func dismissDetail() {
        router?.dismissCurrentRoute(completion: { [weak self] in
            self?.mutableDisplayPromotionNow.update(displayed: true)
            self?.moveHomeIfNeed()
        })
        UIApplication.setStatusBar(using: .default)
    }

    func requestDismissPromotionDetail(completion: @escaping () -> Void) {
        router?.dismissRoute(by: { (r) -> Bool in
            return r is PromotionDetailRouter
        }, completion: completion)
    }
    
    /// Class's private properties
    internal let mutableAuthenticated: MutableAuthenticatedStream
    internal let mutableBooking: MutableBookingStream
    private let firebaseDatabase: DatabaseReference
    private let googleAPIKey: String
    internal var disposeLocation: Disposable?
    private let mutableDisplayPromotionNow: MutableDisplayPromotionNowStream
    private lazy var disposeBag = DisposeBag()
    @VariableReplay var currentLocation: AddressProtocol?
}

// MARK: Class's private methods
private extension MapInteractor {
    private func setupRX() {
        self.fetchListData().bind { [weak self](list) in
            self?.paymentStream.update(source: list)
        }.disposeOnDeactivate(interactor: self)
        
        self.mutableBooking.booking.bind(onNext: weakify({ (b, wSelf) in
            wSelf.currentLocation = b.originAddress
        })).disposeOnDeactivate(interactor: self)

        mutableBooking.booking.map { $0.originAddress.coordinate }.bind(onNext: weakify({ (coord, wSelf) in
            PromotionManager.shared.checkPromotion(coordinate: coord)
        })).disposeOnDeactivate(interactor: self)
        
        mutableBooking.mode
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] step in
                guard let wSelf = self, let router = wSelf.router else {
                    return
                }
                switch step {
                case .bookingConfirm :
                    wSelf.beginConfirmBooking()
//                    router.routeToConfirmBooking()
                case .quickBookingConfirm:
                    wSelf.beginQuickBooking()
                case .editSearchLocation(let suggestMode):
                    wSelf.stopListenUpdateLocation.onNext(())
                    switch suggestMode {
                    case .origin:
                        wSelf.pickerLocation(type: .booking(origin: true, placeHolder: Text.pickupAddress.localizedText, icon: UIImage(named: "ic_origin"), fillInfo: true))
                    case .destination1:
                        wSelf.pickerLocation(type: .booking(origin: false, placeHolder: Text.whereDoYouGo.localizedText, icon: UIImage(named: "ic_destination"), fillInfo: true))
                    }
                case .searchLocation(let suggestMode):
                    wSelf.stopListenUpdateLocation.onNext(())
                    switch suggestMode {
                    case .origin:
                        wSelf.pickerLocation(type: .booking(origin: true, placeHolder: Text.pickupAddress.localizedText, icon: UIImage(named: "ic_origin"), fillInfo: true))
                    case .destination1:
                        wSelf.pickerLocation(type: .booking(origin: false, placeHolder: Text.whereDoYouGo.localizedText, icon: UIImage(named: "ic_destination"), fillInfo: false))
                    }
                    
                case .editQuickBookingSearchLocation:
                    wSelf.stopListenUpdateLocation.onNext(())
                    router.routeToSearchLocation()

                case .pickLocation(_), .editPickLocation(_), .editQuickBookingPickLocation:
                    router.routeToPickLocation()
                    
                case .homeMapSearch:
                    wSelf.stopListenUpdateLocation.onNext(())
                    router.routeToPickLocation()
                    
                default:
                    wSelf.mutableBooking.reset()
                    let nextService: VatoServiceType
                    if let data = wSelf.data, case .service(let s) = data {
                        nextService = s
                    } else {
                        nextService = .car
                    }
                    router.routeToHome(service: nextService)
                    if !wSelf.checked {
                        wSelf.moveToDefaultSelect()
                        wSelf.checked = true
                    }
                }
            }
            .disposeOnDeactivate(interactor: self)

        // Listen to promotion
        UserDefaults.standard.rx.observe([String:Any].self, "push_data")
            .filterNil()
            .flatMap { [weak self] (pushData) -> Observable<(BookingState, [String:Any])> in
                return self?.mutableBooking.mode.take(1).map { ($0, pushData) } ?? Observable.empty()
            }
            .distinctUntilChanged { (previous, pushData) -> Bool in
                let previousID = previous.1.value(for: "gcm.message_id", defaultValue: "")
                let pushDataID = pushData.1.value(for: "gcm.message_id", defaultValue: "")
                return previousID == pushDataID
            }
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (state, pushData) in
                guard
                    let aps = pushData["aps"] as? [String:Any],
                    let extra = aps["extra"] as? String,
                    let type = aps["type"] as? Int,
                    let action = ManifestAction(rawValue: type)
                else {
                    return
                }

                switch state {
                case .home:
                    self?.handlePromotionNotification(with: action, extra: extra)

                default:
                    break
                }
            }
            .disposeOnDeactivate(interactor: self)
        checkPromotion()
        // Load
        beginLoadLocation()
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification, object: nil).bind { [weak self](_) in
            self?.stopListenUpdateLocation.onNext(())
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func checkPromotion() {
        guard self.data == nil, UserDefaults.standard.value(forKey: "push_data") == nil else {
            return
        }
        
        Observable<(PromotionList.ManifestPredicate, PromotionList.Manifest)?>.combineLatest(mutableDisplayPromotionNow.allPredicates, mutableDisplayPromotionNow.allManifests) { (allPredicates, allManifests) -> (PromotionList.ManifestPredicate, PromotionList.Manifest)? in
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
                        
                        self?.promotionDetail(predicate: predicate, manifest: manifest)
                    } else {
                        // Reach maximum number of display per day
                    }
                } else {
                    userDefaults.setValue(predicate.startDate, forKey: "promotion_now_start_date")
                    userDefaults.setValue(predicate.endDate, forKey: "promotion_now_end_date")
                    userDefaults.setValue(1, forKey: "promotion_now_counter")
                    userDefaults.setValue(predicate.id, forKey: "promotion_now_id")
                    userDefaults.synchronize()
                    self?.promotionDetail(predicate: predicate, manifest: manifest)
                }
            }
            .disposeOnDeactivate(interactor: self)
    }
    
    
    private func promotionDetail(predicate: PromotionList.ManifestPredicate, manifest: PromotionList.Manifest) {
        mutableBooking.mode.filter { $0 == .home }.take(1).delay(0.3, scheduler: MainScheduler.asyncInstance).bind { [weak self](_) in
            self?.router?.routeToPromotionDetail(predecate: predicate, manifest: manifest)
        }.disposeOnDeactivate(interactor: self)
    }


    private func requestPromotionData(from code: String) -> Observable<PromotionData> {
        return mutableAuthenticated
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
    
    private func fetchListData() -> Observable<[PaymentCardDetail]> {
        let router = mutableAuthenticated.firebaseAuthToken.take(1).map { VatoAPIRouter.listCard(authToken: $0) }
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
                printDebug(e)
                return Observable.just([])
        }
    }
}

extension MapInteractor {
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
            wSelf.mutableBooking.updateBooking(originAddress: new)
            MapInteractor.Config.defaultMarker = MarkerHistory.init(with: new)
            wSelf.mutableBooking.changeMode(mode: .home)
        }))
    }
    
    private func requestAuthorizeLocation() {
        VatoLocationManager.shared.requestAlwaysAuthorization()
        VatoLocationManager.shared.rx.didChangeAuthorizationStatus.take(1).bind(onNext: weakify({ (_, wSelf) in
            wSelf.checkLocation()
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func findAddress() -> Observable<AddressProtocol> {
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
            return Observable.empty()
          }
        #endif
    }
    
    private func checkLocation() {
        #if targetEnvironment(simulator)
          self.router?.routeToSetLocation()
        #else
          // your real device code
          guard CLLocationManager.locationServicesEnabled() else {
            self.router?.routeToSetLocation()
            return
          }
        
          let status = CLLocationManager.authorizationStatus()
          switch status {
          case .authorizedAlways, .authorizedWhenInUse:
            findAddress().bind(onNext: weakify({ (new, wSelf) in
                wSelf.mutableBooking.updateBooking(originAddress: new)
                MapInteractor.Config.defaultMarker = MarkerHistory.init(with: new)
                wSelf.mutableBooking.changeMode(mode: .home)
            })).disposeOnDeactivate(interactor: self)
          case .denied, .restricted:
              // Track
              self.router?.routeToSetLocation()
          default:
              requestAuthorizeLocation()
          }
        #endif
    }
    
    func refeshLocation() {
        checkLocation()
    }
}
