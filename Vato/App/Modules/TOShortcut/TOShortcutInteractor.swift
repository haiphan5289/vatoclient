//  File name   : TOShortcutInteractor.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork
import Alamofire

protocol TOShortcutRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToWalletListHistory()
    func routeToHistory()
    func routeToQuickSupport()
    func routeToMerchant()
    func routeToSOS()
    func routeToReferral()
    func routeToWebMerchant(token: String)
    func routeToSetLocation()
}

protocol TOShortcutPresentable: Presentable {
    var listener: TOShortcutPresentableListener? { get set }
    
    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TOShortcutListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func routeToShortcutItem(item: TOShortutModel)
    func shortcutDismiss()
    func shortcutRouteToFood()
    func routeToAddDestinationConfirm()
    func inTripNewBook()
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?, removeCurrent: Bool)
}

final class TOShortcutInteractor: PresentableInteractor<TOShortcutPresentable> {
    /// Class's public properties.
    weak var router: TOShortcutRouting?
    weak var listener: TOShortcutListener?
    let type: TOShortcutType
    /// Class's constructor.
    init(presenter: TOShortcutPresentable, authenticated: AuthenticatedStream, type: TOShortcutType, mutableBookingStream: MutableBookingStream) {
        self.mutableBookingStream = mutableBookingStream
        self.authenticated = authenticated
        self.type = type
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    
    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
        //        self.initDummyData()
    }
    
    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    /// Class's private properties.
    private let authenticated: AuthenticatedStream
    @Published private var mDataSource: [TOShortutModel]
    @VariableReplay var currentLocation: AddressProtocol?
    let mutableBookingStream: MutableBookingStream
    
}

// MARK: TOShortcutInteractable's members
extension TOShortcutInteractor: TOShortcutInteractable {
    func setLocationMoveBack(_ address: AddressProtocol?) {
        router?.dismissCurrentRoute(completion: weakify({ (wSelf) in
            guard let new = address else { return }
            wSelf.mutableBookingStream.updateBooking(originAddress: new)
            MapInteractor.Config.defaultMarker = MarkerHistory.init(with: new)
            wSelf.currentLocation = new
        }))
    }
    
    func inTripNewBook() {
        listener?.inTripNewBook()
    }
    
    private func checkLocation() -> Observable<Void> {
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
    
    private func requestAuthorizeLocation() -> Observable<Void> {
        VatoLocationManager.shared.requestAlwaysAuthorization()
        return VatoLocationManager.shared.rx.didChangeAuthorizationStatus.take(1).flatMap { [weak self](_) -> Observable<Void> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.checkLocation()
        }
    }
    
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?) {
        checkLocation().bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToServiceCategory(type: type, action: action, removeCurrent: true)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func historyMoveHome() {
        self.listener?.shortcutDismiss()
    }
    
    func referralMoveback() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func merchantMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func quickSupportMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func routeToFood() {
        router?.dismissCurrentRoute(completion: {[weak self] in
            self?.listener?.shortcutRouteToFood()
        })
    }
    
    func historyDismiss() {
        router?.dismissCurrentRoute(completion: nil)
    }
    
    func listDetailMoveBack() {
        router?.dismissCurrentRoute(completion: nil)
        
    }
    
    func TONearbyDriverBack() {
        router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: TOShortcutPresentableListener's members
extension TOShortcutInteractor: TOShortcutPresentableListener, ActivityTrackingProgressProtocol, Weakifiable {
    func shortcutDismiss() {
        self.listener?.shortcutDismiss()
    }
    
    func routeToReport() {}
    
    func routeToItem(item: TOShortutModel) {
        switch item.type {
        case .paymentHistory:
            router?.routeToWalletListHistory()
        case .history:
            router?.routeToHistory()
        case .quickSupport:
            router?.routeToQuickSupport()
        case .merchant:
            UIApplication
                .openApp(name: "Vato Merchant", scheme: "vatomerchant", id: "1509390675")
                .subscribe(onCompleted: {
                #if DEBUG
                   print("Completed open app action")
                #endif
            }).disposeOnDeactivate(interactor: self)
        case .sos:
            router?.routeToSOS()
        case .inviteFriend:
            router?.routeToReferral()
        default:
            self.listener?.routeToShortcutItem(item: item)
            
        }
    }
    
    private func routeToWebMerchant() {
        FirebaseTokenHelper.instance.eToken.filterNil().take(1).bind(onNext: weakify({ (token, wSelf) in
            wSelf.router?.routeToWebMerchant(token: token)
        })).disposeOnDeactivate(interactor: self)
    }
    
    private func requestListMerchant(p: PagingEcom) -> Observable<OptionalMessageDTO<MerchantResponsePaging<Merchant>>> {
        guard let userId = UserManager.instance.userId else {
            return Observable.empty()
        }
        let params = p.params
        let router = VatoFoodApi.listMerchant(authToken: "", ownerId: userId, isFull: true, params: params)
        let provider = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return provider.request(using: router, decodeTo: OptionalMessageDTO<MerchantResponsePaging<Merchant>>.self).map { try $0.get() }
    }
    
    
    var dataSource: Observable<[TOShortutModel]> {
        return $mDataSource
    }
    
    func requestData() {
        let fName = type.fileName
        let driverNearbyUrl = Bundle.main.url(forResource: fName, withExtension: "")
        
        let mockupRequest = MockupManagerRequest.init(0) { (url, method, parameter, encoding, header) -> NetworkResponse in
            return NetworkResponse(response: nil, data: try Data.init(contentsOf: driverNearbyUrl!))
        }
        let networkRequester = NetworkRequester(provider: mockupRequest)
        
        networkRequester.request(using:VatoFoodApi.getListSaleOrder(authenToken: "", params: nil), decodeTo: OptionalMessageDTO<[TOShortutModel]>.self, method: .get, encoding: JSONEncoding.default, block: nil).bind {[weak self] (result) in
            guard let me = self else { return }
            switch result {
            case .success(let r):
                me.mDataSource = r.data ?? []
            case .failure(let e):
                printDebug(e)
            }
        }.disposeOnDeactivate(interactor: self)
    }
    
    func routeToNearbyDriver() {
        
    }
}

// MARK: Class's private methods
private extension TOShortcutInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
        mutableBookingStream.booking.bind(onNext: weakify({ (b, wSelf) in
            wSelf.currentLocation = b.originAddress
        })).disposeOnDeactivate(interactor: self)
    }
}
