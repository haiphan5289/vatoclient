//  File name   : VatoTaxiRouter.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import GoogleMaps
import RIBs
import RxSwift
import SnapKit
import Firebase
import Kingfisher
import FwiCoreRX

protocol VatoTaxiInteractable: Interactable, NoteListener, TransportServiceListener, TipListener, ConfirmBookingChangeMethodListener, ConfirmDetailListener, BookingConfirmPromotionListener, PromotionListener, PromotionDetailListener, BookingRequestListener, SwitchPaymentListener, ConfirmBookingServiceMoreListener, InTripListener, WalletListener {
    var router: VatoTaxiRouting? { get set }
    var listener: VatoTaxiListener? { get set }

    var currentMethod: PaymentMethod { get }
    var eMethod: Observable<PaymentCardDetail> { get }
    var profileStream: ProfileStream { get }
    var errorStream: ErrorBookingStream { get }
    var eApplyPromotion: Observable<Void> { get }
    var firebaseDatabase: DatabaseReference { get}
    var onlineDrivers: Observable<[SearchDriver]> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    func move(to type: BookingConfirmType)
    func update(payment method: PaymentCardDetail)
    func updateSelectFavorite(use: Bool)
    func update(routes: String)
    
    func editBooking(for marker: MarkerViewType)
    func cancelPromotion()
    func detachMe()
    func forceUseCash()
    func requestBookCancel(revert need: Bool)
    func tripCompleted()
    
    func checkCancelPromotion()
}

final class VatoTaxiRouter: Router<VatoTaxiInteractable>, VatoTaxiRouting, RibsAccessControllableProtocol, LoadingAnimateProtocol, DisposableProtocol {
    // todo: Constructor inject child builder protocols to allow building children.
    struct Config {
        struct NapasError {
            static let overMax = Text.payOverLimitNapas.localizedText
            static let onTouch = "Chuyến đi một chạm không hỗ trợ phương thức thanh toán qua Visa/MasterCard. Vui lòng chọn hình thức thanh toán khác"
        }
        
        struct Button {
            static let napas = Text.changePaymentMethod.localizedText
        }
    }
    
    var viewControllable: ViewControllable {
        return mViewController
    }
    var disposeBag: DisposeBag = DisposeBag()
    init(interactor: VatoTaxiInteractable,
         viewController: BookingConfirmViewControllable,
         noteController: NoteBuildable,
         mapView: GMSMapView,
         transportService: TransportServiceBuildable,
         tipBuilder: TipBuildable,
         changeMethod: ConfirmBookingChangeMethodBuilder,
         detailBuilder: ConfirmDetailBuilder,
         promotionBuilder: BookingConfirmPromotionBuildable,
         promotionListBuilder: PromotionBuilder,
         promotionDetailBuilder: PromotionDetailBuilder,
         bookingRequestBuilder: BookingRequestBuildable,
         switchPaymentBuilder: SwitchPaymentBuildable,
         confirmBookingServiceMoreBuilder: ConfirmBookingServiceMoreBuildable,
         inTripBuildable: InTripBuildable,
         walletBuildable: WalletBuildable)
    {
        self.mViewController = viewController
        self.noteController = noteController
        self.tipBuilder = tipBuilder
        self.mapView = mapView
        self.transportService = transportService
        self.changeMethod = changeMethod
        self.detailBuilder = detailBuilder
        self.promotionBuilder = promotionBuilder
        self.promotionListBuilder = promotionListBuilder
        self.promotionDetailBuilder = promotionDetailBuilder
        self.bookingRequestBuilder = bookingRequestBuilder
        self.switchPaymentBuilder = switchPaymentBuilder
        self.confirmBookingServiceMoreBuilder = confirmBookingServiceMoreBuilder
        self.inTripBuildable = inTripBuildable
        self.walletBuildable = walletBuildable
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        mapView.padding = .zero
        mapView.clear()

        UIView.animate(withDuration: 0.3, animations: {
            self.btnBack?.transform = CGAffineTransform(translationX: -300, y: 0)
            self.bookingConfirmView.transform = CGAffineTransform(translationX: 0, y: 500)
        }) { _ in
            self.btnBack?.removeFromSuperview()
            self.bookingConfirmView.removeFromSuperview()
        }
    }

    override func didLoad() {
        super.didLoad()
        setupDisplay()
        setupRX()
    }

    private func setupDisplay() {
        mapView.isMyLocationEnabled = false
        let bottom = mapView.edgeSafe.top
        let btnBack = UIButton(type: .custom) >>> mapView >>> {
            $0.setImage(#imageLiteral(resourceName: "ic_back_new"), for: .normal)
            $0.tintColor = UIColor.black
            $0.backgroundColor = .clear
            $0.snp.makeConstraints({ make in
                make.left.equalTo(0)
                make.top.equalTo(10 + bottom)
                make.size.equalTo(CGSize(width: 56, height: 44))
            })
        }
        
        _ = btnBack.rx.tap.bind { [weak self] in
            self?.interactor.checkCancelPromotion()
            self?.interactor.detachMe()
        }
        self.btnBack = btnBack
        addMainView()
    }

    func updateBookingUI(from fixedBook: Bool) {
        bookingConfirmView.isFixedBook = fixedBook
    }
    
    func updateDiscount() {
        bookingConfirmView.updatePromotionInfor()
    }

    private func reset() {
        mapView.clear()
        mapView.delegate = self.proxy
        mapView.setMinZoom(1, maxZoom: 20)

        let device = Device()
        let paddingTop: CGFloat
        switch device {
        case .iPhone5, .iPhone5c:
            paddingTop = 100
        default:
            paddingTop = 95
        }
        mapView.padding = UIEdgeInsets(top: paddingTop + mapView.edgeSafe.top, left: 16, bottom: 385, right: 40)
    }

    func drawMarker(from booking: Booking) {
        // remove first
        reset()
        
        self.booking = booking
        let marker1 = BookingConfirmMarker(from: booking.originAddress, type: .start)
        marker1.map = mapView
        marker1.tracksViewChanges = true
        self.maker1 = marker1
        // Draw destination marker 1
        if let destination = booking.destinationAddress1 {
            let marker2 = BookingConfirmMarker(from: destination, type: .end)
            marker2.map = mapView
            self.marker2 = marker2
        } else {
            updateMapViewCamera()
        }
    }

    func drawRoutes(using routes: String) {
        guard let path = GMSPath(fromEncodedPath: routes) else {
            return
        }
        
        self.interactor.update(routes: routes)

        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor.orange
        polyline.map = mapView
        
        defer {
            self.updateMapViewCamera()
        }
        
        guard let b = self.booking, let end = b.destinationAddress1?.coordinate else {
            return
        }
        
        let bounds = GMSCoordinateBounds(coordinate: b.originAddress.coordinate, coordinate: end)
        self.bounds = bounds
        
        CLLocationCoordinate2D.generateWayToCoordinate(from: path,
                                                       start: b.originAddress.coordinate,
                                                       end: end).bind
        { [weak self](item) in
            guard let wSelf = self else { return }
            
            func spans(from path: GMSPath) -> [GMSStyleSpan] {
                let styles = [GMSStrokeStyle.solidColor(.orange),
                GMSStrokeStyle.solidColor(.clear)]
                let lengths: [NSNumber] = [5, 5]
                let spans = GMSStyleSpans(path, styles, lengths, .rhumb)
                return spans
            }
            
            func createPolyline(from encodedPath: String) -> GMSPolyline? {
                guard let nPath = GMSPath(fromEncodedPath: encodedPath) else { return nil }
                let s = spans(from: nPath)
                let pl = GMSPolyline(path: nPath)
                pl.strokeWidth = 3
                pl.spans = s
                return pl
            }
            
            let polyline1 = createPolyline(from: item.p1)
            polyline1?.map = wSelf.mapView
            
            let polyline2 = createPolyline(from: item.p2)
            polyline2?.map = wSelf.mapView
            
        }.disposed(by: disposeBag)
    }

    func updateMapViewCamera() {
        defer {
            self.update(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reCheckPosition()
            }
        }

        if let booking = self.booking, booking.destinationAddress1 == nil {
            mapView.animate(with: GMSCameraUpdate.setTarget(booking.originAddress.coordinate))
        }

        guard let bounds = self.bounds else {
            return
        }
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    private func warningPromotion() -> Observable<PromotionCheckType> {
        return Observable.create({ [weak self](s) -> Disposable in
            let alertOK = AlertAction.init(style: .default, title: PromotionConfig.titleWarningReviewPromotion) {
                s.onNext(.review)
                s.onCompleted()
            }
            
            let alertCancel = AlertAction.init(style: .cancel, title: PromotionConfig.titleWarningOKPromotion) {
                s.onNext(.next)
                s.onCompleted()
            }
            
            AlertVC.show(on: self?.mViewController.uiviewController, title: PromotionConfig.titleWarningPromotion, message: PromotionConfig.titleWarningMessagePromotion, from: [alertOK, alertCancel], orderType: .vertical)
            return Disposables.create()
        })
        
    }
    
    func valid(promotion model: PromotionModel?) -> Observable<PromotionCheckType> {
        guard let model = model, !model.canApply else {
            return Observable.just(.next)
        }
        return self.warningPromotion()
    }

    private func reCheckPosition() {
        self.maker1?.reCheckPosition()
        self.marker2?.reCheckPosition()
    }

    func detactCurrentChild() {
        guard let currentRouting = currentRouting else {
            return
        }
        detachChild(currentRouting)
        mViewController.dismiss(viewController: currentRouting.viewControllable, completion: nil)
    }

    /// Using for update UI
    ///
    /// - Parameter type: type for update
    func update(from type: BookingConfirmUpdateType) {
        _ = Observable.just(type).do(onDispose: { [weak self] in
            self?.detactCurrentChild()
        }).observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] update in
            self?.bookingConfirmView.eUpdate.onNext(update)
        })
    }

    private func attach(route: ViewableRouting, using transition: TransitonType) {
        defer { self.currentRouting = route }
        self.attachChild(route)
        self.mViewController.present(viewController: route.viewControllable, transitionType: transition, completion: nil)
    }

    /// Class's private properties
    private var bounds: GMSCoordinateBounds?
    private lazy var proxy = Proxy()
    private var btnBack: UIButton?
    private let mapView: GMSMapView
    private let mViewController: BookingConfirmViewControllable
    private let noteController: NoteBuildable
    private let tipBuilder: TipBuildable
    private let transportService: TransportServiceBuildable
    private let changeMethod: ConfirmBookingChangeMethodBuilder
    private let detailBuilder: ConfirmDetailBuilder
    private let promotionBuilder: BookingConfirmPromotionBuildable
    private let promotionListBuilder: PromotionBuilder
    private let promotionDetailBuilder: PromotionDetailBuildable
    private let bookingRequestBuilder: BookingRequestBuildable
    private let switchPaymentBuilder: SwitchPaymentBuildable
    private let confirmBookingServiceMoreBuilder: ConfirmBookingServiceMoreBuildable
    private let inTripBuildable: InTripBuildable
    private let walletBuildable: WalletBuildable

    private (set) lazy var bookingConfirmView: BookingConfirmView = BookingConfirmView.loadXib()
    private weak var currentRouting: ViewableRouting?
    private var userInfor: UserInfo?
    private var maker1: BookingConfirmMarker?
    private var marker2: BookingConfirmMarker?
    private var booking: Booking?
    private (set) lazy var handlerIntrip: VatoTaxiHandlerIntrip = VatoTaxiHandlerIntrip()
    
    private var onlineDrivers: [SearchDriver] = []
    private var vehicleMarkers: [GMSMarker] = []
}

extension VatoTaxiRouter {
    private func addMainView() {
        let view = self.bookingConfirmView
        mViewController.bind(bookingConfirmView: view)
        view.layoutSubviews()
        reset()
    }

    private func setupRX() {
        guard let i = interactor as? Interactor else {
            return
        }
        self.bookingConfirmView.eUserInfor = self.interactor.profileStream.user
        self.bookingConfirmView.eAction
            .debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.instance).bind { [weak self] in
            self?.interactor.move(to: $0)
        }.disposeOnDeactivate(interactor: i)
        
        self.handlerIntrip.state
            .observeOn(MainScheduler.asyncInstance)
            .bind
        { [weak self](s) in
            guard let wSelf = self else { return }
            switch s {
            case .cancel:
                wSelf.interactor.requestBookCancel(revert: false)
            case .completed:
                wSelf.interactor.tripCompleted()
                wSelf.interactor.detachMe()
            case .clientCancel:
                wSelf.interactor.requestBookCancel(revert: false)
            case .newTrip:
                wSelf.interactor.detachMe()
            case .dismiss:
                break
            }
        }.disposeOnDeactivate(interactor: i)

        self.interactor.eMethod
            .map { BookingConfirmUpdateType.updateMethod(method: $0) }
            .bind(to: self.bookingConfirmView.eUpdate)
            .disposeOnDeactivate(interactor: i)

        self.proxy.locationSubject.bind { [weak self] coordinate in
            guard let wSelf = self, let booking = wSelf.booking else {
                return
            }

            let contain: Bool
            if let bounds = wSelf.bounds {
                contain = bounds.contains(coordinate)
            } else {
                let distance = booking.originAddress.coordinate.distance(to: coordinate)
                contain = !(distance > 100)
            }

            self?.update(contain)
        }.disposeOnDeactivate(interactor: i)

        self.proxy.eChangeAddress.bind { [weak self] type in
            guard let wSelf = self, let booking = wSelf.booking else {
                return
            }

            let canTap: Bool
            let p2 = wSelf.bookingConfirmView.tapPoint
            switch type {
            case .start:
                let p1 = wSelf.mapView.projection.point(for: booking.originAddress.coordinate)
                let v = wSelf.maker1?.iconView as? BookingConfirmMarkerView
                canTap = v?.canTap(at: p1, tap: p2) ?? false
            case .end:
                guard let last = booking.destinationAddress1?.coordinate else {
                    canTap = false
                    return
                }
                let p1 = wSelf.mapView.projection.point(for: last)
                let v = wSelf.marker2?.iconView as? BookingConfirmMarkerView
                canTap = v?.canTap(at: p1, tap: p2) ?? false
            }

            guard canTap else {
                return
            }
            self?.interactor.editBooking(for: type)
        }.disposeOnDeactivate(interactor: i)

        self.bookingConfirmView.eSelectedServiceFavorite.bind { [weak self] in
            self?.interactor.updateSelectFavorite(use: $0)
        }.disposeOnDeactivate(interactor: i)

        self.bookingConfirmView.eSelectedService.asObserver().subscribe(onNext: {[weak self] (s) in
            self?.interactor.updateSelect(service: s)
        }).disposeOnDeactivate(interactor: i)
        
        self.interactor.errorStream.eError.observeOn(MainScheduler.asyncInstance).bind { [weak self] e in
            self?.showAlert(from: e)
        }.disposeOnDeactivate(interactor: i)
        
        self.interactor.eApplyPromotion.observeOn(MainScheduler.asyncInstance).bind { [weak self] in
            self?.bookingConfirmView.showAlertPromotion(with: .success)
        }.disposeOnDeactivate(interactor: i)

        self.proxy.locationSubject.bind { [weak self] _ in
            self?.reCheckPosition()
        }.disposeOnDeactivate(interactor: i)
        
        interactor.onlineDrivers.observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] drivers in
                self?.onlineDrivers = drivers
                self?.addVehicleOnMap(with: drivers)
            }
            .disposeOnDeactivate(interactor: i)
        
        showLoading(use: interactor.eLoadingObser)

    }

    private func showAlert(from error: Error) {
        guard let promotionError = error as? PromotionError else {
            let alertOK = AlertAction(style: .default, title: "OK", handler: {})
            AlertVC.show(on: mViewController.uiviewController, title: "Lỗi", message: error.localizedDescription, from: [alertOK], orderType: .vertical)
            return
        }
        bookingConfirmView.showAlertPromotion(with: .fail(e: promotionError))
    }
    
    private func addVehicleOnMap(with drivers: [SearchDriver]) {
        for item in vehicleMarkers {
            item.map = nil
        }
        vehicleMarkers.removeAll()
        
        let zoom = round(mapView.camera.zoom)
        let ratio = CGFloat(zoom / mapView.maxZoom)
        let imageCache = ImageCache.default
        let format = "%@_%.2f"
        
        drivers.forEach {
            let imageKey = String(format: format, $0.service.mapImageName(), zoom)
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng))
            marker.tracksViewChanges = false
            marker.rotation = CLLocationDegrees(arc4random_uniform(359))
            marker.icon = imageCache.retrieveImageInMemoryCache(forKey: imageKey)
            if marker.icon == nil {
                let image = $0.service.mapIcon()?.scaleImage(toRatio: ratio)
                defer {
                    if let i = image {
                        imageCache.store(i, forKey: imageKey)
                    }
                }
                marker.icon = image
            }
            marker.map = self.mapView
            
            vehicleMarkers.append(marker)
        }
    }

    func update(_ isHidden: Bool) {
        self.bookingConfirmView.btnMoveBackToCurrent?.isHidden = isHidden
    }
}

// MARK: GMSMapViewDelegate's members
fileprivate class Proxy: NSObject, GMSMapViewDelegate {
    /// Class's public properties.
    fileprivate let locationSubject = ReplaySubject<CLLocationCoordinate2D>.create(bufferSize: 1)
    fileprivate let movingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    fileprivate lazy var eChangeAddress: PublishSubject<MarkerViewType> = PublishSubject()
    fileprivate lazy var ePointMarker: PublishSubject<CGPoint> = PublishSubject()

    fileprivate(set) var zoom: Float = 17

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
        movingSubject.on(.next(true))
    }

    fileprivate func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        defer { isAnimation = false }

        guard !isAnimation else {
            return
        }
        zoom = position.zoom
        movingSubject.on(.next(false))
        locationSubject.on(.next(position.target))
    }

    fileprivate func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let marker = marker as? BookingConfirmMarker {
            eChangeAddress.onNext(marker.type)
        }
        return false
    }

    /// Class's private properties.
    private var isAnimation: Bool
}

// MARK: Routing
extension VatoTaxiRouter {
    
    func routeToConfirmBookServiceMore(listService: [AdditionalServices], listCurrentSelectedService: [AdditionalServices])
    {
        detactCurrentChild()
        let route = confirmBookingServiceMoreBuilder.build(withListener: self.interactor, listService: listService, listCurrentSelectedService: listCurrentSelectedService)
        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
    }
    
    func routeToNote() {
        detactCurrentChild()
        let route = noteController.build(withListener: self.interactor, previousNote: "")
        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
    }
    
    func routeToWallet(vatoServiceType: VatoServiceType) {
        routeToSwitchMethod(vatoServiceType: vatoServiceType)
//        let storyBoard = UIStoryboard(name: "FCPaymentOptionViewController", bundle: nil)
//        guard let vc = FCPaymentOptionViewController.instantiate(from: storyBoard) else {
//            fatalError("Fatal load")
//        }
//        let navi = FacecarNavigationViewController(rootViewController: vc)
//        vc.oldSelect = { [weak self] in
//            self?.interactor.currentMethod ?? PaymentMethodCash
//        }
//
//        vc.callback = { [weak self] method in
//            self?.interactor.update(payment: method)
//        }
//        self.mViewController.uiviewController.present(navi, animated: true, completion: nil)
    }
    
//    func routeToServiceMore() {
//        detactCurrentChild()
//        let route = tipBuilder.build(withListener: self.interactor)
//        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
//    }
    
    func routeToTransport() {
        detactCurrentChild()
        let route = transportService.build(withListener: self.interactor)
        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
    }
    
    func routeToChooseMethod() {
        detactCurrentChild()
        let route = changeMethod.build(withListener: self.interactor)
        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
    }
    
    func routeToTopupWallet() {
        let model = FCHomeViewModel.getInstace()
        guard let controller = FCWalletViewController(view: model) else {
            return
        }
        let navigationController = FacecarNavigationViewController(rootViewController: controller)
        mViewController.uiviewController.present(navigationController, animated: true, completion: nil)
    }
    
    func routeToDetailPrice() {
        detactCurrentChild()
        let route = detailBuilder.build(withListener: self.interactor, service: .booking)
        self.attach(route: route, using: TransitonType.modal(type: .crossDissolve, presentStyle: .overCurrentContext))
    }
    
    func routeToPromotion(coordinate: CLLocationCoordinate2D?) {
        detactCurrentChild()
        let route = promotionListBuilder.build(withListener: self.interactor, type: .booking, coordinate: coordinate)
        //        let route = promotionBuilder.build(withListener: self.interactor)
        self.attach(route: route, using: TransitonType.modal(type: .coverVertical, presentStyle: .fullScreen))
    }
    
    func routeToDetailPromotion(with code: String, maifest: PromotionList.Manifest?) {
        detactCurrentChild()
        let alert = AlertAction.init(style: .default, title: PromotionConfig.detroyPromotion) { [weak self] in
            self?.interactor.cancelPromotion()
        }
        
        let route = promotionDetailBuilder.build(withListener: self.interactor, mode: .recheck(action: alert), manifest: maifest, code: code)
        self.attach(route: route, using: TransitonType.modal(type: .coverVertical, presentStyle: .fullScreen))
    }
    
    func routeToBookingRequest() {
        detactCurrentChild()
        let router = bookingRequestBuilder.build(withListener: self.interactor)
        let transition = TransitonType.modal(type: .crossDissolve, presentStyle: .currentContext)
        let segue = RibsRouting(use: router, transitionType: transition, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToSwitchMethod(vatoServiceType: VatoServiceType) {
        detactCurrentChild()
        let router = switchPaymentBuilder.build(withListener: interactor, switchPaymentType: .service(service: vatoServiceType))
        let transition = TransitonType.presentNavigation
        let segue = RibsRouting(use: router, transitionType: transition, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func checkPaymentError(from e: Error) {
        guard let e = e as? PaymentError else {
            return
        }
        let message: String
        switch e {
        case .napasExceedAllow(let defaultMoney):
            message = String(format: Config.NapasError.overMax, defaultMoney.currency)
        case .napsNotApplyOneTouch:
            message = Config.NapasError.onTouch
        default:
            message = ""
        }
        
        let actionOK = AlertAction.init(style: .default, title: Config.Button.napas) { [weak self] in
            self?.interactor.forceUseCash()
        }
        
        AlertVC.show(on: self.viewControllable.uiviewController, title: nil, message: message, from: [actionOK], orderType: .horizontal)
    }
    
    func presentMessage(message: String) {
        let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText, handler: {})
        AlertVC.show(on: self.viewControllable.uiviewController, title: Text.notification.localizedText, message: message, from: [actionOK], orderType: .horizontal)
    }
    
    func showAlertIntrip(tripId: String) {
        let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText) { [weak self] in
            self?.moveToIntrip(by: tripId)
        }
        
        AlertVC.show(on: self.viewControllable.uiviewController, title: Text.notification.localizedText, message: Text.messageHaveTrip.localizedText, from: [actionOK], orderType: .horizontal)
    }
    
    func routeToIntrip(tripId: String) {
        let route = inTripBuildable.build(withListener: interactor, tripId: tripId)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToAddCard() {
        let route = walletBuildable.build(withListener: interactor, source: .booking)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}
