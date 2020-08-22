//  File name   : HomeRouter.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import GoogleMaps
import Kingfisher
import RIBs
import RxCocoa
import FwiCoreRX
import RxSwift
import SnapKit
import VatoNetwork


protocol HomeInteractable: Interactable, WalletListener, ReferralListener, LatePaymentListener, SetLocationListener {
    var eLoadingObser: Observable<(Bool, Double)> { get }
    
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }

    var originAddress: Observable<AddressProtocol> { get }
    var originLocation: Observable<CLLocationCoordinate2D> { get }

    var credit: Observable<Double> { get }
    var avatarURL: Observable<URL?> { get }
    var onlineDrivers: Observable<[SearchDriver]> { get }
    
    var favoritePlaces: Observable<[PlaceModel]> { get }

    func quickBooking()
    func searchOriginLocation()
    func searchDestinationLocation()
    func searchMap()

    func lookupCurrentAddress()
    func lookupAddress(for: CLLocationCoordinate2D)

    func presentMenu()
    func presentWallet()
    func presentDelivery()
    
    func resetLocation()
    
    func stopListenUpdateLocation()
    
    func updateLocation(place: AddressProtocol?, completion: @escaping (_ mode: LocationType) -> Void)
    var listLocationObservable: Observable<[AddressProtocol]>  { get }
    
    func pickerLocation(type: SearchType)
    func didSelectLocation(indexPath: IndexPath)
    var autheticate: AuthenticatedStream {get}
}

protocol HomeViewControllable: ViewControllable {
    func bind(menuButton: UIButton)
    func bind(homeWalletView: HomeWalletView)
    func bind(quickBookingButton: UIButton, homeView: DestinationPickerView)
    func bind(marker: UIImageView)
    func bind(headerView: VatoLocationHeaderView, contentView: UIView)
    
}

final class HomeRouter: Router<HomeInteractable>, HomeRouting, NetworkTrackingProtocol, Weakifiable {
    
    
    var viewControllable: ViewControllable {
        return viewController
    }
    var currentChild: Routing?
    var currentRoute: ViewableRouting?
    var nextService: VatoServiceType?
    /// Class's constructors
    init(interactor: HomeInteractable,
         viewController: HomeViewControllable,
         walletBuilder: WalletBuildable,
         referralBuildable: ReferralBuildable,
         latePaymentBuilder: LatePaymentBuildable,
         setLocationBuildable: SetLocationBuildable,
         mapView: GMSMapView)
    {
        self.viewController = viewController
        self.mapView = mapView
        self.walletBuilder = walletBuilder
        self.referralBuildable = referralBuildable
        self.latePaymentBuilder = latePaymentBuilder
        self.setLocationBuildable = setLocationBuildable
        super.init(interactor: interactor)
        interactor.router = self
    }

    // MARK: Class's public methods
    func cleanupViews() {
        homeWalletView?.walletButton.removeTarget(self, action: nil, for: .allEvents)
        menuButton.removeTarget(self, action: nil, for: .allEvents)
        quickBookingButton.removeTarget(self, action: nil, for: .allEvents)
        homeView?.locationButton.removeTarget(self, action: nil, for: .allEvents)
        homeView?.mapButton.removeTarget(self, action: nil, for: .allEvents)
        headerView?.backButton.removeTarget(self, action: nil, for: .allEvents)
        
        mapView.clear()
        mapView.delegate = nil
        mapView.isMyLocationEnabled = false
        mapView.padding = .zero
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = true

        menuButton.removeFromSuperview()
        homeWalletView?.removeFromSuperview()
        quickBookingButton.removeFromSuperview()
        currentLocationImageView.removeFromSuperview()
        homeView?.removeFromSuperview()
        headerView?.superview?.removeFromSuperview()
    }

    override func didLoad() {
        super.didLoad()

        // Listen to map view event
        if mapView.minZoom != 16 || mapView.maxZoom != 20 {
            mapView.setMinZoom(16, maxZoom: 20)
            let proxy = Proxy(with: true)
            mapView.delegate = proxy
            self.proxy = proxy
        } else {
            mapView.delegate = proxy
        }

        mapView.isMyLocationEnabled = true

        // Bind menu button
        viewController.bind(menuButton: menuButton)
        menuButton.addTarget(self, action: #selector(HomeRouter.handleMenuButtonOnPressed(_:)), for: .touchUpInside)

        // Load home wallet view
        if let homeWalletView = Bundle.main.loadNibNamed("\(HomeWalletView.self)", owner: nil, options: nil)?.first as? HomeWalletView {
            viewController.bind(homeWalletView: homeWalletView)
            homeWalletView.walletButton.addTarget(self, action: #selector(HomeRouter.handleWalletButtonOnPressed(_:)), for: .touchUpInside)
            self.homeWalletView = homeWalletView
        }

        // Load home view
        guard let homeView = Bundle.main.loadNibNamed("\(DestinationPickerView.self)", owner: nil, options: nil)?.first as? DestinationPickerView else {
            return
        }
        
        let nib = UINib(nibName: "SearchLocationNewCell", bundle: nil)
        homeView.locationTableView.register(nib, forCellReuseIdentifier: SearchLocationNewCell.identifier)
        homeView.locationTableView.backgroundColor = .white
        homeView.locationTableView.tableFooterView = UIView()
        homeView.locationTableView.estimatedRowHeight = 100
        homeView.locationTableView.rowHeight = UITableView.automaticDimension
        
        homeView.locationButton.addTarget(self, action: #selector(HomeRouter.handleDestinationLocationButtonOnPressed(_:)), for: .touchUpInside)
        homeView.mapButton.addTarget(self, action: #selector(HomeRouter.handleCurrentLocationButtonOnPressed(_:)), for: .touchUpInside)
        
        quickBookingButton.addTarget(self, action: #selector(HomeRouter.handleQuickBookingButtonOnPressed(_:)), for: .touchUpInside)

        viewController.bind(quickBookingButton: quickBookingButton, homeView: homeView)
        self.homeView = homeView

        // Register cell
        homeView.suggestionCollectionView.register(HomeSuggestionCVC.self, forCellWithReuseIdentifier: HomeSuggestionCVC.identifier)
        
        // Load headerView
        
        let headerView = VatoLocationHeaderView.loadXib()
        let headerConentView = UIView(frame: .zero)
        headerConentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        self.headerConentView = headerConentView
        self.headerView = headerView
        
        viewController.bind(headerView: headerView, contentView: headerConentView)
        
        headerView.backButton.addTarget(self, action: #selector(HomeRouter.handleMenuButtonOnPressed(_:)), for: .touchUpInside)
        
        
        // Bind current location image view
        viewController.bind(marker: currentLocationImageView)

        // Binding event
        setupRX()
    }
    
    func showWallet() {
        let router = walletBuilder.build(withListener: self.interactor, source: .home)
        let transition = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func dismissWallet() {
        self.dismissCurrentRoute(completion: nil)
    }
    
    func showReferral() {
        let router = referralBuildable.build(withListener: self.interactor)
        let transition = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func dismissReferal() {
        self.dismissCurrentRoute(completion: nil)
    }
    
    func moveToDelivery() {
        self.interactor.presentDelivery()
    }
    
    func routeToSetLocation() {
        let route = setLocationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }

    func presentLocationUnidentifiedAlert() {
        let cancelAction = AlertAction(style: .cancel, title: Text.later.localizedText, handler: {})
        let acceptAction = AlertAction(style: .default, title: Text.settings.localizedText, handler: {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) else {
                return
            }
            UIApplication.shared.openURL(settingsURL)
        })

        AlertVC.show(on: viewController.uiviewController,
                     title: Text.turnOnLocationFeature.localizedText,
                     message: Text.turnOnLocationFeatureDescription.localizedText,
                     from: [cancelAction, acceptAction],
                     orderType: .horizontal)
    }

    func presentLatePayment(with debtInfo: UserDebtDTO) {
        let router = latePaymentBuilder.build(withListener: interactor, debtInfo: debtInfo)
        let transition = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: transition, completion: nil)
    }

    @objc func handleMenuButtonOnPressed(_ sender: Any) {
        interactor.presentMenu()
    }

    @objc func handleWalletButtonOnPressed(_ sender: Any) {
        networkTracking?
            .reachable
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isNetworkAvailable) in
                guard let wSelf = self else {
                    return
                }

                if isNetworkAvailable {
                    wSelf.interactor.presentWallet()
                } else {
                    AlertVC.presentNetworkDown(for: wSelf.viewController)
                }
            })
            .disposed(by: disposeBag)
    }

    @objc func handleQuickBookingButtonOnPressed(_ sender: Any) {
        networkTracking?
            .reachable
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isNetworkAvailable) in
                guard let wSelf = self else {
                    return
                }

                if isNetworkAvailable {
                    wSelf.interactor.quickBooking()
                } else {
                    AlertVC.presentNetworkDown(for: wSelf.viewController)
                }
            })
            .disposed(by: disposeBag)
    }

    @objc func handleCurrentLocationButtonOnPressed(_ sender: Any) {
        self.interactor.stopListenUpdateLocation()
        networkTracking?
            .reachable
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isNetworkAvailable) in
                guard let wSelf = self else {
                    return
                }

                if isNetworkAvailable {
                    if let coordinate = VatoLocationManager.shared.location?.coordinate {
                        wSelf.interactor.lookupCurrentAddress()
                        wSelf.mapView.animate(toLocation: coordinate)
                    }
                } else {
                    AlertVC.presentNetworkDown(for: wSelf.viewController)
                }
            })
            .disposed(by: disposeBag)
    }

    @objc func handleDestinationLocationButtonOnPressed(_ sender: Any) {
        interactor.searchDestinationLocation()
    }

    @objc func handleOriginLocationButtonOnPressed(_ sender: Any) {
        interactor.searchOriginLocation()
    }

    func update(from coordinate: CLLocationCoordinate2D) {
        let zoom = self.proxy.zoom

        let update = GMSCameraUpdate.setTarget(coordinate, zoom: zoom)
        self.mapView.animate(with: update)

        self.hideCurrentLocationButton(coordinate: coordinate)
    }

    /// Class's private properties
    private let viewController: HomeViewControllable
    private let walletBuilder: WalletBuildable
    private let referralBuildable: ReferralBuildable
    private let latePaymentBuilder: LatePaymentBuildable
    private let mapView: GMSMapView

    internal let disposeBag = DisposeBag()

    private (set)var homeView: DestinationPickerView?
    private (set)var headerView: VatoLocationHeaderView?
    private (set)var headerConentView: UIView?
    private var homeWalletView: HomeWalletView?
    private lazy var currentLocationImageView = UIImageView(image: #imageLiteral(resourceName: "ic_origin_marker"))
    private let setLocationBuildable: SetLocationBuildable
    
    private var presenting: Bool {
       return self.viewController.uiviewController.parent?.presentingViewController != nil
    }

    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "ic_default_avatar"), for: .normal)
        return button
    }()

    private lazy var quickBookingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "ic_upstairs_off"), for: .normal)
        button.isEnabled = false
        button.isHidden = true
        return button
    }()

    private var proxy = Proxy()
    private lazy var suggestionVM = HomeSuggestionVM(with: self.homeView?.suggestionCollectionView)
    private var places: [PlaceModel] = []
}

extension HomeRouter: LoadingAnimateProtocol, DisposableProtocol {}

// MARK: Class's private methods
private extension HomeRouter {
    private func setupRX() {
        guard let i = interactable as? Interactor else {
            return
        }
        
        showLoading(use: interactor.eLoadingObser)


        if let headerView = headerView {
            interactor.originAddress
                .observeOn(MainScheduler.asyncInstance)
                .bind(onNext: { [weak headerView](adr) in
                    headerView?.setupDisplay(item: adr)
                })
                .disposeOnDeactivate(interactor: i)
            
            headerView.mapButton.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.interactor.searchMap()
            })).disposeOnDeactivate(interactor: i)
            
            headerView.btnSearchAddress?.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.interactor.searchOriginLocation()
            })).disposeOnDeactivate(interactor: i)
        }

        interactor.originLocation.observeOn(MainScheduler.asyncInstance)
        .take(1)
        .subscribe(onNext: { [weak self]  in
            self?.update(from: $0)
        }).disposeOnDeactivate(interactor: i)
        interactor.originLocation.observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] coordinate in
                self?.hideCurrentLocationButton(coordinate: coordinate)
            })
            .disposeOnDeactivate(interactor: i)
        
        
        if !presenting {
            interactor.avatarURL
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] url in
                    self?.menuButton.kf.setImage(with: url, for: .normal, placeholder: #imageLiteral(resourceName: "ic_default_avatar"), options: nil, progressBlock: nil)
                })
                .disposeOnDeactivate(interactor: i)
        } else {
            homeWalletView?.isHidden = true
        }
        
        
        interactor.credit.observeOn(MainScheduler.asyncInstance)
            .map { $0 > 0 ? $0.currency : "VATOPay" }
            .bind { [weak self] text in
                self?.homeWalletView?.creditLabel.text = text
            }
            .disposeOnDeactivate(interactor: i)

        interactor.onlineDrivers.observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] drivers in
                guard let mapView = self?.mapView else {
                    return
                }
                mapView.clear()

                let zoom = round(mapView.camera.zoom)
                let ratio: CGFloat = 0.65//CGFloat(zoom / mapView.maxZoom)
                
                let imageCache = ImageCache.default
                let format = "%@_%.2f"

                let currentS = self?.nextService
                var icon: UIImage?
                drivers.forEach {
                    let imgMap = (currentS ?? $0.service).mapImageName()
                    let imageKey = String(format: format, imgMap, zoom)
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng))
                    marker.tracksViewChanges = false
                    marker.rotation = CLLocationDegrees(arc4random_uniform(359))
                    marker.icon = imageCache.retrieveImageInMemoryCache(forKey: imageKey)
                    if icon == nil {
                        let image: UIImage?
                        if let img = imageCache.retrieveImageInMemoryCache(forKey: imageKey) {
                            image = img
                        } else {
                            let new = (currentS ?? $0.service).mapIcon()?.scaleImage(toRatio: ratio)
                            defer {
                                if let i = new {
                                    imageCache.store(i, forKey: imageKey)
                                }
                            }
                            image = new
                        }
                        
                        icon = image
                        marker.icon = icon
                    } else {
                       marker.icon = icon
                    }
                    marker.map = self?.mapView
                }
            }
            .disposeOnDeactivate(interactor: i)

        proxy.movingSubject
            .map { (isMoving) -> String in
                return "\(Text.search.localizedText)..."
            }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] text in
                // Moving -> Stop listen
                guard let wSelf = self else { return }
                wSelf.interactor.stopListenUpdateLocation()
            })
            .disposeOnDeactivate(interactor: i)

        proxy.locationSubject
            .subscribe(onNext: { [weak self] location in
                guard let location = location else {
                    self?.interactor.resetLocation()
                    return
                }
                self?.lookupAddress(for: location)
            })
            .disposeOnDeactivate(interactor: i)

        // Listen to app did become active notification
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .flatMap { [weak self] (_) -> Observable<CLLocationCoordinate2D> in
                return self?.interactor.originLocation ?? Observable.empty()
            }
            .bind { [weak self] coordinate in
//                var coord: CLLocationCoordinate2D?
//                self?.interactor.originLocation.subscribe(onNext: { coord = $0 }).dispose()

//                guard let coordinate = coord else {
//                    return
//                }
                self?.hideCurrentLocationButton(coordinate: coordinate)
            }
            .disposeOnDeactivate(interactor: i)
        
        NotificationCenter.default.rx.notification(Notification.Name("moveToBookingView"))
            .bind { [weak self] notification in
                guard let item = notification.object as? PlaceModel, let lat = item.lat, let lon = item.lon else { return }
                let result: AddressProtocol
                if let raw = item.raw {
                    result = raw
                } else {
                    let location = MapModel.Location(lat: Double(lat) ?? 0, lon: Double(lon) ?? 0)
                    let place = MapModel.Place(name: item.address ?? "", address: item.address, location: location, placeId: "\(item.id ?? 0)", isFavorite: true)
                    result = MarkerHistory(with: place).address
                }
                self?.interactor.updateLocation(place: result, completion: { (_) in })
            }
            .disposeOnDeactivate(interactor: i)
    
        //bind value for collectionview
        interactor.favoritePlaces.observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] places in
                self?.places = places
                self?.suggestionVM.update(newItems: places)
            })
            .disposeOnDeactivate(interactor: i)
        
        self.homeView?.suggestionCollectionView.rx.itemSelected.bind(onNext: { [weak self](idx) in
            guard let wSelf = self else { return }
            guard let item = wSelf.places[safe: idx.item] else { return }
            if item.typeId == .AddNew {
                let viewController = FavoritePlaceViewController()
                viewController.authenicate = self?.interactor.autheticate
                viewController.viewModel.isFromFavorite = true
                let navigation = FacecarNavigationViewController(rootViewController: viewController)
                self?.viewController.uiviewController.present(navigation, animated: true, completion: nil)
                viewController.didSelectModel = { model in
                    NotificationCenter.default.post(name: Notification.Name("moveToBookingView"), object: model)
                }
                return
            }
            
            guard let lat = item.lat, let lon = item.lon else {
                return
            }
            
            let result: AddressProtocol
            if let raw = item.raw {
                result = raw
            } else {
                let location = MapModel.Location(lat: Double(lat) ?? 0, lon: Double(lon) ?? 0)
                let place = MapModel.Place(name: item.address ?? "", address: item.address, location: location, placeId: nil, isFavorite: true)
                result = MarkerHistory(with: place).address
            }
            self?.interactor.updateLocation(place: result, completion: { (_) in })
            
        }).disposeOnDeactivate(interactor: i)
        
        if let homeView = homeView {
            interactor.listLocationObservable.bind {[weak self] (list) in
                self?.homeView?.updateEmptyView(isEmpty: list.isEmpty)
            }.disposeOnDeactivate(interactor: i)
            
            interactor.listLocationObservable.bind(to: homeView.locationTableView.rx.items(cellIdentifier: SearchLocationNewCell.identifier, cellType: SearchLocationNewCell.self)) {(row, element, cell) in
                cell.updateData(model: element, typeLocationPicker: .full)
                if row == 0 {
                    cell.backgroundColor = UIColor(red: 0, green: 97/255, blue: 61/255, alpha: 0.1)
                } else {
                    cell.backgroundColor = .white
                }
                
            }.disposeOnDeactivate(interactor: i)
            
            homeView.locationTableView.rx.itemSelected.bind {[weak self](indexPath) in
                self?.interactor.didSelectLocation(indexPath: indexPath)
            }.disposeOnDeactivate(interactor: i)
            
            proxy.stateEvent
                .distinctUntilChanged()
                .observeOn(MainScheduler.asyncInstance)
                .bind { [weak self] (state) in
                self?.homeView?.updateHeight(state: state)
            }.disposeOnDeactivate(interactor: i)
            
            
//            homeView.updatedHeight.distinctUntilChanged().observeOn(MainScheduler.instance).bind {[weak self] (height) in
//                guard let me = self else { return }
//                var padding = me.mapView.padding
//                padding = UIEdgeInsets(top: padding.top, left: padding.left, bottom: height - 48, right: padding.right)
//                UIView.animate(withDuration: 0.2, animations: {
//                    me.mapView.padding = padding
//                })
//            }.disposeOnDeactivate(interactor: i)
        }
        
        
        
        
        // Setup view model
        suggestionVM.setupRX()
    }

    private func lookupAddress(for coordinate: CLLocationCoordinate2D) {
        networkTracking?
            .reachable
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isNetworkAvailable) in
                guard let wSelf = self else {
                    return
                }

                if isNetworkAvailable {
                    wSelf.interactor.lookupAddress(for: coordinate)
                } else {
                    AlertVC.presentNetworkDown(for: wSelf.viewController)
                }
            })
            .disposed(by: disposeBag)
    }

    private func hideCurrentLocationButton(coordinate: CLLocationCoordinate2D) {
        guard let currentLocation = VatoLocationManager.shared.location else {
            return
        }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = location.distance(from: currentLocation)

        if distance > 50.0 {
//            homeView?.currentLocationButton.isHidden = false
//            homeView?.currentLocationButton.alpha = 1.0
        } else {
//            homeView?.currentLocationButton.alpha = 0.0
//            homeView?.currentLocationButton.isHidden = true
        }
    }
}

// MARK: GMSMapViewDelegate's members
enum MapState: Int {
    case idle
    case moving
}

fileprivate class Proxy: NSObject, GMSMapViewDelegate {
    class ProxyLocationUpdate {
        var start: CLLocationCoordinate2D?
        var end: CLLocationCoordinate2D?
        
        func prepareUpdate() {
            let oldEnd = end
            start = oldEnd
        }
        
        func next(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D? {
            // Update first
            end = coordinate
            guard start != end else {
                return nil
            }
            return coordinate
        }
    }
    
    /// Class's public properties.
    lazy var stateEvent = BehaviorRelay<MapState>(value: .idle)
    
    private let _locationSubject = ReplaySubject<CLLocationCoordinate2D?>.create(bufferSize: 1)
    fileprivate var locationSubject: Observable<CLLocationCoordinate2D?> {
        return _locationSubject.asObserver()
    }
    fileprivate let movingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private lazy var proxyUpdate: ProxyLocationUpdate = ProxyLocationUpdate()
    private var needZoom: Bool = true
    fileprivate(set) var zoom: Float = 16

    /// Class's constructors
    fileprivate init(with animation: Bool = false) {
        isAnimation = animation
        super.init()
    }

    fileprivate func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        defer { isAnimation = !gesture }

        guard gesture else {
            return
        }
        stateEvent.accept(.moving)
        movingSubject.on(.next(true))
        proxyUpdate.prepareUpdate()
    }

    fileprivate func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        defer { isAnimation = false }
        stateEvent.accept(.idle)
        guard !isAnimation else {
            return
        }
        zoom = position.zoom
        let coord = position.target
        movingSubject.on(.next(false))
        // Validate
        let next = proxyUpdate.next(coordinate: coord)
        _locationSubject.on(.next(next))
        
//        guard needZoom && zoom < 16 else {
//            return
//        }
//        needZoom = false
//        mapView.animate(to: GMSCameraPosition.camera(withLatitude: coord.latitude, longitude: coord.longitude, zoom: 16))
    }

    /// Class's private properties.
    private var isAnimation: Bool
}
