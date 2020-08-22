//  File name   : StoreTrackingVC.swift
//
//  Author      : khoi tran
//  Created date: 12/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import SnapKit
import Eureka
import FwiCore
import RxSwift
import FwiCoreRX
import GoogleMaps
import AudioToolbox

enum StoreTrackingShowingType: Int {
    case none
    case full
    case compact
    
    var hHeader: CGFloat {
        switch self {
        case .full:
            return 87 + (UIApplication.shared.keyWindow?.edgeSafe ?? .zero).top
        default:
            return 78
        }
    }
}

protocol StoreTrackingPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var order: Observable<SalesOrder> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var errorObserable: Observable<MerchantState>{ get }
    var driver: Observable<DriverInfo> { get }
    var driverCooordinate: Observable<CLLocationCoordinate2D> { get }
    var notifyNewChat: Observable<Int> { get }
    var serviceId: Observable<Int> { get }
    var currentTrip: Observable<FirebaseTrip> { get }
    var polyline: Observable<String> { get }
    var shopDetail: Observable<FoodExploreItem> { get }
    
    func storeTrackingMoveBack()
    func refresh()
    func createNewOrder()
    func cancelOrder()
    func routeToChat()
    func showReceipt()
}

final class StoreTrackingVC: FormViewController, StoreTrackingPresentable, StoreTrackingViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        static let AddressCell = "AddressCell"
        static let DeliveryTime = "DeliveryTime"
        static let Note = "Note"
        static let OrderCell = "OrderCell"
    }
    
    /// Class's public properties.
    weak var listener: StoreTrackingPresentableListener?
    
    private lazy var mContainer: UIView = UIView(frame: .zero)
    private (set) lazy var mapView = GMSMapView()
    lazy var panGesture: UIPanGestureRecognizer? = {
       let p = UIPanGestureRecognizer(target: nil, action: nil)
       self.headerView.addGestureRecognizer(p)
       return p
    }()
    
    private lazy var driverMarker: GMSMarker = {
        let marker = GMSMarker()
        let image = self.loadImageTheme()
        marker.icon = image
        marker.map = mapView
        return marker
    }()
    
    internal lazy var disposeBag = DisposeBag()
    private lazy var headerView = TrackingHeaderView.init(frame: .zero)
    private lazy var backButton = UIButton(frame: .zero)
    
    private lazy var bottomStackView = UIStackView(frame: .zero)
    private lazy var cancelOrderButton = UIButton(type: .system)
    private lazy var newOrderButton = UIButton(frame: .zero)
    @Replay(queue: MainScheduler.asyncInstance) private var mOrder: SalesOrder
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    private lazy var animateViews: [UIView] = []
    
    private var startMarker: GMSMarker?
    private var endMarker: GMSMarker?
    private var polyline: GMSPolyline?
    private var serviceId: Int = -1
    private var showing: StoreTrackingShowingType = .none
    private var disposeZoomDriver: Disposable?
    @Replay(queue: MainScheduler.asyncInstance) private var minHContainer: CGFloat
    private lazy var btnCurrentLocation = UIButton(frame: .zero)
    
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        let w = UIScreen.main.bounds.width / 2
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: w, bottom: 0, right: w)
        self.tableView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.setStatusBar(using: .default)
        localize()
    }
    
    /// Class's private properties.
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
    
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return UIView.create{ $0.backgroundColor = .clear } }
    override func tableView(_: UITableView, heightForHeaderInSection s: Int) -> CGFloat { return s > 0 ? 10 : 0.1 }
}

// MARK: View's event handlers
extension StoreTrackingVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
private extension StoreTrackingVC {
    func loadImageTheme() -> UIImage? {
        let name = "ic_car_marker_\(serviceId)"
        let result = ThemeManager.instance.loadPDFImage(name: name) ?? (UIImage(named: "m-car-\(serviceId)-15") ?? UIImage(named: "m-car-16-15"))?.scaleImage(toRatio: 0.75)
        return result
    }
}

// MARK: Class's private methods
private extension StoreTrackingVC {
    private func localize() {
        // todo: Localize view's here.
    }
    // MARK: -- Map
    func setupMapView() {
        mapView >>> view >>> {
            $0.settings.rotateGestures = false
            $0.padding = UIEdgeInsets(top: 0, left: 0, bottom: 355, right: 0)
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
    }
    
    // MARK: -- Wave view
    func addWaveView() {
        let wView = WaveView.init(frame: .zero)
        let s = CGSize(width: 250, height: 250)
        let visiable = view.bounds.height - 300
        let top = (visiable - s.height) / 2
        wView >>> mapView >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(s)
                make.centerX.equalToSuperview()
                make.top.equalTo(top)
            })
        }
        animateViews.append(wView)
        let image = UIImage(named: "ic_origin_marker")
        let imgView = UIImageView(image: image)
        imgView >>> mapView >>> {
            $0.snp.makeConstraints({ (make) in
                make.centerX.equalTo(wView.snp.centerX).priority(.high)
                make.centerY.equalTo(wView.snp.centerY).offset(-(image?.size.height ?? 4) / 3).priority(.high)
            })
        }
        imgView.transform = CGAffineTransform(translationX: 0, y: -5)
        animateViews.append(imgView)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .autoreverse, .repeat], animations: { [weak imgView] in
            imgView?.transform = .identity
        }, completion: nil)
    }
        
    // MARK: -- Visualize view
    private func visualize() {
        // todo: Visualize view's here.
    
        self.view.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        // Map
        setupMapView()
        backButton >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.top.equalTo(44)
                make.width.equalTo(56)
                make.height.equalTo(44)
            })
            $0.setTitle("", for: .normal)
            $0.setImage(UIImage(named: "ic_food_menu_back"), for: .normal)
        }
        
        // Container
        mContainer >>> view >>> {
            $0.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        bottomStackView >>> mContainer >>> {
            $0.distribution = .fillEqually
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 17
            $0.backgroundColor = .clear
            $0.snp.makeConstraints({ (make) in
                make.height.equalTo(48)
                make.bottom.equalTo(-16)
                make.left.equalTo(16)
                make.right.equalTo(-16)
            })
        }
        
        cancelOrderButton = UIButton.create {
            $0.isHidden = true
            $0.setBackground(using: .white, state: .normal)
            $0.borderColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
            $0.cornerRadius = 24
            $0.borderWidth = 1
            $0.setTitleColor(#colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), for: .normal)
            $0.setTitle("Hủy đơn", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(48)
            }
        }
        
        newOrderButton = UIButton.create {
            $0.backgroundColor = #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)
            $0.cornerRadius = 24
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle("Đặt đơn mới", for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(48)
            }
        }
        
        bottomStackView.addArrangedSubview(cancelOrderButton)
        bottomStackView.addArrangedSubview(newOrderButton)
        
        headerView >>> mContainer >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(128)
            }
        }
        
        tableView >>> mContainer >>> {
            $0?.snp.makeConstraints({ (make) in
                make.top.equalTo(headerView.snp.bottom).offset(0)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(bottomStackView.snp.top).offset(-16)
            })
        }
        
        tableView.refreshControl = mRefreshControl
        
        btnCurrentLocation >>> mapView >>> {
            $0.isHidden = true
            $0.backgroundColor = .white
            $0.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.24)
            $0.shadowOpacity = 1
            $0.shadowRadius = 5
            $0.shadowOffset = CGSize(width: -2, height: 2)
            $0.setImage(UIImage(named: "ic_current_location_new"), for: .normal)
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.snp.makeConstraints { make in
                make.right.equalTo(-16)
                make.size.equalTo(CGSize(width: 32, height: 32))
                make.bottom.equalTo(0)
            }
        }
        addEventZoom(button: btnCurrentLocation)
        mContainer.transform = CGAffineTransform(translationX: 0, y: 1000)
    }
    
    func listenStateChange() {
        self.listener?.order.distinctUntilChanged().skip(1).observeOn(MainScheduler.asyncInstance).bind(onNext: {[weak self] (order) in
            guard let me = self, let status = order.status else {
                assert(false, "Require!!")
                return
            }
            self?.mOrder = order
            me.headerView.setupDisplay(item: (status: order, description: order.statusDes))
            me.cancelOrderButton.isHidden = !status.canCancelOrder
        }).disposed(by: disposeBag)
    }
    
    func listenTripChange() {
        listener?.driverCooordinate.bind(onNext: weakify({ (coord, wSelf) in
            wSelf.driverMarker.updateMarker(from: coord)
        })).disposed(by: disposeBag)
        
        listener?.polyline.bind(onNext: weakify({ (polyline, wSelf) in
            wSelf.removePolyline()
            guard let p = GMSPath.init(fromEncodedPath: polyline) else { return }
            let polyline = GMSPolyline(path: p)
            polyline.strokeColor = .orange
            polyline.strokeWidth = 3.0
            polyline.map = wSelf.mapView
            wSelf.polyline = polyline
        })).disposed(by: disposeBag)
    }
    
    private func moveMapToDriver(){
        disposeZoomDriver?.dispose()
        guard let listener = listener else { return }
        let e1 = listener.driverCooordinate.take(1)
        let e2 = listener.currentTrip.take(1)
        let edge = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        disposeZoomDriver = Observable.zip(e1, e2) { (d, trip) -> GMSCoordinateBounds in
            var b = GMSCoordinateBounds()
            let s = trip.info.coordinateStart
            let e = trip.info.coordinateEnd
            b = b.includingCoordinate(s)
            b = b.includingCoordinate(d)
            b = b.includingCoordinate(e)
            return b
        }.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (b, wSelf) in
            wSelf.mapView.animate(with: .fit(b, with: UIEdgeInsets(top: edge.top + 16, left: 16, bottom: 16, right: 16)))
        }))
    }
    
    private func addEventZoom(button: UIButton) {
        button.rx.tap.debounce(.milliseconds(300), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (wSelf) in
            wSelf.moveMapToDriver()
        })).disposed(by: disposeBag)
    }
    
    private func addButtonLocation() {
        btnCurrentLocation.isHidden = false
        $minHContainer.distinctUntilChanged().bind(onNext: weakify({ (h, wSelf) in
            let bottom = UIScreen.main.bounds.height - h
            wSelf.btnCurrentLocation.snp.updateConstraints { (make) in
                make.bottom.equalTo(-bottom - 20)
            }
        })).disposed(by: disposeBag)
    }
    
    func setupRX() {
        listener?.driver.bind(onNext: weakify({ (d, wSelf) in
            wSelf.addDriverInfo(d)
        })).disposed(by: disposeBag)
        
        listener?.serviceId.take(1).bind(onNext: weakify({ (sId, wSelf) in
            wSelf.serviceId = sId
            wSelf.listenTripChange()
        })).disposed(by: disposeBag)
        
        listener?.currentTrip.take(1).bind(onNext: weakify({ (_, wSelf) in
            wSelf.addButtonLocation()
        })).disposed(by: disposeBag)
        
        listener?.currentTrip.bind(onNext: weakify({ (trip, wSelf) in
            guard let s = trip.lastCommand?.status, s >= .started else { return }
            if !wSelf.animateViews.isEmpty {
                wSelf.animateViews.forEach { $0.removeFromSuperview() }
                wSelf.mapView.isUserInteractionEnabled = true
            }
        })).disposed(by: disposeBag)
    
        Observable.merge([headerView.btnBack.rx.tap.asObservable(), backButton.rx.tap.asObservable()]).bind { [weak self] () in
            guard let wSelf = self else { return }
            wSelf.listener?.storeTrackingMoveBack()
        }.disposed(by: disposeBag)
        
        self.listener?.order.take(1).observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (order, wSelf) in
            guard let status = order.status else {
                assert(false, "Require!!")
                return
            }
            wSelf.headerView.setupDisplay(item: (status: order, description: order.statusDes))
            wSelf.updateData(order: order)
            wSelf.cancelOrderButton.isHidden = !status.canCancelOrder
            wSelf.mOrder = order
            wSelf.listenStateChange()
            guard !order.completed  else {
                wSelf.updateUI(by: .showReceipt)
                return
            }
            DispatchQueue.main.async { wSelf.dismissContainer() }
        })).disposed(by: disposeBag)
        
        mRefreshControl.rx.controlEvent(.valueChanged).bind { [weak self] in
            guard let wSelf = self else { return }
            wSelf.mRefreshControl.beginRefreshing()
            wSelf.listener?.refresh()
        }.disposed(by: disposeBag)
        
        newOrderButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            me.listener?.createNewOrder()
        }.disposed(by: disposeBag)
        
        cancelOrderButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            me.listener?.cancelOrder()
        }.disposed(by: disposeBag)
                
        showLoading(use: self.listener?.eLoadingObser)
        
        self.listener?.eLoadingObser.bind(onNext: weakify({ (res, wSelf) in
            if res.0 == false {
                guard wSelf.mRefreshControl.isRefreshing else {
                    return
                }
                wSelf.mRefreshControl.endRefreshing()
            }
        })).disposed(by: disposeBag)
        
        self.listener?.errorObserable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self](err) in
            AlertVC.showError(for: self, message: err.getMsg())
        }).disposed(by: disposeBag)
        
        $mOrder.bind(onNext: weakify({ (order, wSelf) in
            wSelf.trackState(order: order)
        })).disposed(by: disposeBag)
        
        panGesture?.rx.event.bind(onNext: weakify({ (p, wSelf) in
            wSelf.handler(gesture: p)
        })).disposed(by: disposeBag)
    }
}

// MARK: -- Update Info Table
extension StoreTrackingVC {
    private func updateData(order: SalesOrder) {
        self.updateInfoSection(order: order)
        self.updateItemSection(order: order )
    }
    
    private func updateItemSection(order: SalesOrder) {
        let section = Section() { (s) in
            s.tag = "Section2"
        }
        
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    func updateInfoSection(order: SalesOrder) {
        let section1 = Section() { (s) in
            s.tag = "Section1"
        }
        section1 <<< RowDetailGeneric<TrackingAddressCell>.init(Config.AddressCell , {(row) in
            row.value = order
        })
        addInfo(to: section1, order: order)
        
        UIView.performWithoutAnimation {
            self.form += [section1]
        }
    }
    
    func addDetaiBill(item: SalesOrder) {
        guard let section = form.sectionBy(tag: "Section2") else { return }
        var rows = [BaseRow]()
        switch showing {
        case .full:
            let headerName = "Đơn hàng từ \(item.orderItems?.first?.nameStore ?? "cửa hàng")"
            let r =  RowDetailGeneric<TrackingInfoHeaderCell>.init("HeaderCell" , {(row) in
                row.value = headerName
            })
            rows.append(r)
            var index = 0
            let items = item.orderItems ?? []
            for item in items {
                let r1 = RowDetailGeneric<TrackingOrderItemCell>.init(Config.OrderCell , {(row) in
                    row.value = item
                    let left: CGFloat = index >= items.count-1 ? 16 : 52
                    row.cell.contentView.addSeperator(with: UIEdgeInsets(top: 0, left: left, bottom: 0, right: 0), position: .bottom)
                                    
                })
                rows.append(r1)
                index += 1
            }
            var styles = [PriceInfoDisplayStyle]()
            let d1 = PriceInfoDisplayStyle(attributeTitle: "Phí đơn hàng".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (item.baseGrandTotal?.currency ?? "").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
            styles.append(d1)
            
            let d2 = PriceInfoDisplayStyle(attributeTitle: "Phí giao hàng".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (item.salesOrderShipments?.first?.price?.currency ?? "").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
            styles.append(d2)
            
            let discount = 0 - (item.discountAmount ?? 0)
            let d3 = PriceInfoDisplayStyle(attributeTitle: Text.promotion.localizedText.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: "\(discount.currency)".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)), showLine: false, edge: .zero)
            styles.append(d3)
            
            if let vatoDiscountShippingFee = item.vatoDiscountShippingFee, vatoDiscountShippingFee > 0 {
                let att4 = FwiLocale.localized("Vato KM vận chuyển").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
                let price4 = (0 - vatoDiscountShippingFee).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
                let d3 = PriceInfoDisplayStyle(attributeTitle: att4, attributePrice: price4, showLine: false, edge: .zero)
                styles.append(d3)
            }
            
            let desPayment = item.salesOrderPayments?.first?.paymentMethodDes ?? ""
            let d4 = PriceInfoDisplayStyle(attributeTitle: desPayment.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (item.grandTotal?.currency ?? "").attribute >>> .font(f: .systemFont(ofSize: 20, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: true, edge: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
            styles.append(d4)
            
            let priceCell = RowDetailGeneric<AddDestinationPriceCell>.init("AddDestinationPriceCell") { (row) in
                row.value = styles
            }
            rows.append(priceCell)
        case .compact:
            let trackingCell = RowDetailGeneric<TrackingTotalCell>.init("TrackingTotalCell" , {(row) in
                row.value = item
            })
            rows.append(trackingCell)
        default:
            break
        }
        section.removeAll()
        rows.forEach { section <<< $0 }
    }
    
    func addInfo(to section: Section?, order: SalesOrder) {
        guard form.rowBy(tag: Config.DeliveryTime) == nil else { return }
        guard let section = section else { return }
        
        section <<< RowDetailGeneric<TrackingInfoCell>.init(Config.DeliveryTime , {(row) in
            row.cell.contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), position: .top)
            row.cell.setTitle(title: "Thời gian giao hàng")
            row.value = order.timePickUpString()
        })
        
        section <<< RowDetailGeneric<TrackingInfoCell>.init(Config.Note , {(row) in
            row.cell.contentView.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), position: .top)
            row.cell.setTitle(title: Text.note.localizedText)
            row.value = order.customerNote
        })
    }
    
    func removeAddressInfo() {
        let section = self.form.sectionBy(tag: "Section1")
        section?.allRows.filter({ (row) -> Bool in
            row.tag == Config.DeliveryTime || row.tag == Config.Note
        }).forEach({ (row) in
            guard let idx = section?.index(of: row) else { return }
            section?.remove(at: idx)
        })
    }
    
    func handlerMessage(row: RowDetailGeneric<InTripContactDriverCell>) {
        self.listener?.notifyNewChat.bind(onNext: { [weak row](number) in
            row?.value = number
        }).disposed(by: self.disposeBag)
    }
    
    func addDriverInfo(_ info: DriverInfo) {
        guard let section = self.form.sectionBy(tag: "Section1") else { return }
        let rowInfo = RowDetailGeneric<InTripDriverInfoCell>.init(InTripCellType.driverInfo.rawValue) { (row) in
            row.value = info
            row.cell.view.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16), position: .bottom)
        }
        
        let rowContact = RowDetailGeneric<InTripContactDriverCell>.init(InTripCellType.contactInfo.rawValue) { (row) in
            self.handlerMessage(row: row)
            row.cell.view.btnCall?.rx.tap.bind(onNext: weakify({ (wSelf) in
                let p = info.personal.phone
                guard let url: URL = URL(string: "tel://\(p)"), UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })).disposed(by: disposeBag)
            row.cell.view.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16), position: .bottom)
            row.cell.view.btnMessage?.rx.tap.bind(onNext: weakify({ (wSelf) in
                wSelf.listener?.routeToChat()
            })).disposed(by: disposeBag)
        }
        var allRows = section.allRows
        allRows.insert(rowContact, at: 0)
        allRows.insert(rowInfo, at: 0)
        
        section.removeAll()
        allRows.forEach { r in
            section <<< r
        }
        dismissContainer()
    }
}

// MARK: -- Track State
extension StoreTrackingVC {
    func trackState(order: SalesOrder) {
        guard let status = order.status else { return }
        switch status {
        case StoreOrderStatus.NEW..<StoreOrderStatus.DRIVER_ACCEPTED:
            guard animateViews.isEmpty else {
                return
            }
            addWaveView()
            listener?.shopDetail.take(1).bind(onNext: weakify({ (store, wSelf) in
                wSelf.mapView.animate(with: GMSCameraUpdate.setTarget(store.coordinate, zoom: MapConfig.Zoom.max))
            })).disposed(by: disposeBag)
            mapView.isUserInteractionEnabled = false
        case .CANCELED, .DRIVER_CANCEL:
            self.updateUI(by: .showReceipt)
        case .DRIVER_ACCEPTED:
            fallthrough
        default:
            if !animateViews.isEmpty {
                animateViews.forEach { $0.removeFromSuperview() }
                mapView.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: -- Setup Drag
extension StoreTrackingVC {
    func handler(gesture: UIPanGestureRecognizer) {
        let container = mContainer
        defer { gesture.setTranslation(.zero, in: container) }
        let state = gesture.state
        switch state {
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
        mContainer.transform = .identity
        guard showing != .full else { return }
        UIApplication.setStatusBar(using: .lightContent)
        showing = .full
        headerView.update(type: .full)
        headerView.snp.updateConstraints { (make) in
            make.height.equalTo(showing.hHeader)
        }
        removeAddressInfo()
        $mOrder.take(1).bind(onNext: weakify({ (order, wSelf) in
            wSelf.addInfo(to: wSelf.form.sectionBy(tag: "Section1"), order: order)
            wSelf.addDetaiBill(item: order)
        })).disposed(by: disposeBag)
    }
        
    func dismissContainer() {
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let r = self.tableView.rectForFooter(inSection: 1)
                let n = self.tableView.convert(r, to: self.mContainer)
                let y = UIScreen.main.bounds.height - n.minY
                self.minHContainer = y
                UIView.animate(withDuration: 0.2) {
                    self.mContainer.transform = CGAffineTransform(translationX: 0, y: y )
                }
            }
        }
        guard showing != .compact else { return }
        UIApplication.setStatusBar(using: .default)
        showing = .compact
        headerView.update(type: .compact)
        headerView.snp.updateConstraints { (make) in
            make.height.equalTo(showing.hHeader)
        }
        removeAddressInfo()
        $mOrder.take(1).bind(onNext: weakify({ (order, wSelf) in
            wSelf.addDetaiBill(item: order)
        })).disposed(by: disposeBag)
    }
}

// MARK: -- Marker
private extension StoreTrackingVC {
    func generateMarker(icon: String?, title: String, address: String?, coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let v = StoreTrackingInfoView.loadXib()
        v.lblTitle?.text = title
        v.lblName?.text = address
        v.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(v)
        mapView.bringSubviewToFront(btnCurrentLocation)
        let marker = VatoMarkerCustom(use: coordinate, id: title, icon: UIImage(optional: icon), viewChange: v)
        marker.map = mapView
        return marker
    }
    
    func removePolyline() {
        polyline?.map = nil
        polyline = nil
    }
}

// MARK: -- Update UI
extension StoreTrackingVC {
    func updateUI(by type: InTripUIUpdateType) {
        switch type {
        case .vibrateDriverNearby:
            Observable<Int>.timer(.seconds(1), scheduler: MainScheduler.asyncInstance).take(5).bind(onNext: weakify({ (_, wSelf) in
                AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, nil)
            })).disposed(by: disposeBag)
        case .showTakeClientTime:
            self.endMarker?.map = nil
            self.endMarker = nil
            listener?.currentTrip.take(1).bind(onNext: weakify({ (trip, wSelf) in
                let startCoord = trip.info.coordinateStart
                let marker = wSelf.generateMarker(icon: "ic_origin_marker",
                                                  title: "Quán",
                                                  address: trip.info.startAddress,
                                                  coordinate: startCoord)
                wSelf.endMarker = marker
            })).disposed(by: disposeBag)
            
        case .showInTripTime:
            self.endMarker?.map = nil
            self.endMarker = nil
        
            listener?.currentTrip.take(1).bind(onNext: weakify({ (trip, wSelf) in
                
                let startCoord = trip.info.coordinateStart
                let marker0 = wSelf.generateMarker(icon: "ic_origin_marker",
                                                   title: "Quán",
                                                   address: trip.info.startAddress,
                                                   coordinate: startCoord)
                wSelf.startMarker = marker0
                
                let endCoordinate = trip.info.coordinateEnd
                let marker = wSelf.generateMarker(icon: "ic_map_destination",
                                                  title: "Giao tới",
                                                  address: trip.info.endAddress,
                                                  coordinate: endCoordinate)
                wSelf.endMarker = marker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    wSelf.moveMapToDriver()
                }
            })).disposed(by: disposeBag)
        case .alertTripRemove(let message):
            let alertOK = AlertAction(style: .default, title: Text.ok.localizedText) { [weak self] in
                self?.listener?.storeTrackingMoveBack()
            }
            AlertVC.show(on: self, title: Text.notification.localizedText, message: message, from: [alertOK], orderType: .horizontal)
        case .showReceipt:
            showContainer()
            guard let p = self.panGesture else { return }
            headerView.removeGestureRecognizer(p)
            guard !(UIApplication.topViewController() is AlertVC) else { return }
            listener?.showReceipt()
        default:
            fatalError("Please Implement")
        }
    }
}
