//  File name   : HomeInteractor.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Alamofire
import CoreLocation
import FirebaseDatabase
import RealmSwift
import RIBs
import RxSwift
import VatoNetwork
import FwiCoreRX

let defautDistanceDriver = 500.0 //default distance to compare   request driver
let defautTimeDriver = 60.0 //default time to compare for request driver
let minDistanceRequest: CGFloat = 10 //min distance for request driver
let minDurationRequest: CGFloat = 5 //min time for request driver

protocol HomeRouting: Routing, RibsAccessControllableProtocol {
    var homeView: DestinationPickerView? { get }
    var nextService: VatoServiceType? { get set }
    func cleanupViews()
    func showWallet()
    func showReferral()
    func dismissReferal()
    func dismissWallet()
    func presentLocationUnidentifiedAlert()
    func update(from coordinate: CLLocationCoordinate2D)
    func presentLatePayment(with debtInfo: UserDebtDTO)
}

protocol HomeListener: class, MapLocationProtocol {
    func requestDismissPromotionDetail(completion: @escaping () -> Void)

    func beginMenu()
    func beginWallet()
    func presentDelivery()
    func beginConfirmBooking()
    func getBalance()
    func pickerLocation(type: SearchType)
}

final class HomeInteractor: Interactor, HomeInteractable, ActivityTrackingProgressProtocol, LocationRequestProtocol, Weakifiable {
    func showTopUp() {
        
    }
    
    var autheticate: AuthenticatedStream {
        return self.authenticated
    }
    

    weak var router: HomeRouting?
    weak var listener: HomeListener?

    var token: Observable<String> {
        return authenticated.firebaseAuthToken.take(1)
    }
    
    
    var originAddress: Observable<AddressProtocol> {
        return mutableBooking.booking.map { $0.originAddress }
    }

    var originLocation: Observable<CLLocationCoordinate2D> {
        return mutableBooking.booking.map { $0.originAddress }.map { $0.coordinate }
    }

    var credit: Observable<Double> {
        return profile.user.map { $0.cash }
    }

    var avatarURL: Observable<URL?> {
        return profile.user.map { URL(string: $0.avatarUrl ?? "") }
    }

    var onlineDrivers: Observable<[SearchDriver]> {
        return mutableBooking.onlineDrivers
    }
    
    var favoritePlaces: Observable<[PlaceModel]> {
        return favoritePlacesSubject.asObservable()
    }
    
    /// Class's constructor
    init(authenticated: AuthenticatedStream,
         profile: ProfileStream,
         mutableBooking: MutableBookingStream,
         firebaseDatabase: DatabaseReference,
         googleAPIKey: String,
         mutablePaymentStream: MutablePaymentStream)
    {
        self.authenticated = authenticated
        self.profile = profile
        self.mutableBooking = mutableBooking
        self.firebaseDatabase = firebaseDatabase
        self.mutablePaymentStream = mutablePaymentStream
        self.googleAPIKey = googleAPIKey
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()

//        bookingStream.reset()
        // Check if it exists a location

        let current = VatoLocationManager.shared.location?.coordinate ?? MapInteractor.Config.defaultMarker.address.coordinate
        router?.update(from: current)
    }
    
    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()

        // todo: Pause any business logic.
    }

    func stopListenUpdateLocation() {
        self.listener?.stopListenUpdateLocation.onNext(())
    }
    
    func getBalance() {
        listener?.getBalance()
    }
    
    func presentDelivery() {
        listener?.presentDelivery()
    }
    
    func quickBooking() {
        var booking: Booking?
        mutableBooking.booking.subscribe(onNext: { booking = $0 }).dispose()

        guard booking != nil else {
            router?.presentLocationUnidentifiedAlert()
            return
        }
        mutableBooking.changeMode(mode: .quickBookingConfirm)
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
            wSelf.mutableBooking.updateBooking(originAddress: new)
            MapInteractor.Config.defaultMarker = MarkerHistory.init(with: new)
        }))
    }

    func searchOriginLocation() {
        mutableBooking.changeMode(mode: .searchLocation(suggestMode: .origin))
    }
    
    func refeshLocation() {}

    func searchDestinationLocation() {
        var booking: Booking?
        mutableBooking.booking.subscribe(onNext: { booking = $0 }).dispose()

        if booking == nil {
            mutableBooking.changeMode(mode: .searchLocation(suggestMode: .origin))
        } else {
            mutableBooking.changeMode(mode: .searchLocation(suggestMode: .destination1))
        }
    }

    func lookupCurrentAddress() {
        guard let currentLocation = VatoLocationManager.shared.location else {
            return
        }
        address(for: currentLocation.coordinate, d: PlacesHistoryManager.Configs.defaultRadius)
    }
    
    private func address(for location: CLLocationCoordinate2D, d: Double = PlacesHistoryManager.Configs.minDistance) {
        searchDisposable?.dispose()
        searchDisposable = self.lookupAddress(for: location, maxDistanceHistory: d, isOrigin: true)
            .subscribe(onNext: { [weak self] (result) in
                self?.mutableBooking.updateBooking(originAddress: result)
            })
    }
    
    func resetLocation() {
        mutableBooking.reset()
    }

    func lookupAddress(for location: CLLocationCoordinate2D) {
        print("!!!!!lookupAddress")
        address(for: location)
    }
    
    func searchMap() {
        mutableBooking.changeMode(mode: .homeMapSearch(suggestMode: .origin))
    }

    func presentMenu() {
        listener?.beginMenu()
    }

    func presentWallet() {
//        listener?.beginWallet()
        router?.showWallet()
    }
    
    func presentReferral() {
        router?.showReferral()
    }
    
    func referralMoveback() {
        router?.dismissReferal()
    }

    func requestToDismissLatePaymentModule() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func updateLocation(place: AddressProtocol?, completion: @escaping (LocationType) -> Void) {
        guard let location = place else {
            return
        }
        
        let updateBooking: (AddressProtocol) -> () = { [weak self] address in
            self?.mutableBooking.updateBooking(destinationAddress1: address)
            self?.listener?.beginConfirmBooking()
        }
        
        if let p = location.placeId, !p.isEmpty {
            updateBooking(location)
        } else {
            self.lookupAddress(for: location.coordinate, maxDistanceHistory: PlacesHistoryManager.Configs.minDistance, isOrigin: false)
                .bind(onNext: updateBooking)
                .disposeOnDeactivate(interactor: self)
        }
    }
    
    func requestFavoritePlace() {
        let event = PlacesHistoryManager.instance
            .favoritePlaces
            .map { $0.filter ({ $0.isOrigin == false }).map(PlaceModel.init(address:)) }
        let listFavObserver = event.map { list -> [PlaceModel] in
            let modelAddNew = PlaceModel(id: nil, name: Text.favoriteSaved.localizedText, address: nil, typeId: .AddNew, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime)
            return [modelAddNew] + list
        }
        let originAddress = mutableBooking.booking.map({ $0.originAddress })
        getLatestLocations().bind { [weak self](list) in
            self?.listLocationSubject.onNext(list)
        }.disposeOnDeactivate(interactor: self)
        
        Observable.combineLatest(originAddress, listFavObserver).bind {[weak self] (o, listFavourite) in
            guard let me = self else { return }
            
            let fileteredListFavourite = listFavourite.filter({ (p) -> Bool in
                if p.typeId == .AddNew {
                    return true
                }
                return !(abs(p.coordinate.distance(to: o.coordinate)) < 55)
            })
            
            
            me.favoritePlacesSubject.on(.next(fileteredListFavourite))
            
        }.disposeOnDeactivate(interactor: self)
    }

    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
    
    /// Class's private properties
    private let firebaseDatabase: DatabaseReference
    private let googleAPIKey: String
    
    private let profile: ProfileStream
    private let authenticated: AuthenticatedStream
    private let mutableBooking: MutableBookingStream
    private let mutablePaymentStream: MutablePaymentStream

    private var searchDisposable: Disposable?
    private var onlineWaitingDisposable: Disposable?
    private var onlineDriversDisposable: Disposable?
    
    private let favoritePlacesSubject = ReplaySubject<[PlaceModel]>.create(bufferSize: 1)
    
    private var timerGetListDriverOnline: SafeTimer?
    
    private let listLocationSubject = ReplaySubject<[AddressProtocol]>.create(bufferSize: 1)

    
    func updateUserBalance(cash: Double, coin: Double) {}
    
    
    var listLocationObservable: Observable<[AddressProtocol]>  {
        return listLocationSubject.asObservable()
    }
    
    func didSelectLocation(indexPath: IndexPath) {
        listLocationSubject
            .take(1)
            .subscribe(onNext: {[weak self] (listData) in
                guard let item = listData[safe: indexPath.row] else {
                    return
                }
                
                self?.updateLocation(place: item, completion: { (_) in })
            }).disposeOnDeactivate(interactor: self)
    }
    
    func pickerLocation(type: SearchType) {
        listener?.pickerLocation(type: type)
    }

    deinit {
        timerGetListDriverOnline?.invalidate()
        timerGetListDriverOnline = nil
    }
}

// MARK: Class's private methods
private extension HomeInteractor {
    private func setupRX() {
        /* // move to VatoMain
         mutablePaymentStream.isCheckedLatePayment
         .bind { [weak self] (isChecked) in
         guard !isChecked else {
         return
         }
         self?.checkUserDebt()
         }
         .disposeOnDeactivate(interactor: self)
         */
//        mutableBooking.booking.map { $0.originAddress.coordinate }.bind { [weak self](location) in
//            self?.router?.update(from: location)
//        }.disposeOnDeactivate(interactor: self)
        
        var defautDistance = defautDistanceDriver
        if let appConfigure = FirebaseHelper.shareInstance()?.appConfigure,
            appConfigure.request_driver_config != nil,
            let distance = appConfigure.request_driver_config?.distance,
            distance > minDistanceRequest {
            defautDistance = Double(distance)
        }
        
        mutableBooking.booking
            .map { $0.originAddress.coordinate }
            .distinctUntilChanged { $0.distance(to: $1) <= defautDistance }
            .subscribe(onNext: { [weak self] coordinate in
                self?.requestOnlineDrivers(coordinate: coordinate)
            })
            .disposeOnDeactivate(interactor: self)
        
        var defautTime = defautTimeDriver
        if let appConfigure = FirebaseHelper.shareInstance()?.appConfigure,
            appConfigure.request_driver_config != nil,
            let time = appConfigure.request_driver_config?.duration,
            time > minDurationRequest {
            defautTime = Double(time)
        }
        
        timerGetListDriverOnline = SafeTimer()
        timerGetListDriverOnline?.schedule(timeInterval: defautTime, repeats: true, userInfo: nil)
        timerGetListDriverOnline?.delegate = self
        
       
        
        // Listen to update favorite places
        
        //insert first item in favorite places
        let favoritePlaces = [PlaceModel(id: nil, name: Text.favoriteSaved.localizedText, address: nil, typeId: .AddNew, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime)]
        favoritePlacesSubject.on(.next(favoritePlaces))
        requestFavoritePlace()
    }
    
    private func requestOnlineDrivers(coordinate: CLLocationCoordinate2D) {
        onlineWaitingDisposable?.dispose()
        onlineWaitingDisposable = nil
        let currentId = self.router?.nextService
        onlineWaitingDisposable = authenticated.firebaseAuthToken
            .take(1)
            .subscribe(onNext: { [weak self] (authToken) in
                self?.onlineDriversDisposable?.dispose()
                self?.onlineDriversDisposable = nil

                self?.onlineDriversDisposable = self?.findZone(from: coordinate)
                    .flatMap {
                        return self?.findServices(by: $0) ?? Observable.empty()
                    }
                    .map { $0.first(where: { service in service.choose == true }) }
                    .filterNil()
                    .flatMap { (service) -> Observable<(HTTPURLResponse, Message<[SearchDriver]>)> in
                        let id = currentId?.rawValue ?? service.id
                        return Requester.requestDTO(using: VatoAPIRouter.searchDriver(authToken: authToken, coordinate: coordinate, service: id),
                                                    method: .post,
                                                    encoding: JSONEncoding.default)
                    }
                    .timeout(30.0, scheduler: SerialDispatchQueueScheduler(qos: .background))
                    .subscribe(onNext: { (_, message) in
                        self?.mutableBooking.updateBooking(onlineDrivers: message.data)
                    })
            })
    }

    private func findZone(from coordinate: CLLocationCoordinate2D) -> Observable<Zone> {
        return self.firebaseDatabase.findZone(with: coordinate).take(1)
    }

    private func findServices(by zone: Zone) -> Observable<[Service]> {
        return self.firebaseDatabase.findServices(by: zone.id).flatMap { [weak self] (s) -> Observable<[Service]> in
            guard s.count > 0 else {
                if let wSelf = self {
                    return wSelf.firebaseDatabase.findServices(by: ZoneConstant.vn)
                }
                return Observable.empty()
            }
            return Observable.just(s)
        }
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
                guard message.data.amount > 0 else {
                    return
                }
                self?.listener?.requestDismissPromotionDetail(completion: {
                    self?.router?.presentLatePayment(with: message.data)
                })
                self?.mutablePaymentStream.updateCheckLatePayment(status: true)
                
            }, onError: { (err) in
                // Ignore error, wait for next time present home module.
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    struct ItemHistoryCompare: Hashable, Comparable {
        var distance: Double
        var numberCount: Int
        var item: AddressProtocol
        
        init(model: AddressProtocol) {
            distance = model.distance ?? Double.infinity
            numberCount = model.counter
            item = model
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(distance)
            hasher.combine(numberCount)
        }
        
        static func ==(lhs: ItemHistoryCompare, rhs: ItemHistoryCompare) -> Bool {
            return abs(lhs.distance - rhs.distance) <= 30
        }
        
        static func <(lhs: ItemHistoryCompare, rhs: ItemHistoryCompare) -> Bool {
            if abs(lhs.distance - rhs.distance) <= 30 {
                return lhs.numberCount > rhs.numberCount
            } else {
                return lhs.distance < rhs.distance
            }
        }
    }
    
    private static func filter(originAddress: AddressProtocol,
                               listLatestLocation: [AddressProtocol],
                               listMostUsedLocation: [AddressProtocol]) -> [AddressProtocol] {
        
        func refilterDistance(list: [AddressProtocol], maxItem: Int) -> [AddressProtocol] {
            var result = [AddressProtocol]()
            var idx: Int = 0
            while result.count < maxItem && idx < list.count {
                defer {
                    idx += 1
                }
                
                guard let item = list[safe: idx] else { continue }
                let d = abs(item.coordinate.distance(to: originAddress.coordinate))
                guard let idx = result.firstIndex (where: { (i) -> Bool in
                    let d1 = abs(i.coordinate.distance(to: originAddress.coordinate))
                    let delta = abs(d - d1)
                    return delta <= 30
                }) else {
                    result.append(item)
                    continue
                }
                let old = result[idx]
                guard old.counter < item.counter else {
                    continue
                }
                
                result.remove(at: idx)
                result.append(item)
            }
            
            return result
        }
        
        guard var latestLocation = listLatestLocation
            .first(where: { abs($0.coordinate.distance(to: originAddress.coordinate)) > 200 } ) else {
            
             let r = listMostUsedLocation
                .map({ (address) -> AddressProtocol in
                    var newAddress = address
                    newAddress.distance = address.coordinate.distance(to: originAddress.coordinate)
                    return newAddress
                })
                .filter({ $0.counter > 0 && $0.distance ?? Double.infinity > 200  })
                return refilterDistance(list: r, maxItem: 4)
        }

        var tempArray = listMostUsedLocation
            .map({ (address) -> AddressProtocol in
                var newAddress = address
                newAddress.distance = abs(address.coordinate.distance(to: originAddress.coordinate))
                return newAddress
            })
            .filter({
                $0.coordinate != latestLocation.coordinate &&
                $0.counter > 0 &&
                $0.distance ?? Double.infinity > 200
            })
        
        tempArray = refilterDistance(list: tempArray, maxItem: 3)

        latestLocation.distance = abs(latestLocation.coordinate.distance(to: originAddress.coordinate))
        let result = [latestLocation] + Array(tempArray)
        
        return result
    }
    
    
    private func getLatestLocations() -> Observable<[AddressProtocol]> {
        let originAddress = mutableBooking.booking.map({ $0.originAddress })
        // History
        let listLatestLocation = PlacesHistoryManager.instance.searchListLastest(isOrigin: false)
        let listMostUsedLocation = PlacesHistoryManager.instance.searchCounter(isOrigin: false)
        
        return Observable.combineLatest(originAddress, listLatestLocation, listMostUsedLocation).map { (originAddress, listLatestLocation, listMostUsedLocation) -> [AddressProtocol] in
            return HomeInteractor.filter(originAddress: originAddress, listLatestLocation: listLatestLocation, listMostUsedLocation: listMostUsedLocation)
        }
    }
}

extension HomeInteractor {
    func wallet(handle action: WalletAction) {
        switch action {
        case .moveBack:
            router?.dismissWallet()
        }
    }
    
}

extension HomeInteractor: SafeTimerDelegate {
    func safeTimerDidTrigger(_ safeTimer: SafeTimer) {
        mutableBooking.booking
            .take(1)
            .subscribe(onNext: {[weak self] (booking) in
                self?.requestOnlineDrivers(coordinate: booking.originAddress.coordinate)
            }).disposeOnDeactivate(interactor: self)
    }
}
