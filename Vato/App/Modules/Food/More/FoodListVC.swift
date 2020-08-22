//  File name   : FoodListVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/5/19
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


protocol FoodListPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var items: Observable<ListUpdate<FoodExploreItem>> { get }
    var quoteCart: Observable<QuoteCart?> { get }
    
    func refresh()
    func loadNext()
    func foodListMoveBack()
    func routeToDetail(item: FoodExploreItem)
    func routeToCheckOut()
}

final class FoodListVC: UIViewController, FoodListPresentable, FoodListViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: FoodListPresentableListener?
    var type: FoodListType = .none
    private lazy var disposeBag = DisposeBag()
    private lazy var mSource: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    var lblNumberItemQuoteCard: UILabel?
    var quoteCartView: VatoGuideControl?
    
    private lazy var tableView: UITableView = {
       let t = UITableView(frame: .zero, style: .plain)
       t.separatorStyle = .none
       t.estimatedRowHeight = 200
       t.rowHeight = UITableView.automaticDimension
       return t
    }()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .lightContent)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        localize()
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension FoodListVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension FoodListVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let idx = indexPaths.last else {
            return
        }
        
        let range = mSource.value.count - idx.item
        guard 0...10 ~= range else { return }
        listener?.loadNext()
    }
}

// MARK: Class's public methods
extension FoodListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mSource.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodDiscoveryView>.identifier) as? FoodGenericTVC<FoodDiscoveryView> else {
            fatalError("Please Implement")
        }
        let item = mSource.value[indexPath.item]
        cell.setupDisplay(item: item)
        return cell
    }
}

extension FoodListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let c = cell as? LazyDisplayImageProtocol else { return }
        DispatchQueue.main.async {
            c.displayImage()
        }
    }
}

// MARK: Class's private methods
private extension FoodListVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func update(event: ListUpdate<FoodExploreItem>) {
        if self.mRefreshControl.isRefreshing {
            self.mRefreshControl.endRefreshing()
        }
        
        switch event {
        case let .reload(items):
            self.mSource.accept(items)
            self.tableView.reloadData()
        case let .update(items):
            let before = self.mSource.value
            let after = before + items
            self.mSource.accept(after)
            let range = (before.count ..< after.count)
            guard !range.isEmpty else { return }
            self.tableView.beginUpdates()
            defer {
                self.tableView.endUpdates()
            }
            let indexs = range.map { IndexPath(item: $0, section: 0) }
            self.tableView.insertRows(at: indexs, with: .fade)
        }
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
        title = self.type.title
        if self.tabBarController == nil {
            let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
            let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
            button.setImage(image, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
            let leftBarButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = leftBarButton
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            UIApplication.setStatusBar(using: .lightContent)
            
            button.rx.tap.bind { [weak self] in
                self?.listener?.foodListMoveBack()
            }.disposed(by: disposeBag)
        }
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        tableView.register(FoodGenericTVC<FoodDiscoveryView>.self, forCellReuseIdentifier: FoodGenericTVC<FoodDiscoveryView>.identifier)
        tableView.prefetchDataSource = self
        tableView.addSubview(mRefreshControl)
        
        createQuoteView()
        self.quoteCartView?.isHidden = true
    }
    
    func setupRX() {
        tableView.rx.setDataSource(self).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        listener?.items.bind(onNext: weakify({ (event, wSelf) in
            wSelf.update(event: event)
        })).disposed(by: disposeBag)
        
        mRefreshControl.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.mRefreshControl.beginRefreshing()
            wSelf.listener?.refresh()
        })).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map { [weak self](idx) -> FoodExploreItem? in
            self?.mSource.value[safe: idx.item]
        }.filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.listener?.routeToDetail(item: item)
        })).disposed(by: disposeBag)
        
        listener?.quoteCart.bind(onNext: weakify({ (old, wSelf) in
            wSelf.quoteCartView?.isHidden = old == nil || old?.itemsCount == 0
            wSelf.lblNumberItemQuoteCard?.text = "\(old?.itemsCount ?? 0)"
        })).disposed(by: disposeBag)
        
        quoteCartView?.rx.controlEvent(.touchUpInside).bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToCheckOut()
        })).disposed(by: disposeBag)
        
        setupHiddenBasketIfNeeded()
    }
    
    private func setupHiddenBasketIfNeeded() {
        var mhide: Bool = false
        func search(hidden hide: Bool) {
            guard mhide != hide else {
                return
            }
            mhide = hide
            let alpha: CGFloat = hide ? 0 : 1
            let transform: CGAffineTransform = mhide ? CGAffineTransform(scaleX: 0, y: 0) : .identity
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState, .allowAnimatedContent], animations: {
                self.quoteCartView?.alpha = alpha
                self.quoteCartView?.transform = transform
            }, completion: nil)
        }
        
        tableView.rx.didEndDragging.bind(onNext: weakify({ (decelerating, wSelf) in
            guard !decelerating else { return }
            search(hidden: false)
        })).disposed(by: disposeBag)
        
        let e1 = tableView.rx.willBeginDragging.map {
            return true
        }
        let e2 = tableView.rx.didEndDecelerating.map {
            return false
        }
        
        Observable.merge([e1, e2]).bind(onNext: weakify({ (show, wSelf) in
           search(hidden: show)
        })).disposed(by: disposeBag)
    }
}

// MARK: Quote cart
extension FoodListVC: QuoteCartProtocol {
    var containerView: UIView {
        return self.view
    }
}
