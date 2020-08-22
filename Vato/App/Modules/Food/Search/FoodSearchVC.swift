//  File name   : FoodSearchVC.swift
//
//  Author      : Dung Vu
//  Created date: 11/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCore
import FwiCoreRX
import SnapKit
import RxSwift
import RxCocoa

protocol FoodSearchPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var tags: Observable<[String]> { get }
    var keywordsHistory: Observable<[String]> { get }
    var search: Observable<ListUpdate<FoodExploreItem>> { get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    
    func foodSearchMoveBack()
    func search(keyword: String?)
    func refreshSearch()
    func requestNextSearch()
    func routeToDetail(item: FoodExploreItem)
}

final class FoodSearchVC: UIViewController, FoodSearchPresentable, FoodSearchViewControllable {
    private struct Config {
        static let headerSearch = "Tìm kiếm gần đây"
    }
    
    /// Class's public properties.
    weak var listener: FoodSearchPresentableListener?
    internal lazy var disposeBag = DisposeBag()
    private lazy var tableViewHistory: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.backgroundColor = .white
        t.separatorStyle = .none
        return t
    }()
    
    private lazy var tableViewResult: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .white
        t.separatorStyle = .none
        return t
    }()
    private var headerView: FoodSearchHeaderView?
    private lazy var sourceSearch: BehaviorRelay<[FoodExploreItem]> = BehaviorRelay(value: [])
    private lazy var sourceHistory: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    
    private lazy var noItemView = NoItemView(imageName: "ic_food_noItem", message: Text.noStoreFound.localizedText, on: tableViewResult)

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
        localize()
        headerView?.textField?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView?.textField?.resignFirstResponder()
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension FoodSearchVC: LoadingAnimateProtocol, DisposableProtocol {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FoodSearchVC {
}

extension FoodSearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView === tableViewHistory else { return nil }
        let headerView = UIView(frame: .zero)
        let label = UILabel(frame: .zero)
        label >>> headerView >>> {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            $0.textColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
            $0.text = Config.headerSearch
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(16)
                make.bottom.equalToSuperview()
                make.right.equalTo(-16)
            })
        }
        headerView.clipsToBounds = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView === tableViewHistory else { return 0.1 }
        let h: CGFloat = sourceHistory.value.isEmpty ? 0.1 : 30
        return h
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let c = cell as? LazyDisplayImageProtocol else { return }
        DispatchQueue.main.async {
            c.displayImage()
        }
    }
    
}

extension FoodSearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceSearch.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodGenericTVC<FoodDiscoveryView>.identifier) as? FoodGenericTVC<FoodDiscoveryView> else {
            fatalError("Please Implement")
        }
        let item = sourceSearch.value[indexPath.item]
        cell.setupDisplay(item: item)
        return cell
    }
    
}

extension FoodSearchVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let idx = indexPaths.last else {
            return
        }
        
        let range = sourceSearch.value.count - idx.item
        guard 0...10 ~= range else { return }
        listener?.requestNextSearch()
    }
}

// MARK: Class's private methods
private extension FoodSearchVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        
        navigationItem.setHidesBackButton(true, animated: true)
        let headerView = FoodSearchHeaderView.loadXib()
        headerView >>> {
            $0.snp.makeConstraints({ (make) in
                make.size.equalTo(CGSize(width: UIScreen.main.bounds.width, height: 44))
            })
        }
        
        headerView.btnBack?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.foodSearchMoveBack()
        })).disposed(by: disposeBag)
        
        navigationItem.titleView = headerView
        view.backgroundColor = .white
        self.headerView = headerView
        
        tableViewHistory >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(0)
            })
        }
        
        tableViewResult >>> view >>> {
            $0.isHidden = true
            $0.estimatedRowHeight = 200
            $0.rowHeight = UITableView.automaticDimension
            $0.snp.makeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(0)
            })
        }
        tableViewResult.keyboardDismissMode = .onDrag
        tableViewResult.register(FoodGenericTVC<FoodDiscoveryView>.self, forCellReuseIdentifier: FoodGenericTVC<FoodDiscoveryView>.identifier)
        tableViewResult.addSubview(mRefreshControl)
        tableViewResult.prefetchDataSource = self
        tableViewHistory.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
    }
    
    private func update(event: ListUpdate<FoodExploreItem>) {
        if self.mRefreshControl.isRefreshing {
            self.mRefreshControl.endRefreshing()
        }
        
        switch event {
        case let .reload(items):
            sourceSearch.accept(items)
            self.tableViewResult.reloadData()
        case let .update(items):
            let before = self.sourceSearch.value
            let after = before + items
            sourceSearch.accept(after)
            let range = (before.count ..< after.count)
            guard !range.isEmpty else { return }
            self.tableViewResult.beginUpdates()
            defer {
                self.tableViewResult.endUpdates()
            }
            let indexs = range.map { IndexPath(item: $0, section: 0) }
            self.tableViewResult.insertRows(at: indexs, with: .bottom)
        }
    }
    
    func setupTagsView(items: [String]) {
        guard !items.isEmpty else {
            tableViewHistory.tableHeaderView = nil
            return
        }
        
        let tagsView = FoodSearchTagsView(frame: .zero)
        let size = tagsView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        tagsView.frame = CGRect(origin: .zero, size: size)
        tableViewHistory.tableHeaderView = tagsView
        tagsView.setupDisplay(item: items)
        
        tagsView.selectedTag.bind(onNext: weakify({ (keyword, wSelf) in
            wSelf.headerView?.textField?.text = keyword
            wSelf.headerView?.textField?.sendActions(for: .valueChanged)
        })).disposed(by: disposeBag)
    }
    
    func setupRX() {
        showLoading(use: listener?.loadingProgress)
        tableViewHistory.rx.setDelegate(self).disposed(by: disposeBag)
        tableViewResult.rx.setDelegate(self).disposed(by: disposeBag)
        tableViewResult.rx.setDataSource(self).disposed(by: disposeBag)
        headerView?.textField?.rx.text.map({ (t) -> Bool in
            let t = t ?? ""
            return !t.isEmpty
        }).bind(onNext: weakify({ (hasText, wSelf) in
            wSelf.tableViewHistory.isHidden = hasText
            wSelf.tableViewResult.isHidden = !hasText
        })).disposed(by: disposeBag)
        
        headerView?.textField?.rx.text
            .distinctUntilChanged()
            .debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.instance).bind(onNext: weakify({ (keyword, wSelf) in
            wSelf.listener?.search(keyword: keyword)
        })).disposed(by: disposeBag)
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] in
            let h = $0.height
            UIView.animate(withDuration: $0.duration) {
                self?.tableViewHistory.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-h)
                })
                
                self?.tableViewResult.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-h)
                })
            }
        }.disposed(by: disposeBag)
        
        listener?.tags.bind(onNext: weakify({ (tags, wSelf) in
            wSelf.setupTagsView(items: tags)
        })).disposed(by: disposeBag)
        
        listener?.search.bind(onNext: weakify({ (event, wSelf) in
            wSelf.update(event: event)
        })).disposed(by: disposeBag)
        
        listener?.keywordsHistory.bind(to: sourceHistory).disposed(by: disposeBag)
        
        mRefreshControl.rx.controlEvent(.valueChanged).bind(onNext: weakify({ (wSelf) in
            wSelf.mRefreshControl.beginRefreshing()
            wSelf.listener?.refreshSearch()
        })).disposed(by: disposeBag)
        
        sourceHistory.bind(to: tableViewHistory.rx.items(cellIdentifier: UITableViewCell.identifier, cellType: UITableViewCell.self)) { idx, element, cell in
            cell.selectionStyle = .none
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            cell.textLabel?.textColor = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
            cell.textLabel?.text = element
        }.disposed(by: disposeBag)
        
        tableViewHistory.rx.itemSelected.map ({ [weak self] idx -> String? in
            self?.sourceHistory.value[safe: idx.item]
        }).filterNil().bind(onNext: weakify({ (keyword, wSelf) in
            wSelf.headerView?.textField?.text = keyword
            wSelf.headerView?.textField?.sendActions(for: .valueChanged)
        })).disposed(by: disposeBag)
        
        tableViewResult.rx.itemSelected.map ({ [weak self] idx -> FoodExploreItem? in
            self?.sourceSearch.value[safe: idx.item]
        }).filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.listener?.routeToDetail(item: item)
        })).disposed(by: disposeBag)
        
        
        sourceSearch.map { return $0.isEmpty }.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (isEmpty, wSelf) in
            isEmpty ? wSelf.noItemView.attach() : wSelf.noItemView.detach()
        })).disposed(by: disposeBag)
    }
}
