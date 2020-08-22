//  File name   : TicketListHistoryVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import VatoNetwork

typealias TicketHistoryType = TicketDetailModel
protocol TicketListHistoryHandlerProtocol: AnyObject {
    var userId: Int { get }
    func requestList(params: [String: Any]) -> Observable<ResponsePaging<TicketHistoryType>>
    func select(item: TicketHistoryType)
    func option(item: TicketHistoryType, type: TicketHistory)
    func detailRoute(item: TicketHistoryType)
}

protocol TicketListHistoryRemoveProtocol: UIViewController {
    var type: TicketHistory { get }
    func remove(item: TicketHistoryType)
    func refresh()
}

extension TicketHistoryType: HistoryDetailDisplay {
    var originPriceHistory: Int64? {
        return self.originPrice
    }
    var seatDiscountsHistory: [Double]? {
        return self.seatDiscounts ?? []
    }
    var seatIdsHistory: [Int32]? {
        return self.seatIds ?? []
    }
    var cardFee: String? {
        return (self.card_fee ?? 0).currency
    }
    
    var paymentCardType: PaymentCardType? {
        guard let paymentMethod = self.paymentMethod else { return nil }
        return PaymentCardType(rawValue: paymentMethod)
    }
    
    var ticketsCode: String? {
        return code
    }
    
    var userName: String? {
        return self.passengers?.first?.custName
    }
    var phone: String? {
        return self.passengers?.first?.custMobile
    }
    var routName: String? {
        return self.routeName
    }
    
    var time: String? {
        return "\(self.departureTime ?? "") \(self.departureDate ?? "")"
    }
    
    var pickupAddress: String? {
        return self.pickUpStreet
    }
    
    var pickup: String? {
        return self.pickUpName
    }
    
    var numberSeats: String? {
        return "\(self.seatIds?.count ?? 0)"
    }
    
    var seatsName: String? {
        return self.seatNames?.joined(separator: ",")
    }
    
    var priceStr: String? {
        return self.price?.currency
    }
    
    var totalPriceStr: String? {
        return self.total_price?.currency
    }
    
    var timeExpiredPaymentStr: String? {
        var padding = ((self.timeExpiredPayment ?? 0) - FireBaseTimeHelper.default.currentTime) // milisecond to hour
        padding = max(padding, 0)
        let hour = padding/3600000
        // if hour >=1 => only caculate hour
        // else caculate minute
        if hour >= 1 {
            let str = String(format: Text.formatHours.localizedText, "\(Int(hour))")
            return str
        }
        // caculate minute
        let minute = padding/60000
        let str = String(format: Text.formatMinute.localizedText, "\(Int(minute))")
        return str
        
    }
    
}

final class TicketListHistoryVC: UITableViewController, ActivityTrackingProtocol, TicketListHistoryRemoveProtocol, SafeAccessProtocol {
    /// Class's public properties.
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    weak var listener: TicketListHistoryHandlerProtocol?
    private var source: [TicketHistoryType] = [] {
        didSet {
            source.isEmpty ? noItemView.attach() : noItemView.detach()
        }
    }
    private var update: ReplaySubject<ListUpdate<TicketHistoryType>> = ReplaySubject.create(bufferSize: 1)
    private var paging: Paging = .default
    private lazy var disposeBag = DisposeBag()
    var type: TicketHistory = .none
    private var loading: Bool = false
    private lazy var noItemView = NoItemView(imageName: "empty", message: Text.donotHaveTicket.localizedText, on: tableView)
    private var disposeRequest: Disposable?
    private lazy var mRefreshControl: UIRefreshControl = {
        let f = UIRefreshControl(frame: .zero)
        return f
    }()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        requestList()
    }
    
    func refresh() {
        self.mRefreshControl.beginRefreshing()
        self.paging = .default
        requestList()
    }
    
    private func setupRX() {
        mRefreshControl.rx.controlEvent(.valueChanged).bind { [weak self](_) in
            self?.refresh()
        }.disposed(by: disposeBag)
        
        indicator.asObservable()
            .observeOn(MainScheduler.instance)
            .bind(onNext: weakify({ (load, wSelf) in
                wSelf.loading = load
                load ? LoadingManager.showProgress() : LoadingManager.dismissProgress()
            })).disposed(by: disposeBag)
        
        update.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (event, wSelf) in
            wSelf.update(event: event)
        })).disposed(by: disposeBag)
    }
    
    
    private func update(event: ListUpdate<TicketHistoryType>) {
        if self.mRefreshControl.isRefreshing {
            self.mRefreshControl.endRefreshing()
        }
        
        switch event {
        case let .reload(items):
            excute { self.source = items }
            self.tableView?.reloadData()
        case let .update(items):
            let before = self.source.count
            excute { self.source += items }
            let range = (before ..< (items.count + before))
            guard !range.isEmpty else { return }
            self.tableView?.beginUpdates()
            defer {
                self.tableView?.endUpdates()
            }
            let indexs = range.map { IndexPath(item: $0, section: 0) }
            self.tableView?.insertRows(at: indexs, with: .bottom)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    
    deinit {
        disposeRequest?.dispose()
    }
}

extension TicketListHistoryVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let idx = indexPaths.last?.item else { return }
        let total = excute(block: { return source.count })
        guard total - idx <= 10 else { return }
        requestList()
    }
}

// MARK: View's event handlers
extension TicketListHistoryVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func remove(item: TicketHistoryType) {
        guard let idx: Int = excute (block: {
            var source = self.source
            guard let idx = source.firstIndex(where: { $0.code == item.code }) else {
                return nil
            }
            source.remove(at: idx)
            self.source = source
            return idx
        }) else { return }
        self.tableView?.beginUpdates()
        defer {
            self.tableView?.endUpdates()
        }
        self.tableView.deleteRows(at: [IndexPath(item: idx, section: 0)], with: .fade)
    }
}

// MARK: Class's private methods
private extension TicketListHistoryVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        self.tableView.addSubview(mRefreshControl)
        self.tableView.prefetchDataSource = self
    }
    
    func requestList() {
        guard paging.page == 0 || !loading else {
            return
        }
        
        guard let next = paging.next else {
            return
        }
        disposeRequest?.dispose()
        let isFirst = next.first
        var params: [String: Any] = [:]
        params["page"] = next.page
        params["pageSize"] = next.size
        params["type"] = type.value
        params["userId"] = listener?.userId
        disposeRequest = listener?
            .requestList(params: params)
            .trackActivity(indicator)
            .subscribe(onNext: weakify({ (res, wSelf) in
            wSelf.paging = Paging(page: res.currentPage, canRequest: res.next, size: next.size)
            if isFirst {
                wSelf.update.onNext(.reload(items: res.data ?? []))
            } else {
                wSelf.update.onNext(.update(items: res.data ?? []))
            }
        }), onError: { [weak self] (e) in
            guard let wSelf = self else { return }
            if isFirst {
                wSelf.update.onNext(.reload(items: []))
            } else {
                wSelf.update.onNext(.update(items:[]))
            }
        })
    }

    /// Initialize cell at index.
    ///
    /// - Parameters:
    /// - cell {UITableViewCell} (a UITableView's cell according to index)
    /// - indexPath {IndexPath} (a cell's index)
    private func configure(forCell cell: TicketHistoryTVC, indexPath index: IndexPath) {
        // todo: Configure cell here.
        let item = source[index.item]
        cell.setupDislay(for: item, type: type)
        cell.btnOption?.tag = index.item
        cell.btnOption?.addTarget(self, action: #selector(tapBySelectOption(_:)), for: .touchUpInside)
        cell.btnDetailRoute?.rx.tap.takeUntil(cell.rx.methodInvoked(#selector(TicketHistoryTVC.prepareForReuse))).bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.detailRoute(item: item)
        })).disposed(by: disposeBag)
    }
    
    @objc func tapBySelectOption(_ button: UIButton?) {
        guard let id = button?.tag, let item = source[safe: id] else { return }
        self.listener?.option(item: item, type: type)
    }
}

// MARK: UITableViewDataSource's members
extension TicketListHistoryVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TicketHistoryTVC.dequeueCell(tableView)
        configure(forCell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: UITableViewDelegate's members
extension TicketListHistoryVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = source[indexPath.item]
        listener?.select(item: item)
    }
}
