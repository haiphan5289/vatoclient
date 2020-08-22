//  File name   : InTripVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import GoogleMaps
import AudioToolbox

protocol InTripPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var polyline: Observable<String> { get }
    var estimate: Observable<FirebaseTrip.Duration> { get }
    var driver: Observable<DriverInfo> { get }
    var driverCooordinate: Observable<CLLocationCoordinate2D> { get }
    var serviceId: Observable<Int> { get }
    var payment: Observable<InTripPayment> { get }
    var notifyNewChat: Observable<Int> { get }
    var allAddress: Observable<[String]> { get }
    var note: String? { get }
    var status: Observable<String> { get }
    var currentTrip: Observable<FirebaseTrip> { get }
    var wayPoints: Observable<[TripWayPoint]> { get }
    var tripId: String { get }
    var formatText: Observable<String> { get }
    
    func inTripCompleted()
    func inTripMoveBack()
    func inTripCancel()
    func inTripNewBook()
    func routeToChat()
    func routeToCancelTrip()
    func routeToShortcut()
}

final class InTripVC: FormViewController, InTripPresentable, InTripViewControllable {
    private struct Config {
        struct Section {
            static let tag = "Trip Info"
        }
        struct Header {
            static let minimize: CGFloat = 50
            static let maximize: CGFloat = 44 + (UIApplication.shared.keyWindow?.edgeSafe ?? .zero).top
        }
    }
    
    /// Class's public properties.
    weak var listener: InTripPresentableListener?
    private (set) lazy var mapView = GMSMapView()
    private lazy var disposeBag = DisposeBag()
    private var serviceId: Int = -1
    private var polyline: GMSPolyline?
    private var headerView :InTripHeaderView?
    private var addDestinationView: AddNewDestinationView?
    private var disposeVibrate: Disposable?
    private var showedAddDestination: Bool = false
    @Replay(queue: MainScheduler.asyncInstance) private var hContainer: CGFloat
    private lazy var mContainerView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .clear
        v.clipsToBounds = false
        return v
    }()
    private var disposeTrackTime: Disposable?
    private lazy var panGesture: UIPanGestureRecognizer = {
        let p = UIPanGestureRecognizer(target: nil, action: nil)
        p.delegate = self
        mContainerView.addGestureRecognizer(p)
        return p
    }()
    
    private lazy var driverMarker: GMSMarker = {
        let marker = GMSMarker()
        let viewMarker = generateMarker(style: .default)
        let image = self.loadImageTheme()
        viewMarker.iconMarkerDefaule?.image = image
        marker.iconView = viewMarker
        marker.map = mapView
        return marker
    }()
    
    private var startMarker: GMSMarker?
    private var endMarker: GMSMarker?
    private var btnCancel: UIButton?
    private var btnNewTrip: UIButton?
    @Replay(queue: MainScheduler.asyncInstance) private var mPath: GMSPath
    @Published private var timeRemainText: String?
    
    private var currentMarkersWayPoints: [GMSMarker]?
    private var containerLocation:UIView?
    private var diposeListenUpdateTitle: Disposable?
    private var currentDestination: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    private var showedFullInfo: Bool = false
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func generateMarker(style: FCMarkerStyle) -> FCMapMarker {
        let viewMarker = FCMapMarker()
        viewMarker.setMarkerStyle(style)
        return viewMarker
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        findServiceId()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissContainer()
    }

    /// Class's private properties.
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return nil
    }
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }
    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat { return 0.1 }
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
    
}
// MARK: -- Receipt Delegate
extension InTripVC: ReceiptVCDelegate {
    func dismissTrip() {
        listener?.inTripCompleted()
    }
}

// MARK: Cancel trip
private extension InTripVC {
    func cancelTrip() {
        listener?.routeToCancelTrip()
    }
}

// MARK: Gesture
extension InTripVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard let tableView = self.tableView else {
            return true
        }
        let shouldBegin = tableView.contentOffset.y <= -tableView.contentInset.top
        return shouldBegin
    }
}

// MARK: Handler Gesture
private extension InTripVC {
    func handler(gesture: UIPanGestureRecognizer) {
        let container = mContainerView
        defer { gesture.setTranslation(.zero, in: container) }
        let state = gesture.state
        switch state {
        case .began:
            self.addDestinationView?.isHidden = true
        case .changed:
            let translation = gesture.translation(in: container)
            let current = container.transform
            let next = current.ty + translation.y
            guard next > 0 else {
                container.transform = .identity
                return
            }
            container.transform = current.translatedBy(x: 0, y: translation.y)

        case .ended:
            let deltaY = container.transform.ty
            guard deltaY >= container.bounds.height / 3 else {
                return showContainer()
            }
            dismissContainer()
        default:
            break
        }
    }
    
    func showContainer() {
        mContainerView.transform = .identity
        self.headerView?.update(state: .max)
        defer {
            self.headerView?.snp.updateConstraints({ (make) in
                make.height.equalTo(Config.Header.maximize)
            })
        }
        if self.form.rowBy(tag: InTripCellType.addressInfo.rawValue) == nil {
            showAddress()
        }
        
        self.addDestinationView?.isHidden = true
    }
    
    func dismissContainer() {
        if showedAddDestination {
            self.addDestinationView?.isHidden = false
        }
        self.headerView?.update(state: .minmal)
        defer {
            self.headerView?.snp.updateConstraints({ (make) in
                make.height.equalTo(Config.Header.minimize)
            })
        }
        
        Show: if !showedFullInfo {
            showedFullInfo = true
        } else {
            let section = self.form.sectionBy(tag: Config.Section.tag)
            guard let row = self.form.rowBy(tag: InTripCellType.addressInfo.rawValue), let idx = section?.index(of: row) else {
                break Show
            }
            section?.remove(at: idx)
        }

        let date = Date()
        calculateDismiss().retry().bind(onNext: weakify({ (wSelf) in
            defer {
                let time = abs(date.timeIntervalSinceNow)
                LogEventHelper.log(key: "InTrip_client_compact_ios", params: ["time": time])
            }
            let r = wSelf.tableView.rectForFooter(inSection: 0)
            let n = wSelf.tableView.convert(r, to: wSelf.mContainerView)
            let y = UIScreen.main.bounds.height - n.minY - 80
            wSelf.hContainer = y
            UIView.animate(withDuration: 0.2) {
                wSelf.mContainerView.transform = CGAffineTransform(translationX: 0, y: y )
            }
        })).disposed(by: disposeBag)
    }
    
    private func calculateDismiss() -> Observable<Void> {
        let e = Observable<Int>.interval(.milliseconds(300), scheduler: MainScheduler.asyncInstance).take(1)
        return e.map { [unowned self](_) -> Void in
            guard self.tableView.numberOfSections == 0 else { return }
            throw NSError(use: "")
        }
    }
}

// MARK: View's event handlers
extension InTripVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension InTripVC {
    private func showPositionDriver() {
        listener?.driverCooordinate.take(1).bind(onNext: weakify({ (coord1, wSelf) in
            let bounds = GMSCoordinateBounds(coordinate: coord1, coordinate: wSelf.currentDestination)
            wSelf.mapView.animate(with: .fit(bounds, with: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)))
        })).disposed(by: disposeBag)
    }
    
    func drawPolyline(p: String) {
        removePolyline()
        guard let path = GMSPath(fromEncodedPath: p) else { return }
        let polyline = createPolyline(spans: [])
        polyline.path = path
        self.polyline = polyline
    }
}

// MARK: Class's private methods
private extension InTripVC {
    private func loadImageTheme() -> UIImage? {
        let name = "ic_car_marker_\(serviceId)"
        let result = ThemeManager.instance.loadPDFImage(name: name) ?? UIImage(named: "m-car-\(serviceId)-15")?.scaleImage(toRatio: 0.75)
        return result
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.clipsToBounds = true
        tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        mapView >>> view >>> {
            $0.settings.rotateGestures = false
            $0.padding = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
            $0.setMinZoom(7, maxZoom: 17.5)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        guard let resourceURL = MapResource.urlMapFile else {
            return
        }
        do {
            let style = try GMSMapStyle(contentsOfFileURL: resourceURL)
            mapView.mapStyle = style
        } catch {
            assert(false, error.localizedDescription)
        }
        mapView.animate(to: .init(latitude: 10.7664067, longitude: 106.6935349, zoom: 16))
        let headerView = InTripHeaderView.loadXib()
        self.headerView = headerView
        mContainerView >>> view >>> {
            $0.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
            $0.shadowOpacity = 1
            $0.shadowRadius = 5
            $0.shadowOffset = CGSize(width: -2, height: -2)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        headerView >>> mContainerView >>> {
            $0.update(state: .max)
            $0.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(Config.Header.maximize)
            }
        }
        
        let btnCancel = UIButton(frame: .zero)
        btnCancel.applyButton(style: .cancel)
        btnCancel.setTitle(Text.cancel.localizedText, for: .normal)
        self.btnCancel = btnCancel
        
        let btnNewTrip = UIButton(frame: .zero)
        btnNewTrip.applyButton(style: .default)
        btnNewTrip.setTitle(Text.inTripNewTrip.localizedText, for: .normal)
        self.btnNewTrip = btnNewTrip
        let v = UIView(frame: .zero)
        v >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
            }
        }
        let stackView = UIStackView(arrangedSubviews: [btnCancel, btnNewTrip])
        stackView >>> v >>> {
            $0.distribution = .fillEqually
            $0.spacing = 10
            $0.axis = .horizontal
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview().priority(.high)
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-20)
                make.height.equalTo(48)
            }
        }
        
        tableView >>> mContainerView >>> {
            $0.separatorColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4)
            $0.panGestureRecognizer.require(toFail: panGesture)
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(headerView.snp.bottom)
                make.bottom.equalTo(v.snp.top)
            }
        }
        let app = AppConfig.default.appInfor
        
        let lblVersion = UILabel(frame: .zero)
        lblVersion >>> view >>> {
            $0.textAlignment = .center
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.text = String.makeStringWithoutEmpty(from: app?.version, "\(UserManager.instance.userId ?? 0)", listener?.tripId, seperator: " | ")
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(16)
            }
        }
        
        mContainerView.transform = CGAffineTransform(translationX: 0, y: 10000)
        
        
        let addDestinationView = AddNewDestinationView(frame: .zero)
        addDestinationView.isHidden = true
        self.addDestinationView = addDestinationView
                
        let btnCurrentLocation = UIButton(frame: .zero)
        btnCurrentLocation >>> mapView >>> {
            $0.backgroundColor = .white
            $0.setImage(UIImage(named: "ic_current_location_new"), for: .normal)
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.snp.makeConstraints { make in
                make.top.equalTo(-1000)
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 32, height: 32))
            }
        }
        
        btnCurrentLocation.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.showPositionDriver()
        })).disposed(by: disposeBag)
        
        addDestinationView >>> mapView >>> {
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(72)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(btnCurrentLocation.snp.top).offset(-5)
            }
        }
        
        containerLocation = btnCurrentLocation
        addDestinationView.transform = CGAffineTransform(translationX: 1000, y: 0)
        
    }
    
    func findServiceId() {
        listener?.serviceId.take(1).bind(onNext: weakify({ (sId, wSelf) in
            wSelf.serviceId = sId
            UIView.animate(withDuration: 0.3) {
                wSelf.dismissContainer() //mContainerView.transform = .identity
            }
            wSelf.setupRX()
        })).disposed(by: disposeBag)
    }
    
    func removePolyline() {
        polyline?.map = nil
        polyline = nil
    }
    
    func createPolyline(spans: [GMSStyleSpan]) -> GMSPolyline {
        let polyline = GMSPolyline()
        polyline.strokeWidth = 2.5
        polyline.strokeColor = .orange
        polyline.map = self.mapView
        if !spans.isEmpty {
            polyline.spans = spans
        }
        
        return polyline
    }
    
    func animatePolyline(path: GMSPath) {
        let count = path.count()
        guard count > 0 else { return }
        mPath = path
        
        
//        let duration: UInt = 40
//        let subject = PublishSubject<Void>()
//        var idx: UInt = 0
//        Observable<Int>.interval(.milliseconds(Int(duration / count)), scheduler: MainScheduler.instance).takeUntil(subject).bind { (_) in
//            idx += 1
//            guard idx < count else {
//                return subject.onNext(())
//            }
//            let coordinate = path.coordinate(at: idx)
//            animationPath.add(coordinate)
//            polyline.path = animationPath
//        }.disposed(by: disposeBag)
        
        
        let bounds = GMSCoordinateBounds(path: path)
        self.mapView.animate(with: .fit(bounds))
    }
    
    func handlerMessage(row: RowDetailGeneric<InTripContactDriverCell>) {
        self.listener?.notifyNewChat.bind(onNext: { [weak row](number) in
            row?.value = number
        }).disposed(by: self.disposeBag)
    }
    
    func showAddress() {
        listener?.allAddress.take(1).bind(onNext: weakify({ (list, wSelf) in
            let section = wSelf.form.sectionBy(tag: Config.Section.tag)
            guard let row = wSelf.form.rowBy(tag: InTripCellType.driverInfo.rawValue)  else { return }
            let cell = RowDetailGeneric<InTripAddressCell>.init(InTripCellType.addressInfo.rawValue) { (row) in
                row.value = list
            }
            do {
               try section?.insert(row: cell, after: row)
            } catch {
                #if DEBUG
                   assert(false, "Fail!!!")
                #endif
            }
            
        })).disposed(by: self.disposeBag)
    }
    
    func setupDisplay(from info: DriverInfo, trip: FirebaseTrip) {
        let section = Section { (s) in
            s.tag = Config.Section.tag
        }
        
        section <<< RowDetailGeneric<InTripDriverInfoCell>.init(InTripCellType.driverInfo.rawValue) { (row) in
            row.value = info
            row.cell.view.updateBrandTaxi(name: trip.info.taxiBrandName)
        }
        
        section <<< RowDetailGeneric<InTripContactDriverCell>.init(InTripCellType.contactInfo.rawValue) { (row) in
            self.handlerMessage(row: row)
            row.cell.view.btnCall?.rx.tap.bind(onNext: weakify({ (wSelf) in
                let p = info.personal.phone
                guard let url: URL = URL(string: "tel://\(p)"), UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })).disposed(by: disposeBag)
            
            row.cell.view.btnMessage?.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.listener?.routeToChat()
            })).disposed(by: disposeBag)
        }
        
        if let note = listener?.note, !note.isEmpty {
            section <<< RowDetailGeneric<InTripNoteCell>.init(InTripCellType.noteDriver.rawValue) { (row) in
                row.value = note
            }
        }
        
        section <<< RowDetailGeneric<InTripPaymentCell>.init(InTripCellType.paymentInfo.rawValue) { (row) in
            handlerPayment(row: row)
        }
        
        defer {
            showAddress()
        }
        
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func handlerPayment(row: RowDetailGeneric<InTripPaymentCell>) {
        listener?.payment.bind(onNext: { [weak row](p) in
            row?.value = p
        }).disposed(by: disposeBag)
    }
}

// MARK: - Handler Event
private extension InTripVC {
    func registerUpdateMainTitle() {
        diposeListenUpdateTitle?.dispose()
        diposeListenUpdateTitle = listener?.formatText.flatMap({ [weak self](format) -> Observable<String> in
            guard let wSelf = self else { return Observable.empty() }
            return wSelf.$timeRemainText
                .filterNil()
                .map { String(format: format, Int($0) ?? 0) }
                .distinctUntilChanged()
        }).bind(onNext: weakify({ (text, wSelf) in
            wSelf.headerView?.lblMessage?.text = text
        }))
    }
    
    func setupRX() {
        mapView.rx.moving.bind(onNext: weakify({ (move, wSelf) in
            UIView.animate(withDuration: 0.3) {
                wSelf.addDestinationView?.transform = move ? CGAffineTransform(translationX: 1000, y: 0) : .identity
            }
        })).disposed(by: disposeBag)
        
        btnCancel?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.cancelTrip()
        })).disposed(by: disposeBag)
        
        btnNewTrip?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.inTripNewBook()
        })).disposed(by: disposeBag)
        
        panGesture.rx.event.bind(onNext: weakify({ (pan, wSelf) in
            wSelf.handler(gesture: pan)
        })).disposed(by: disposeBag)
        
        listener?.driverCooordinate.bind(onNext: weakify({ (coord, wSelf) in
            wSelf.driverMarker.updateMarker(from: coord)
        })).disposed(by: disposeBag)
        
        listener?.status.bind(onNext: weakify({ (s, wSelf) in
            wSelf.headerView?.lblMessage?.text = s
        })).disposed(by: disposeBag)
        
        listener?.polyline.bind(onNext: weakify({ (polyline, wSelf) in
            guard let p = GMSPath.init(fromEncodedPath: polyline) else { return }
            wSelf.animatePolyline(path: p)
        })).disposed(by: disposeBag)
        
        if let listener = listener {
            let eDriverInfo = listener.driver.take(1)
            let eCurrentTrip = listener.currentTrip.take(1)
            
            Observable.zip(eDriverInfo, eCurrentTrip) { return ($0, $1) }.bind(onNext: weakify({ (item, wSelf) in
                wSelf.setupDisplay(from: item.0, trip: item.1)
            })).disposed(by: disposeBag)
        }
        
        listener?.wayPoints.filter { !$0.isEmpty }.bind(onNext: weakify({ (list, wSelf) in
            wSelf.currentMarkersWayPoints?.forEach { $0.map = nil }
            let markers = list.map { p -> GMSMarker in
                let view = InTripMarkerWayPointView.loadXib()
                view.lblName?.text = p.address
                let m = GMSMarker()
                m.position = p.coordinate
                m.iconView = view
                m.map = wSelf.mapView
                return m
            }
            wSelf.currentMarkersWayPoints = markers
            
        })).disposed(by: disposeBag)
        
        addDestinationView?.guideView?.rx.controlEvent(.touchUpInside).bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToShortcut()
        })).disposed(by: disposeBag)
        
        $hContainer.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (height, wSelf) in
            wSelf.containerLocation?.snp.updateConstraints({ (make) in
                make.top.equalTo(height - 40)
            })
            
            wSelf.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: UIScreen.main.bounds.height - height, right: 0)
        })).disposed(by: disposeBag)
    }
}

// MARK: - Update UI
extension InTripVC {
    func updateUI(by type: InTripUIUpdateType) {
        switch type {
        case .vibrateDriverNearby:
            disposeVibrate = Observable<Int>.timer(.seconds(1), scheduler: MainScheduler.asyncInstance).take(5).bind(onNext: weakify({ (_, wSelf) in
                AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, nil)
            }))
        case .showTakeClientTime(let duration):
            self.btnNewTrip?.isHidden = true
            disposeVibrate?.dispose()
            self.endMarker?.map = nil
            self.endMarker = nil
            listener?.currentTrip.take(1).bind(onNext: weakify({ (trip, wSelf) in
                let marker = GMSMarker()
                let startCoord = trip.info.coordinateStart
                wSelf.currentDestination = startCoord
                let view = wSelf.generateMarker(style: .startInTrip)
                view.lblStartIntrip?.text = "\(Int(duration.duration / 60))"
                marker.iconView = view
                marker.position = startCoord
                marker.map = wSelf.mapView
                wSelf.endMarker = marker
                defer {
                    wSelf.showPositionDriver()
                }
                wSelf.registerUpdate(from: startCoord, duration: duration, label: view.lblStartIntrip, start: true)
            })).disposed(by: disposeBag)
            
        case .showInTripTime(let duration):
            self.btnCancel?.isHidden = true
            self.btnNewTrip?.isHidden = false
            self.endMarker?.map = nil
            self.endMarker = nil
            self.startMarker?.map = nil
            self.startMarker = nil
            self.timeRemainText = nil
        
            listener?.currentTrip.take(1).bind(onNext: weakify({ (trip, wSelf) in
                let startCoord = trip.info.coordinateStart
                let marker0 = GMSMarker()
                marker0.icon = UIImage(named: "marker-start")
                marker0.position = startCoord
                marker0.map = wSelf.mapView
                wSelf.startMarker = marker0
                
                let marker = GMSMarker()
                let endCoordinate = trip.info.coordinateEnd
                wSelf.currentDestination = endCoordinate
                let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 95)))
                containerView.backgroundColor = .clear
                let view = wSelf.generateMarker(style: .endInTrip)
                let new = Date().addingTimeInterval(Double(duration.duration))
                view.lblEndIntrip?.text = new.string(from: "HH:mm")
                view >>> containerView >>> {
                    $0.snp.makeConstraints { (make) in
                        make.centerX.equalToSuperview()
                        make.bottom.equalToSuperview()
                    }
                }
                marker.iconView = containerView
                marker.position = endCoordinate
                marker.map = wSelf.mapView
                wSelf.endMarker = marker
                defer {
                    wSelf.showPositionDriver()
                }
                wSelf.registerUpdate(from: endCoordinate, duration: duration, label: view.lblEndIntrip, start: false)
            })).disposed(by: disposeBag)
        case .alertTripRemove(let message):
            disposeTrackTime?.dispose()
            let alertOK = AlertAction(style: .default, title: Text.ok.localizedText) { [weak self] in
                self?.listener?.inTripCancel()
            }
            AlertVC.show(on: self, title: Text.notification.localizedText, message: message, from: [alertOK], orderType: .horizontal)
        case .showAlertBeginNewTrip(let message):
            disposeTrackTime?.dispose()
            let alertCancel = AlertAction(style: .cancel, title: Text.dismiss.localizedText) { [weak self] in
                self?.listener?.inTripCancel()
            }
            let alertNewTrip = AlertAction(style: .default, title: Text.reset.localizedText) { [weak self] in
                self?.listener?.inTripNewBook()
            }
            AlertVC.show(on: self, title: Text.notification.localizedText, message: message, from: [alertCancel, alertNewTrip], orderType: .horizontal)
        case .showReceipt:
            disposeTrackTime?.dispose()
            listener?.currentTrip.take(1).bind(onNext: weakify({ (trip, wSelf) in
                do {
                    let json = try trip.toJSON()
                    let booking = try FCBooking(dictionary: json)
                    let receipVC = ReceiptVC(nibName: "ReceiptVC", bundle: nil)
                    receipVC.setBookInfo(book: booking)
                    receipVC.delegate = wSelf
                    let navi = UINavigationController(rootViewController: receipVC)
                    navi.modalPresentationStyle = .fullScreen
                    wSelf.present(navi, animated: true, completion: nil)
                } catch {
                    assert(false, error.localizedDescription)
                }
            })).disposed(by: disposeBag)
        case .showAddNewDestination:
            showedAddDestination = true
            self.addDestinationView?.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.addDestinationView?.transform = .identity
            }
        default:
            fatalError("Please Implement")
        }
    }
    
    private func registerUpdate(from destination: CLLocationCoordinate2D, duration: FirebaseTrip.Duration, label: UILabel?, start: Bool) {
        disposeTrackTime?.dispose()
        registerUpdateMainTitle()
        guard let listener = self.listener else { return }
        let e1 = listener.driverCooordinate
        let e2 = $mPath.map { path -> (distance: Double, segments: Double) in
            let d = path.coordinate(at: 1).distance(to: destination)
            let distance = path.length(of: .geodesic)
            let segments = path.segments(forLength: distance, kind: .geodesic)
            
            return (d, segments)
        }
        
        disposeTrackTime = Observable.combineLatest(e1, e2) { (coordinate, values) -> Double in
            let current = coordinate.distance(to: destination)
            let p = abs(values.distance - current) / values.distance
            return p
        }.bind(onNext: weakify({ [weak label] (percent, wSelf) in
            let d = Double(duration.duration)
            let result = wSelf.calculateTimeRemain(percent: percent, duration: d, start: start)
            wSelf.timeRemainText = result
            label?.text = result
        }))
    }
    
    private func calculateTimeRemain(percent: Double, duration d: Double, start: Bool) -> String {
        let remain: Double
        if percent > 1 {
            remain = d + max(min(d - d * (percent - 1), d), 0)
        } else {
            remain = max(min(d - d * percent, d), 0)
        }
        
        if start {
            let r = remain / 60
            return String(format: "%.0f", r)
        } else {
            let new = Date().addingTimeInterval(remain)
            return new.string(from: "HH:mm")
        }
    }
}
