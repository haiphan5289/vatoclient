//  File name   : VatoMainVC.swift
//
//  Author      : Dung Vu
//  Created date: 8/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import KeyPathKit
import SafariServices

enum ServiceCategoryAction: Equatable {
    case storeId(id: Int)
}

protocol VatoMainPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var homeResponse: Observable<[HomeResponse]>  { get }
    var user: Observable<UserInfo> { get }
    var loading: Observable<(Bool, Double)> { get }
    var servicesOngoing: Observable<[VatoHomeGroupEventGoing]> { get }
    var listBanner: Observable<[VatoHomeLandingItem]> { get }
    var listSections: Observable<ListUpdate<VatoHomeLandingItemSection>> { get }
    var loadingRequest: Observable<Bool> { get }
    var cachedItems: Observable<[VatoHomeLandingItemSection]> { get }
    
    func routeToBooking(data: VatoMainData)
    func routeToTopup()
    func routeToListPromotion()
    func showListWalletHistory()
    func handler(manifest action: ManifestAction, info: [String: Any])
    func routeToScanQR()
    func routeToProfile()
    func routeToWallet()
    func routeToServiceCategory(type: ServiceCategoryType, action: ServiceCategoryAction?)
    func routeToShortcut()
    func handler(action: VatoServiceAction)
    func requestEventOnGoing()
    func routeToHistory(type: HistoryItemType?, object: Any?)
    func checkLocation() -> Observable<Void>
    func requestNextHomeSections()
    func findDetailPromotion(code: String)
    func routeToShopping()
    func refreshHomeLanding(ignoreCache: Bool)
    func updateCheckLatePayment(status: Bool)
    func lookingForDestination(service: VatoServiceType, coordinate: Coordinate)
}

enum HomeCellIdentifier: String {
    case payment
    case service
    case other
}

final class VatoMainVC: FormViewController, VatoMainPresentable, VatoMainViewControllable, LoadingAnimateProtocol, DisposableProtocol, SafeAccessProtocol {
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private struct Config {
        static let kPrefixImageViewFooter = "bg_footer_top_main"
        static let kTagImageViewFooter = 4582
        static let kTimeImageDuration = 5 // senconds
    }
    
    /// Class's public properties.
    weak var listener: VatoMainPresentableListener?
    lazy var disposeBag = DisposeBag()
    var canHandler: Bool = true
    private var guideView: VatoGuideControl?
    private var bannerView: VatoScrollView<VatoBannerView<VatoHomeLandingItem>>?
    private var disposeListenOngoing: Disposable?
    private var loadedSections: Bool = false
    private var diposeLoadCache: Disposable?
    private var source: [VatoHomeLandingItemSection] = []
    
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        f.tintColor = .white
        return f
    }()
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.tableView.separatorColor = .clear
        self.tableView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .lightContent)
        self.canHandler = true
        localize()
        listener?.requestEventOnGoing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.canHandler = false
    }
    
    /// Class's private properties.
}

// MARK: View's event handlers
extension VatoMainVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension VatoMainVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = .white
        
        let addGuide = { [unowned self] in
            let guideView = VatoGuideControl()
            guideView >>> self.view >>> {
                $0.snp.makeConstraints { (make) in
                    make.right.equalTo(-16)
                    make.size.equalTo(CGSize(width: 72, height: 72))
                    if self.tabBarController?.tabBar.isHidden == true {
                        make.bottom.equalTo(self.view.snp.bottom).offset(-16)
                    } else {
                        if #available(iOS 11, *) {
                            make.bottom.equalTo(self.view.layoutMarginsGuide.snp.bottom).offset(-16)
                        } else {
                            let h = (self.tabBarController?.tabBar.bounds.height ?? 0) + 16
                            make.bottom.equalTo(self.view.layoutMarginsGuide.snp.bottom).offset(-h)
                        }
                    }
                }
            }
            self.guideView = guideView
        }
        
        let imageView = VatoScrollView<VatoBannerView<VatoHomeLandingItem>>.init(edge: .zero, sizeItem: CGSize(width: UIScreen.main.bounds.width, height: 64), spacing: 0, type: .banner, bottomPageIndicator: -10)
        imageView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                if self.tabBarController?.tabBar.isHidden == true {
                    make.bottom.equalTo(view.snp.bottom)
                } else {
                    if #available(iOS 11, *) {
                        make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom)
                    } else {
                        let h = self.tabBarController?.tabBar.bounds.height ?? 0
                        make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-h)
                    }
                }
                make.height.equalTo(0)
            }
        }
        
        self.bannerView = imageView
        let backgroundView = UIView(frame: .zero)
        let hBgView = UIView(frame: .zero)
        hBgView >>> backgroundView >>> {
            $0.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            $0.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(UIScreen.main.bounds.height * 0.4)
            }
        }
        
        backgroundView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        tableView >>> view >>> {
            $0.refreshControl = mRefreshControl
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(view.layoutMarginsGuide.snp.top)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(imageView.snp.top)
            })
        }
        view.bringSubviewToFront(imageView)
        addGuide()
    }
    
    private func addListenPayment(row: RowDetailGeneric<VatoPaymentMainCell>) {
        self.listener?.user.bind(onNext: weakify({ [weak row](user, wSelf) in
            row?.cell.update(user: user)
        })).disposed(by: disposeBag)
    }
    
    private func setupDisplayEventOnGoing(list: [VatoHomeGroupEventGoing]) {
        self.form.removeAll(where: { $0.tag == "OnGoing" })
        guard !list.isEmpty else { return }
        let section = Section { (s) in
            s.tag = "OnGoing"
        }
        
        section <<< RowDetailGeneric<VatoEventOnGoingCell>.init("CellOnGoing", { (row) in
            row.value = list
            row.cell.segment.scrollView = self.tableView
            row.cell.segment.selected.bind(onNext: weakify({ (i, wSelf) in
                wSelf.listener?.routeToHistory(type: i.service.historyType, object: nil)
            })).disposed(by: disposeBag)
        })
        self.form.insert(section, at: 1)
    }
    
    private func listenOngoing() {
        disposeListenOngoing = listener?.servicesOngoing.bind(onNext: weakify({ (list, wSelf) in
            wSelf.setupDisplayEventOnGoing(list: list)
        }))
    }
    
    func setupRX() {
        self.tableView.prefetchDataSource = self
        showLoading(use: self.listener?.loading)
        listener?.listBanner.bind(onNext: weakify({ (list, wSelf) in
            let h = list.isEmpty ? 0 : 66
            wSelf.bannerView?.setupDisplay(item: list)
            wSelf.bannerView?.snp.updateConstraints({ (make) in
                make.height.equalTo(h)
            })
        })).disposed(by: disposeBag)
        
        self.rx.methodInvoked(#selector(self.viewDidAppear(_:))).skip(1).bind(onNext: weakify({ (_, wSelf) in
            guard DispatchQueue.needCheckLatePayment else { return }
            wSelf.listener?.updateCheckLatePayment(status: false)
        })).disposed(by: disposeBag)
        
        mRefreshControl.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.mRefreshControl.beginRefreshing()
            wSelf.loadedSections = false
            wSelf.listener?.refreshHomeLanding(ignoreCache: true)
        })).disposed(by: disposeBag)
        
        listener?.loadingRequest.bind(onNext: weakify({ (load, wSelf) in
            if !load, wSelf.mRefreshControl.isRefreshing {
                wSelf.mRefreshControl.endRefreshing()
            }
        })).disposed(by: disposeBag)
        
        self.bannerView?.selected.bind(onNext: weakify({ (item, wSelf) in
            wSelf.handlerHomeLanding(item)
        })).disposed(by: disposeBag)
        
        self.guideView?.rx.controlEvent(.touchUpInside).bind(onNext: weakify({ (wSelf) in
            wSelf.handler(payment: .support)
        })).disposed(by: disposeBag)
        
        self.listener?.homeResponse.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (items, wSelf) in
            wSelf.disposeListenOngoing?.dispose()
            if !wSelf.form.isEmpty {
                wSelf.form.removeAll()
            }
            
            let section1 = Section("", { (section) in
                section.tag = "Payment"
            })
            
            let section2 = Section("", { (s) in
                s.tag = "Promotion"
                var header = HeaderFooterView<UIView>.init(.callback({ () -> UIView in
                    let v = UIView(frame: .zero)
                    v.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                    v.addSeperator()
                    v.addSeperator(position: .top)
                    return v
                }))
                header.height = { 10 }
                s.header = header
            })
            let values = items.filter(where: \.active == 1 && \.layout_type > 0)
            
            let groups = values.groupBy(\.layout_type).sorted(by: { (v1, v2) -> Bool in
                return v1.key < v2.key
            })
            
            wSelf.loadCacheSections(for: section2)
            
            groups.forEach({ (element) in
                switch element.key {
                case 1:
                    section1 <<< RowDetailGeneric<VatoPaymentMainCell>.init(HomeCellIdentifier.payment.rawValue, { (row) in
                        row.value = element.value.first
                        row.cell.setCallBack({ [weak self](action) in
                            self?.handler(payment: action)
                        })
                        self.addListenPayment(row: row)
                    })
                case 2:
                    section1 <<< RowDetailGeneric<VatoServiceCell>.init(HomeCellIdentifier.service.rawValue, { (row) in
                        row.value = element.value.first?.items?.sorted(by: { (i1, i2) -> Bool in
                            (i1.active ?? 0) > (i2.active ?? 0)
                        })
                        row.cell.callBack = { [weak self] s in
                            guard let type = s.type else {
                                return
                            }
                            if type == .erp {
                                self?.openERPWeb(url: s.erpItem?.url)
                            } else {
                                self?.handler(service: type)
                            }
                        }
                    })
                default:
                    break
                }
            })

            UIView.performWithoutAnimation {
                wSelf.form += [section1, section2]
            }
            wSelf.listenOngoing()
            wSelf.listenListSections()
        })).disposed(by: disposeBag)
    }
    
    private func openERPWeb(url: String?) {
        guard let url = url, var p = URLComponents(string: url)  else {
            return
        }
        
        guard let phone = UserManager.instance.info?.phone else {
            return
        }
        
        FirebaseTokenHelper.instance.eToken.filterNil().take(1).bind(onNext: weakify({ (token, wSelf) in
            let queries = [URLQueryItem(name: "phoneNumber", value: phone), URLQueryItem(name: "token", value: token)]
            p.queryItems = queries
            let newURL = p.url
            wSelf.openSafari(url: newURL)
        })).disposed(by: disposeBag)
    }
    
    private func openSafari(url: URL?) {
        guard let url = url else { return }
        ERPWebVC.loadWeb(on: self, url: url, title: nil)
//        let webVC: SFSafariViewController
//        if #available(iOS 11, *) {
//            let configure = SFSafariViewController.Configuration()
//            configure.barCollapsingEnabled = true
//            webVC = SFSafariViewController(url: url, configuration: configure)
//        } else {
//            webVC = SFSafariViewController(url: url)
//        }
//        webVC.preferredBarTintColor = Color.orange
//        webVC.preferredControlTintColor = .white
//        self.present(webVC, animated: true, completion: nil)
    }
    
    private func loadCacheSections(for section: Section) {
        diposeLoadCache = listener?.cachedItems.bind(onNext: weakify({ (items, wSelf) in
            if !section.allRows.isEmpty {
                UIView.performWithoutAnimation {
                    section.removeAll()
                }
            }
            
            if !items.isEmpty {
                DispatchQueue.loadCacheHome = true
                wSelf.updateDisplaySection(items: items, section: section)
            } else {
                section <<< RowDetailGeneric<VatoPromotionNewsLayout1Cell>.init("Dummy1", { (row) in
                    row.cell.loadDummyView()
                })
                
                section <<< RowDetailGeneric<VatoPromotionNewsLayout2Cell>.init("Dummy2", { (row) in
                    row.cell.loadDummyView()
                })
            }
        }))
    }
    
    private func updateDisplaySection(items: [VatoHomeLandingItemSection], section: Section) {
        items.forEach { (s) in
            guard let t = s.type else { return }
            switch t {
            case .carousel:
                section <<< RowDetailGeneric<VatoPromotionNewsLayout1Cell>.init(s.id, { [unowned self] (row) in
                    row.value = s
                    self.handler(event: row.cell.removeEvent, tag: s.id, section: section)
                    row.cell.containerView.view.itemsView.selected.bind(onNext: self.weakify({ (i, wSelf) in
                        wSelf.handlerHomeLanding(i)
                    })).disposed(by: self.disposeBag)
                })
            case .horizontal:
                section <<< RowDetailGeneric<VatoPromotionNewsLayout2Cell>.init(s.id, { [unowned self] (row) in
                    row.value = s
                    self.handler(event: row.cell.removeEvent, tag: s.id, section: section)
                    self.setupSeeAll(button: row.cell.btnSeeAll, section: s)
                    row.cell.containerView.view.itemsView.selected.bind(onNext: self.weakify({ (i, wSelf) in
                        wSelf.handlerHomeLanding(i)
                    })).disposed(by: self.disposeBag)
                })
            case .vertical:
                break
            case .bannerList:
                break
            }
        }
    }
    
    private func showList(section: VatoHomeLandingItemSection) {
        VatoMainListSectionVC.showList(on: self, section: section).filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.handlerHomeLanding(item)
        })).disposed(by: disposeBag)
    }
    
    private func setupSeeAll(button: UIButton, section: VatoHomeLandingItemSection) {
        button.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.showList(section: section)
        })).disposed(by: disposeBag)
    }
    
    private func listenListSections() {
        listener?.listSections.bind(onNext: weakify({ (update, wSelf) in
            DispatchQueue.loadCacheHome = false
            wSelf.diposeLoadCache?.dispose()
            guard let section = wSelf.form.sectionBy(tag: "Promotion") else { return }
            wSelf.loadedSections = true
            var items: [VatoHomeLandingItemSection]
            var reload: Bool = false
            switch update {
            case .reload(let i):
                reload = true
                UIView.performWithoutAnimation {
                    section.removeAll()
                }

                items = i
            case .update(let i):
                items = i
            }
            guard !items.isEmpty else { return }
            if reload {
                wSelf.source = items
            } else {
                items = items.filter { !wSelf.source.contains($0) }
                wSelf.source += items
            }
            wSelf.excute { wSelf.updateDisplaySection(items: items, section: section) }
        })).disposed(by: disposeBag)
    }
    
    private func handler(event: Observable<Void>, tag: String, section: Section) {
        event.bind { [weak section] in
            section?.removeAll { (row) -> Bool in
                row.tag == tag
            }
        }.disposed(by: disposeBag)
    }
    
    private func handler(payment action: VatoPayAction) {
        switch action {
        case .wallet:
            if self.tabBarController?.tabBar.isHidden == false {
                self.tabBarController?.selectedIndex = TabbarType.vatoPay.rawValue
            } else {
                listener?.routeToWallet()
            }
        case .topup:
            self.listener?.routeToTopup()
        case .promotion:
           self.listener?.routeToListPromotion()
        case .transaction:
            self.listener?.showListWalletHistory()
        case .scanQR:
            self.listener?.routeToScanQR()
        case .profile:
            self.listener?.routeToProfile()
        case .support:
            self.listener?.routeToShortcut()
        }
    }
    
    private func handler(service action: VatoServiceAction) {
        self.listener?.handler(action: action)
    }
    
    func handler(item: HomeItems?) {
        guard let item = item, let extra = item.data, !extra.isEmpty else {
            return
        }
        let id = item.id ?? 0
        
        switch id {
        case 300..<400:
            // promotion
            if extra.contains("http") {
                self.listener?.handler(manifest: .web, info: ["extra": extra])
            } else {
                self.listener?.handler(manifest: .manifest, info: ["extra": extra])
            }
        case 400..<500:
            // news
            self.listener?.handler(manifest: .web, info: ["extra": extra])
        default:
            break
        }
    }
}

// MARK: - Prefech data
extension VatoMainVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard loadedSections else { return }
        guard let last = indexPaths.last, self.form.allSections.count - 1 == last.section else { return }
        guard last.item >= 2 else {
            return
        }
        listener?.requestNextHomeSections()
    }
    
}

// MARK: - Handler action home
private extension VatoMainVC {
    private func handlerHomeLanding(_ item: VatoHomeLandingItem) {
        let action = item.action
        guard let type = action.action_type else {
            return
        }
        
        if let buslineItem = action.buslineItem {
            listener?.routeToHistory(type: .busline, object: buslineItem)
            return
        }

        guard let data = action.data else {
            return
        }
        
        defer {
            LogEventHelper.log(key: "Home_Client_iOS_Item_landing", value: item, params: nil)
        }
        
        let openWeb: ((url: String?, external: Bool)) -> () = { [weak self] i in
            guard let url = i.url, let p = URL(string: url) else {
                return
            }
            
            if i.external {
                guard UIApplication.shared.canOpenURL(p) else {
                    return
                }
                UIApplication.shared.open(p, options: [:], completionHandler: nil)
            } else {
                WebVC.loadWeb(on: self, url: p, title: nil)
            }
        }
        
        switch type {
        case .open, .view:
            guard let target_screen = action.target_screen else {
                return
            }
            
            switch target_screen {
            case .webViewLocal:
                openWeb((data.url, false))
            case .webViewBrowser:
                openWeb((data.url, true))
            case .ecomHome, .ridingBook:
                findingService(from: item)

            case .busline:
                self.handler(service: .buyTicket)
            case .delivery:
                guard let sId = data.service_ids?.first, let s = VatoServiceType(rawValue: sId)  else {
                    return
                }
                switch s {
                case .shopping:
                    listener?.checkLocation().bind(onNext: weakify({ (wSelf) in
                        wSelf.listener?.routeToShopping()
                    })).disposed(by: disposeBag)
                default:
                    listener?.routeToBooking(data: .service(s: s))
                }
                
            case .topup:
                self.listener?.routeToTopup()
            case .promotion:
                guard let code = data.code else {
                    return
                }
                listener?.findDetailPromotion(code: code)
            }
            
        case .view_web:
            openWeb((data.url, false))
        case .open_web:
            openWeb((data.url, true))
        default:
            break
        }
    }
}

