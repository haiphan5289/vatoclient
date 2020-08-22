//  File name   : FoodMainVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import FwiCore
import FwiCoreRX

enum FoodDetailType {
    case item(store: FoodExploreItem)
    case store(id: Int)
    case category(id: Int)
}

enum FoodDisplayType: Int, CaseIterable {
    case banner = 0
    case category
    case whatstoday
    case highCommission
    case freeShipShop
    case familiarShop
    case news
    case nearest
    var title: String {
        switch self {
        case .banner:
            return ""
        case .category:
            return "Danh mục"
        case .familiarShop:
            return "Quán cũ mà ngon"
        case .news:
            return "Mới nhất"
        case .nearest:
            return "Gần tôi"
        case .freeShipShop:
            return "Miễn phí giao hàng"
        case .whatstoday:
            return "Hôm nay ăn gì"
        case .highCommission:
            return "Gợi ý"
        }
    }
    
    var more: String {
        switch self {
        case .news, .nearest, .familiarShop, .whatstoday, .highCommission, .freeShipShop:
            return "Xem thêm"
        default:
            return ""
        }
    }
}

protocol FoodMainPresentableListener: HistoryListenerProtocol {
    var banners: Observable<[FoodBannerItem]> { get }
    var categories: Observable<[FoodCategoryItem]> { get }
    var news: Observable<[FoodExploreItem]> { get }
    var nearest: Observable<[FoodExploreItem]> { get }
    var familarShops: Observable<[FoodExploreItem]> { get }
    var freeShipShops: Observable<[FoodExploreItem]> { get }
    var whatsTodays: Observable<[FoodExploreItem]> { get }
    var listHighCommission: Observable<[FoodExploreItem]> { get }
    var discovery: Observable<ListUpdate<FoodExploreItem>> { get }
    var originAddress: Observable<AddressProtocol?> { get }
    var error: Observable<MerchantState> { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    var quoteCart: Observable<QuoteCart?> { get }
    var numberProcessing: Observable<Int> { get }
    var rootId: Int { get }
    
    func foodMoveBack()
    func routeToDetail(item: FoodDetailType)
    func routeToList(type: FoodListType)
    func requestDiscovery()
    func refresh()
    func routeToSearch()
    func routeToSearchLocation()
    func routeToRootCategory()
    func routeToListCategory(detail: CategoryRequestProtocol)
    func requestNumberOrderProcessing()
    func routeToCheckOut()
    func requestStores(from brandId: Int) -> Observable<[FoodExploreItem]>
    func cancelRequestDiscovery()
 }

final class FoodMainVC: UIViewController, FoodMainPresentable, FoodMainViewControllable, LoadingAnimateProtocol, DisposableProtocol, SafeAccessProtocol {
    private struct Config {
        static let discovery: (Int?) -> String = { rootId -> String in
            guard let rootId = rootId, let type = ServiceCategoryType.loadEcom(category: rootId) else {
                return "Khám phá"
            }
            
            switch type {
            case .food:
                return "Quán ngon gần tôi"
            default:
                return "Khám phá"
            }
            
        }
    }
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private (set) var canHandler: Bool = true
    /// Class's public properties.
    weak var listener: FoodMainPresentableListener?
    private lazy var headerView = FoodVatoHeaderView.loadXib()
    private lazy var noStoreNearbyView = NoStoreNearby(frame: .zero)
    private lazy var searchView = UIView(frame: .zero)
    var lblNumberItemQuoteCard: UILabel?
    var quoteCartView: VatoGuideControl?
    private var currentLoadDataIndexPath: IndexPath?
    
    lazy var disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.showsVerticalScrollIndicator = false
        t.backgroundColor = .white
        t.separatorStyle = .none
        return t
    }()
    
    private lazy var sourceHighCommission: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var sourceWhatsToday: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var sourceCategories: BehaviorRelay<[FoodCategoryItem]> = BehaviorRelay(value: [])
    private lazy var sourceBanners: BehaviorRelay<[FoodBannerItem]> = BehaviorRelay(value: [])
    private lazy var sourceNews: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var sourceNearest: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var sourceDiscovery: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var sourceFamiliarShops: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var sourceFreeShipShops: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    
    private lazy var noItemView = NoItemView(imageName: "ic_food_noItem", message: Text.foodNoItem.localizedText, on: tableView)
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .default)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        setDisplayNavigationBar()
        localize()
        canHandler = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        canHandler = false
    }

    /// Class's private properties.
    
    @objc func tapMore(_ button: UIButton) {
        let tag = button.tag
        guard let displayType = FoodDisplayType(rawValue: tag), let id = self.listener?.rootId else {
            return
        }
        
        switch displayType {
        case .news:
            listener?.routeToList(type: .news(rootId: id))
        case .nearest:
            listener?.routeToList(type: .nearest(rootId: id))
        case .familiarShop:
            listener?.routeToList(type: .familarShop(rootId: id))
        case .whatstoday:
            listener?.routeToList(type: .whatstoday(rootId: id))
        case .highCommission:
            listener?.routeToList(type: .highCommission(rootId: id))
        case .freeShipShop:
            listener?.routeToList(type: .freeShipShop(rootId: id))
        default:
            break
        }
    }
}

// MARK: Quote cart
extension FoodMainVC: QuoteCartProtocol {
    var containerView: UIView {
        return self.view
    }
}

// MARK: View's event handlers
extension FoodMainVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func historyDismiss(completion: (() ->())?) {
        self.presentedViewController?.dismiss(animated: true, completion: completion)
    }
}

// MARK: Class's public methods
extension FoodMainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let type = FoodDisplayType(rawValue: indexPath.item) else {
                fatalError("Please Implement")
            }
            switch type {
            case .banner:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodBannerView>.identifier) as? FoodGenericTVC<FoodBannerView> else {
                    fatalError("Please Implement")
                }
                let eReuse = cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse))
                let event = listener?.numberProcessing.map { n -> String in
                    n > 0 ? FwiLocale.localized("Đang xử lý") + " <b>(\(n))</b>" : Text.orderedItem.localizedText
                }.takeUntil(eReuse)
                cell.view.updateDisplay(text: event)
                eReuse.take(1).bind { [weak cell](_) in
                    cell?.view.disposeUpdate?.dispose()
                }.disposed(by: disposeBag)
                cell.view.btnDetailPromotion?.rx.tap.takeUntil(eReuse).bind(onNext: weakify({ (wSelf) in
                    wSelf.showHistory()
                })).disposed(by: disposeBag)
                cell.view.showHistory()
                cell.view.callback = { [weak self] item in
                    guard let item = item as? FoodBannerItem, let action = item.action else { return }
                    self?.handlerBanner(action)
                }
                
                cell.setupDisplay(item: sourceBanners.value)
                return cell
            case .category:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodCategoryView>.identifier) as? FoodGenericTVC<FoodCategoryView> else {
                    fatalError("Please Implement")
                }
                cell.setupDisplay(item: sourceCategories.value)
                cell.view.callback = { [weak self] item in
                    guard item.id != nil else {
                        self?.listener?.routeToRootCategory()
                        return
                    }
                    
                    if item.hasChildren {
                        self?.listener?.routeToListCategory(detail: item)
                    } else {
                        self?.listener?.routeToList(type: .category(model: item))
                    }
                }
                return cell
            case .whatstoday:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodItemsView>.identifier) as? FoodGenericTVC<FoodItemsView> else {
                    fatalError("Please Implement")
                }
                cell.view.lblTitle?.text = type.title
                cell.view.btnMore?.tag = type.rawValue
                cell.view.btnMore?.addTarget(self, action: #selector(tapMore(_:)), for: .touchUpInside)
                cell.view.btnMore?.setTitle(type.more, for: .normal)
                cell.view.callback = { [weak self] item in
                    self?.listener?.routeToDetail(item: .item(store: item))
                }
                cell.setupDisplay(item: sourceWhatsToday.asObservable())
                cell.view.btnMore?.isHidden = sourceWhatsToday.value.count < 10
                if cell.contentView.viewWithTag(7538) == nil {
                    let lineView = UIView(frame: .zero)
                    lineView >>> cell.contentView >>> {
                        $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                        $0.snp.makeConstraints { (make) in
                            make.left.right.bottom.equalToSuperview()
                            make.height.equalTo(8)
                        }
                    }
                    lineView.addSeperator(position: .top)
                    lineView.addSeperator()
                }
                return cell
            case .highCommission:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodItemsView>.identifier) as? FoodGenericTVC<FoodItemsView> else {
                    fatalError("Please Implement")
                }
                cell.view.lblTitle?.text = type.title
                cell.view.btnMore?.tag = type.rawValue
                cell.view.btnMore?.addTarget(self, action: #selector(tapMore(_:)), for: .touchUpInside)
                cell.view.btnMore?.setTitle(type.more, for: .normal)
                cell.view.callback = { [weak self] item in
                    self?.listener?.routeToDetail(item: .item(store: item))
                }
                cell.setupDisplay(item: sourceHighCommission.asObservable())
                cell.view.btnMore?.isHidden = sourceHighCommission.value.count < 10
                if cell.contentView.viewWithTag(7538) == nil {
                    let lineView = UIView(frame: .zero)
                    lineView >>> cell.contentView >>> {
                        $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                        $0.snp.makeConstraints { (make) in
                            make.left.right.bottom.equalToSuperview()
                            make.height.equalTo(8)
                        }
                    }
                    lineView.addSeperator(position: .top)
                    lineView.addSeperator()
                }
                return cell
            case .freeShipShop:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodItemsView>.identifier) as? FoodGenericTVC<FoodItemsView> else {
                    fatalError("Please Implement")
                }
                cell.view.lblTitle?.text = type.title
                cell.view.btnMore?.tag = type.rawValue
                cell.view.btnMore?.addTarget(self, action: #selector(tapMore(_:)), for: .touchUpInside)
                cell.view.btnMore?.setTitle(type.more, for: .normal)
                cell.view.callback = { [weak self] item in
                    self?.listener?.routeToDetail(item: .item(store: item))
                }
                cell.view.btnMore?.isHidden = sourceFreeShipShops.value.count < 10
                cell.setupDisplay(item: sourceFreeShipShops.asObservable())
                if cell.contentView.viewWithTag(7538) == nil {
                    let lineView = UIView(frame: .zero)
                    lineView >>> cell.contentView >>> {
                        $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                        $0.snp.makeConstraints { (make) in
                            make.left.right.bottom.equalToSuperview()
                            make.height.equalTo(8)
                        }
                    }
                    lineView.addSeperator(position: .top)
                    lineView.addSeperator()
                }
                return cell
            case .familiarShop:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodItemsView>.identifier) as? FoodGenericTVC<FoodItemsView> else {
                    fatalError("Please Implement")
                }
                cell.view.lblTitle?.text = type.title
                cell.view.btnMore?.tag = type.rawValue
                cell.view.btnMore?.addTarget(self, action: #selector(tapMore(_:)), for: .touchUpInside)
                cell.view.btnMore?.setTitle(type.more, for: .normal)
                cell.view.btnMore?.isHidden = sourceFamiliarShops.value.count < 10
                cell.view.callback = { [weak self] item in
                    self?.listener?.routeToDetail(item: .item(store: item))
                }
                cell.setupDisplay(item: sourceFamiliarShops.asObservable())
                cell.view.btnMore?.isHidden = sourceFamiliarShops.value.count < 10
                if cell.contentView.viewWithTag(7538) == nil {
                    let lineView = UIView(frame: .zero)
                    lineView >>> cell.contentView >>> {
                        $0.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                        $0.snp.makeConstraints { (make) in
                            make.left.right.bottom.equalToSuperview()
                            make.height.equalTo(8)
                        }
                    }
                    lineView.addSeperator(position: .top)
                    lineView.addSeperator()
                }
                return cell
            case .news:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodItemsView>.identifier) as? FoodGenericTVC<FoodItemsView> else {
                    fatalError("Please Implement")
                }
                cell.view.lblTitle?.text = type.title
                cell.view.btnMore?.tag = type.rawValue
                cell.view.btnMore?.addTarget(self, action: #selector(tapMore(_:)), for: .touchUpInside)
                cell.view.btnMore?.setTitle(type.more, for: .normal)
                cell.view.callback = { [weak self] item in
                    self?.listener?.routeToDetail(item: .item(store: item))
                }
                cell.setupDisplay(item: sourceNews.asObservable())
                cell.view.btnMore?.isHidden = sourceNews.value.count < 10
                return cell
            case .nearest:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodItemsView>.identifier) as? FoodGenericTVC<FoodItemsView> else {
                    fatalError("Please Implement")
                }
                cell.view.btnMore?.tag = type.rawValue
                cell.view.lblTitle?.text = type.title
                cell.view.btnMore?.addTarget(self, action: #selector(tapMore(_:)), for: .touchUpInside)
                cell.view.btnMore?.setTitle(type.more, for: .normal)
                cell.view.callback = { [weak self] item in
                    self?.listener?.routeToDetail(item: .item(store: item))
                }
                cell.setupDisplay(item: sourceNearest.asObservable())
                return cell
            }
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodDiscoveryView>.identifier) as? FoodGenericTVC<FoodDiscoveryView> else {
                fatalError("Please Implement")
            }
            let item = sourceDiscovery.value[safe: indexPath.item]
            cell.setupDisplay(item: item)
            cell.view.btnShowBrand?.addTarget(self, action: #selector(showStores(_:)), for: .touchUpInside)
            return cell
            
        default:
            fatalError("Please Implement")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let c = cell as? LazyDisplayImageProtocol else {
            return
        }
        DispatchQueue.main.async {
            c.displayImage()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let c = cell as? CleanActionProtocol else {
            return
        }
        c.cleanAction()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return FoodDisplayType.allCases.count
        case 1:
            return sourceDiscovery.value.count
        default:
            fatalError("Please Implement")
        }
    }
}

// MARK: -- Prefetch Data
extension FoodMainVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let idx = indexPaths.last, idx.section > 0 else {
            return
        }
        let range = sourceDiscovery.value.count - idx.item
        guard 0...10 ~= range else { return }
        excute { self.currentLoadDataIndexPath = idx }
        DispatchQueue(label: "com.vato.ecomRequest").async {
            self.listener?.requestDiscovery()
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        guard let current = excute(block: { self.currentLoadDataIndexPath }), indexPaths.contains(current) else {
            return
        }
        listener?.cancelRequestDiscovery()
        excute { self.currentLoadDataIndexPath = nil }
    }
}

extension FoodMainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            guard let type = FoodDisplayType(rawValue: indexPath.item) else {
                fatalError("Please Implement")
            }
            switch type {
            case .banner:
                return sourceBanners.value.isEmpty ? 0 : UITableView.automaticDimension
            case .category:
                return sourceCategories.value.isEmpty ? 0 : UITableView.automaticDimension
            case .whatstoday:
                return sourceWhatsToday.value.isEmpty ? 0 : UITableView.automaticDimension
            case .familiarShop:
                return sourceFamiliarShops.value.isEmpty ? 0 : UITableView.automaticDimension
            case .highCommission:
                return sourceHighCommission.value.isEmpty ? 0 : UITableView.automaticDimension
            case .freeShipShop:
                return sourceFreeShipShops.value.isEmpty ? 0 : UITableView.automaticDimension
            case .news:
                return sourceNews.value.isEmpty ? 0 : UITableView.automaticDimension
            case .nearest:
                return sourceNearest.value.isEmpty ? 0 : UITableView.automaticDimension
            }
        case 1:
            return UITableView.automaticDimension
        default:
            fatalError("Please Implement")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            let view = UIView(frame: .zero)
            view.backgroundColor = .white
            view.clipsToBounds = true
            let label = UILabel(frame: .zero)
            label >>> view >>> {
                $0.text = Config.discovery(listener?.rootId)
                $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                $0.snp.makeConstraints({ (make) in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalTo(-5)
                })
            }
            return view
        default:
            fatalError("Please Implement")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.1
        case 1:
            let h: CGFloat = sourceDiscovery.value.isEmpty ? 0.1 : 34
            return h
        default:
            fatalError("Please Implement")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            break
        case 1:
            let item = self.sourceDiscovery.value[indexPath.item]
            listener?.routeToDetail(item: .item(store: item))
        default:
            fatalError("Please Implement")
        }
    }
}

// MARK: -- Show Alert Confirm
extension FoodMainVC {
    func showConfirmRemoveBasketAlert(cancelHandler: @escaping AlertBlock, confirmHandler: @escaping AlertBlock) {
        var arguments: AlertArguments = [:]
        let titleStyle = AlertLabelValue(text: "Tạo giỏ hàng mới", style: AlertStyleText(color: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), font: UIFont.systemFont(ofSize: 18, weight: .medium), numberLines: 1, textAlignment: .center))
        arguments[.title] = titleStyle
        let messagerStyle = AlertLabelValue(text: "Chọn món này thì các món hiện tại trong giỏ hàng sẽ bị xoá. Bạn có muốn tiếp tục không?", style: AlertStyleText(color: #colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1), font: UIFont.systemFont(ofSize: 15, weight: .regular), numberLines: 0, textAlignment: .center))
        arguments[.message] = messagerStyle
        let imageStyle = AlertImageValue(imageName: "ic_food_promotion_alert", style: AlertImageStyle(contentMode: .scaleAspectFill, size: CGSize(width: 160, height: 120)))
        arguments[.image] = imageStyle
        
        let buttons: [AlertAction] = [AlertAction(style: .newCancel, title: "Không", handler: cancelHandler), AlertAction(style: .newDefault, title: "Có", handler: confirmHandler)]
        
        AlertCustomVC.show(on: self, option: .all, arguments: arguments, buttons: buttons, orderType: .horizontal)
        
    }
}

// MARK: Class's private methods
private extension FoodMainVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    @objc func showStores(_ button: UIButton) {
        let brandId = button.tag
        guard let listener = listener else { return }
        EcomStoresListVC
            .showUse(source: listener.requestStores(from: brandId), on: self,
                     currentSelect: Observable.empty(),
                     title: FwiLocale.localized("Danh sách cửa hàng"))
            .filterNil()
            .delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (item, wSelf) in
            wSelf.listener?.routeToDetail(item: .item(store: item))
        })).disposed(by: disposeBag)
    }
    
    func handlerBanner(_ action: FoodBannerAction) {
        switch action.type {
        case .store:
            listener?.routeToDetail(item: .store(id: action.targetId))
        case .product:
            assert(false, "Not Define Yet!!!")
        case .listing:
            listener?.routeToDetail(item: .category(id: action.targetId))
        }
    }
    
    func showHistory() {
        let foodVC = FoodHistoryViewController()
        foodVC.historyItemType = .food
        foodVC.listener = listener
        foodVC.showingType = .navigation
        
        let naviVC = UINavigationController(rootViewController: foodVC)
        naviVC.modalTransitionStyle = .coverVertical
        naviVC.modalPresentationStyle = .fullScreen
        self.present(naviVC, animated: true, completion: nil)
    }
    
    func setDisplayNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.setBackgroundImage(nil, for: .default)
        navigationBar?.barTintColor = .white
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
// MARK: - Visualize
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = .white
        UIApplication.setStatusBar(using: .default)
        let navigationBar = navigationController?.navigationBar
        navigationBar?.shadowImage = UIImage()
        if #available(iOS 12, *) {
        } else {
            navigationBar?.subviews.flatMap { $0.subviews }.filter{ $0 is UIImageView }.forEach({
                $0.isHidden = true
            })
        }
        headerView >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: UIScreen.main.bounds.width, height: 44))
            })
        }
        
        let sView = FoodSearchHeaderView.loadXib()
        sView >>> searchView >>> {
            $0.btnBack?.isHidden = true
            $0.btnBack?.removeFromSuperview()
            $0.update(placeHolder: FwiLocale.localized("Tìm món, cửa hàng"))
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(16)
                make.left.equalTo(16)
                make.bottom.equalTo(-6).priority(.high)
                make.right.equalTo(10)
            }
        }
        
        searchView >>> view >>> {
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.snp.makeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(58)
            })
        }
        
        let btnSearch: UIButton = UIButton(frame: .zero)
        btnSearch >>> searchView >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        btnSearch.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToSearch()
        })).disposed(by: disposeBag)
        
        headerView.btnSearch?.setImage(UIImage(named: "ic_food_promotion_bar"), for: .normal)
        headerView.btnSearch?.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        navigationItem.titleView = headerView
        tableView.addSubview(mRefreshControl)
        tableView >>> view >>> {
            $0.separatorColor = .clear
            $0.separatorStyle = .none
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(searchView.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            })
        }
        
        FoodDisplayType.allCases.forEach { (type) in
            switch type {
            case .banner:
                tableView.register(FoodGenericTVC<FoodBannerView>.self, forCellReuseIdentifier: FoodGenericTVC<FoodBannerView>.identifier)
            case .category:
                tableView.register(FoodGenericTVC<FoodCategoryView>.self, forCellReuseIdentifier: FoodGenericTVC<FoodCategoryView>.identifier)
            case .news:
                tableView.register(FoodGenericTVC<FoodItemsView>.self, forCellReuseIdentifier: FoodGenericTVC<FoodItemsView>.identifier)
            default:
                break
            }
        }
        tableView.register(FoodGenericTVC<FoodDiscoveryView>.self, forCellReuseIdentifier: FoodGenericTVC<FoodDiscoveryView>.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        noStoreNearbyView >>> self.view >>> {
            $0.isHidden = true
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        createQuoteView()
        self.quoteCartView?.isHidden = true
    }
    
    private func update(event: ListUpdate<FoodExploreItem>) {
        if self.mRefreshControl.isRefreshing {
            self.mRefreshControl.endRefreshing()
        }
        
        switch event {
        case let .reload(items):
            sourceDiscovery.accept(items)
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        case let .update(items):
            let before = self.sourceDiscovery.value
            let after = before + items
            sourceDiscovery.accept(after)
            let range = (before.count ..< after.count)
            guard !range.isEmpty else { return }
            self.tableView.beginUpdates()
            defer {
                self.tableView.endUpdates()
            }
            let indexs = range.map { IndexPath(item: $0, section: 1) }
            self.tableView.insertRows(at: indexs, with: .none)
        }
    }
    
// MARK: - Handler Event
    func setupRX() {
        showLoading(use: self.listener?.loadingProgress)
        
        self.rx.methodInvoked(#selector(viewDidAppear(_:))).observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (_, wSelf) in
            wSelf.listener?.requestNumberOrderProcessing()
        })).disposed(by: disposeBag)
        
        self.listener?.error.map { $0.getMsg() }.bind(onNext: weakify({ (message, wSelf) in
            AlertVC.showError(for: wSelf, message: message)
        })).disposed(by: disposeBag)

        mRefreshControl.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.mRefreshControl.beginRefreshing()
            wSelf.listener?.refresh()
        })).disposed(by: disposeBag)
        
        headerView.btnBack?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.foodMoveBack()
        })).disposed(by: disposeBag)
        
        listener?.quoteCart.bind(onNext: weakify({ (old, wSelf) in
            wSelf.quoteCartView?.isHidden = old == nil || old?.itemsCount == 0
            wSelf.lblNumberItemQuoteCard?.text = "\(old?.itemsCount ?? 0)"
        })).disposed(by: disposeBag)
        
        self.quoteCartView?.rx.controlEvent(.touchUpInside).bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToCheckOut()
        })).disposed(by: disposeBag)
        
        listener?.listHighCommission.bind(to: sourceHighCommission).disposed(by: disposeBag)
        listener?.whatsTodays.bind(to: sourceWhatsToday).disposed(by: disposeBag)
        listener?.banners.bind(to: sourceBanners).disposed(by: disposeBag)
        listener?.categories.bind(to: sourceCategories).disposed(by: disposeBag)
        listener?.news.bind(to: sourceNews).disposed(by: disposeBag)
        listener?.nearest.bind(to: sourceNearest).disposed(by: disposeBag)
        listener?.familarShops.bind(to: sourceFamiliarShops).disposed(by: disposeBag)
        listener?.freeShipShops.bind(to: sourceFreeShipShops).disposed(by: disposeBag)
        
        listener?.discovery.bind(onNext: weakify({ (event, wSelf) in
            wSelf.update(event: event)
        })).disposed(by: disposeBag)
        
        Observable.combineLatest([sourceBanners.map { $0.isEmpty },
                                  sourceCategories.map { $0.isEmpty },
                                  sourceNews.map { $0.isEmpty },
                                  sourceNearest.map { $0.isEmpty },
                                  sourceFamiliarShops.map { $0.isEmpty },
                                  sourceFreeShipShops.map { $0.isEmpty },
                                  sourceWhatsToday.map { $0.isEmpty },
                                  sourceHighCommission.map { $0.isEmpty }])
            .skip(1)
            .distinctUntilChanged()
            .bind(onNext: weakify({ (list, wSelf) in
                let show = list.reduce(true, { $0 && $1 })
                show ? wSelf.noItemView.attach() : wSelf.noItemView.detach()
        })).disposed(by: disposeBag)
        
        Observable.merge(sourceBanners.map ({ _ in FoodDisplayType.banner}),
                         sourceCategories.map ({ _ in FoodDisplayType.category }),
                         sourceNews.map ({ _ in FoodDisplayType.news }),
                         sourceNearest.map ({ _ in FoodDisplayType.nearest }),
                         sourceFamiliarShops.map ({ _ in FoodDisplayType.familiarShop }),
                         sourceFreeShipShops.map ({ _ in FoodDisplayType.freeShipShop }),
                         sourceWhatsToday.map ({ _ in FoodDisplayType.whatstoday }),
                         sourceHighCommission.map ({ _ in FoodDisplayType.highCommission }))
            .observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (type, wSelf) in
                wSelf.tableView.reloadRows(at: [IndexPath(item: type.rawValue, section: 0)], with: .fade)
            })).disposed(by: disposeBag)
        
        listener?.originAddress.bind(onNext: weakify({ (address, wSelf) in
            wSelf.headerView.setupDisplay(item: address)
        })).disposed(by: disposeBag)
        
        headerView.btnSearchAddress?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToSearchLocation()
        })).disposed(by: disposeBag)
        setupAnimateQuouteCart()
    }
    
    private func setupAnimateQuouteCart() {
        let eHidden0 = tableView.rx.willBeginDragging.map {
            return true
        }
        
        let eHidden1 = tableView.rx.didEndDragging.map { (decelerating) -> Bool? in
            guard !decelerating else { return nil }
            return false
        }.filterNil()
        
        let eHidden2 = tableView.rx.didEndDecelerating.map {
            return false
        }
        
        let animateBlock: (Bool) -> Void = { [weak self] hidden in
            guard let wSelf = self else { return }
            let alpha: CGFloat = hidden ? 0 : 1
            let transform: CGAffineTransform = hidden ? CGAffineTransform(scaleX: 0, y: 0) : .identity
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState, .allowAnimatedContent], animations: {
                wSelf.quoteCartView?.alpha = alpha
                wSelf.quoteCartView?.transform = transform
            }, completion: nil)
        }
        
        Observable.merge([eHidden0, eHidden1, eHidden2])
            .bind(onNext: animateBlock)
            .disposed(by: disposeBag)
    }
}


