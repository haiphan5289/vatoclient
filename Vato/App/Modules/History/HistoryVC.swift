//  File name   : HistoryVC.swift
//
//  Author      : vato.
//  Created date: 12/23/19
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
import VatoNetwork

enum HistoryDetailItemType {
    case trip(id: String)
    case express(id: String)
    case food(order: SalesOrder)
    case preorder(order: SalesOrder)
}

enum HistoryItemType: Int, CaseIterable, StoreCategoryDisplayProtocol {
    var name: String? {
        switch self {
        case .booking:
            return Text.booking.localizedText.uppercased()
        case .expressUrBan:
            return FwiLocale.localized("Giao hàng nội thành").uppercased()
        case .expressDomestic:
            return FwiLocale.localized("Giao hàng liên tỉnh").uppercased()
        case .food:
            return FwiLocale.localized("Đồ ăn & Cửa hàng").uppercased()
        case .supply:
            return Text.vatoSupply.localizedText.uppercased()
        default:
            return nil
        }
    }
    
    case booking
    case expressUrBan
    case expressDomestic
    case supply
    case food
    case busline
    
    static var allCases: [HistoryItemType] {
        #if DEBUG
        return [.booking, .expressUrBan, .expressDomestic, .supply, .food]
        #elseif STAGING
        return [.booking, .expressUrBan, .food]
        #else
        return [.booking, .expressUrBan, .food]
        #endif
    }
}

protocol HistoryRequestProtocol {
    var authenticated: AuthenticatedStream { get }
    func request<T: Codable>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T>
}

protocol HistoryListenerProtocol: AnyObject, HistoryRequestProtocol {
    var error: Observable<MerchantState> { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    var selectedType: Observable<HistoryItemType> { get }
    
    func detail(item: HistoryDetailItemType)
    func history(hiddenBottomLine: Bool)
    func historyDismiss()
    func report(tripCode: String, service: String)
    func historyMoveHome()
}

protocol HistoryPresentableListener: HistoryListenerProtocol {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class HistoryVC: UIViewController, HistoryPresentable, HistoryViewControllable, DisposableProtocol, LoadingAnimateProtocol {
    private struct Config {
        static let hTopView: CGFloat = 100
        static let title = Text.tabbarHistory.localizedText
    }
    
    /// Class's public properties.
    weak var listener: HistoryPresentableListener?
    private lazy var btnDismiss: UIButton = UIButton(frame: .zero)
    private lazy var selectCategoryView = StoreSelectCategoryView(frame: .zero)
    private lazy var pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    private var controllers = [UIViewController]()
    private var current: Int = 0 {
        didSet {
            bottomLine?.isHidden = false
        }
    }
    private var bottomLine: UIView?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        UIApplication.setStatusBar(using: .lightContent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension HistoryVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension HistoryVC {
    func history(hiddenBottomLine: Bool) {
        bottomLine?.isHidden = hiddenBottomLine
    }
}

// MARK: Class's private methods
private extension HistoryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        title = Text.tabbarHistory.localizedText
        view.clipsToBounds = true
        if self.tabBarController == nil {
            let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
            let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
            button.setImage(image, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
            let leftBarButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = leftBarButton
            self.navigationItem.leftBarButtonItem = leftBarButton
            let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
            btn.setImage(UIImage(named: "ic_close_vato"), for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
            let rightView = UIBarButtonItem(customView: btn)
            self.navigationItem.rightBarButtonItem = rightView
            
            button.rx.tap.bind { [weak self] in
                self?.listener?.historyDismiss()
            }.disposed(by: disposeBag)
            
            btn.rx.tap.bind { [weak self] in
                self?.listener?.historyMoveHome()
            }.disposed(by: disposeBag)
        }
        
        
        //        let edge = UIApplication.shared.keyWindow?.edgeSafe ?? .zero
        //        let heightMax = edge.top + Config.hTopView
        
        let viewTop = UIView(frame: .zero)
        viewTop >>> view >>> {
            $0.backgroundColor = .white
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
        }
        
        selectCategoryView >>> viewTop >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.left.equalTo(-3)
                make.right.equalToSuperview()
                make.bottom.equalTo(-16)
                make.height.equalTo(40)
            }
        }
        selectCategoryView.setupDisplay(item: HistoryItemType.allCases)
        DispatchQueue.main.async {
            self.selectCategoryView.select(at: 0)
        }
        
        bottomLine = viewTop.addSeperator()
        pageVC.view >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(viewTop.snp.bottom)
            }
        }
        
        self.addChild(pageVC)
        pageVC.didMove(toParent: self)
        setupChildsController()
    }
    
    private func setupChildsController() {
        
        // Booking
        let bookingVC = BookingHistoryViewController()
        bookingVC.historyItemType = .booking
        bookingVC.listener = listener
        controllers.append(bookingVC)
        
        // expressUrBan
        let expressUrBanVC = BookingHistoryViewController()
        expressUrBanVC.historyItemType = .expressUrBan
        expressUrBanVC.listener = listener
        
        controllers.append(expressUrBanVC)
        
        #if DEBUG
        // expressDomestic
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        var historyExpressVC = HistoryExpressVC()
        if let vc = storyboard.instantiateViewController(withIdentifier: "HistoryExpressVC") as? HistoryExpressVC {
            historyExpressVC = vc
        }
        historyExpressVC.listener = listener
        controllers.append(historyExpressVC)
        
        
        let shoppingVC = BookingHistoryViewController()
        shoppingVC.historyItemType = .supply
        shoppingVC.listener = listener
        controllers.append(shoppingVC)
        // food
        let foodVC = FoodHistoryViewController()
        foodVC.historyItemType = .food
        foodVC.listener = listener
        controllers.append(foodVC)
        #else
        let foodVC = FoodHistoryViewController()
        foodVC.historyItemType = .food
        foodVC.listener = listener
        controllers.append(foodVC)
        #endif
        
        // Set
        pageVC.setViewControllers([controllers[0]], direction: .forward, animated: false, completion: nil)
    }
    
    private func setupRX() {
        showLoading(use: listener?.loadingProgress)
        self.listener?.error.map { $0.getMsg() }.bind(onNext: weakify({ (message, wSelf) in
            AlertVC.showError(for: wSelf, message: message)
        })).disposed(by: disposeBag)
        
        selectCategoryView.selected.bind(onNext: weakify({ (idx, wSelf) in
            wSelf.selected(idx: idx)
        })).disposed(by: disposeBag)
        
        btnDismiss.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.historyDismiss()
        })).disposed(by: disposeBag)
        
        guard let listener = self.listener else { return }
        
        let e1 = listener.selectedType.take(1)
        let e2 = self.rx.methodInvoked(#selector(viewDidAppear(_:))).take(1)
        
        Observable.zip(e1, e2) { (type, _) -> HistoryItemType in
            return type
        }.bind(onNext: weakify({ (type, wSelf) in
            guard let idx = HistoryItemType.allCases.index(of: type) else { return }
            wSelf.selectCategoryView.select(at: idx)
            wSelf.pageVC.setViewControllers([wSelf.controllers[idx]], direction: .forward, animated: false, completion: nil)
        })).disposed(by: disposeBag)
    }
    
    private func selected(idx: Int) {
        guard current != idx else {
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = idx > current ? .forward : .reverse
        guard let vc = controllers[safe: idx] else {
            return
        }
        current = idx
        pageVC.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    }
}
