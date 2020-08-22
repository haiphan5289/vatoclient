//  File name   : WalletListHistoryInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import VatoNetwork

import FwiCoreRX
import FwiCore

protocol WalletListHistoryRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func showDetail(by item: WalletItemDisplayProtocol)
}

protocol WalletListHistoryPresentable: Presentable {
    var listener: WalletListHistoryPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol WalletListHistoryListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func listDetailMoveBack()
}


struct WalletListHistoryUpdate {
    let from: Int
    let to: Int
    let source: [WalletListHistorySection]
}

final class WalletListHistoryInteractor: PresentableInteractor<WalletListHistoryPresentable>, WalletListHistoryInteractable, WalletListHistoryPresentableListener, ActivityTrackingProgressProtocol, LoadingAnimateProtocol {
    var eLoading: Observable<Bool> {
        return indicator.asObservable()
    }
    weak var router: WalletListHistoryRouting?
    weak var listener: WalletListHistoryListener?
    let authenticated: AuthenticatedStream
    private var currentPage: Int = 0
    private var canLoadMore: Bool = true {
        didSet {
            guard canLoadMore else {
                return
            }
            // Update next
            currentPage += 1
        }
    }
    
    var eUpdate: Observable<WalletListHistoryUpdate> {
        return _eUpdate.observeOn(MainScheduler.asyncInstance)
    }
    
    private var source = [WalletListHistorySection]()
    private lazy var _eUpdate = PublishSubject<WalletListHistoryUpdate>()
    private lazy var indicator = ActivityIndicator()
    private var isLoading: Bool = false
    private let balanceType: Int
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: WalletListHistoryPresentable, authenticated: AuthenticatedStream, balanceType: Int) {
        self.authenticated = authenticated
        self.balanceType = balanceType
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        setupRX()
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }
    
    private func setupRX() {
        self.eLoadingObser.bind(onNext: { [weak self] (loading, percent) in
            self?.isLoading = loading
        }).disposeOnDeactivate(interactor: self)
        showLoading(use: eLoadingObser)
    }
    
    func moveBack() {
        self.listener?.listDetailMoveBack()
    }
    
    func showDetail(by item: WalletItemDisplayProtocol) {
        router?.showDetail(by: item)
    }
    
    func detailHistoryMoveBack() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
    
    struct Config {
        static let limitdays: Double = 2505600000
    }
    
    private func update(from list: [WalletTransactionItem]?) {
        guard let list = list else {
            return
        }
        let lastSectionIndex = self.source.count - 1
        var next = lastSectionIndex
        let last = self.source.last
        var temp: WalletListHistorySection? = last
        list.forEach { (item) in
            do {
                if temp == nil {
                    throw ListHistorySection.notExists
                }
                
                try temp?.add(from: item)
                temp?.needReload = temp == last
                
            } catch {
                let new = WalletListHistorySection(by: item)
                self.source.append(new)
                next += 1
                temp = new
            }
        }
        
        let value = WalletListHistoryUpdate(from: lastSectionIndex, to: next, source: self.source)
        _eUpdate.onNext(value)
    }
    
    func requestData() {
        disposableNext?.dispose()
        self.requestListTransactions()
            .catchErrorJustReturn(nil)
            .trackProgressActivity(self.indicator)
            .filterNil()
        .bind { [weak self](r) in
            self?.update(from: r.transactions)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private var disposableNext: Disposable?
    func update() {
        guard !isLoading, canLoadMore else {
            return
        }
        
        disposableNext?.dispose()
        disposableNext = self.requestListTransactions()
            .catchErrorJustReturn(nil)
            .trackProgressActivity(self.indicator)
            .filterNil()
            .bind { [weak self](r) in
                self?.update(from: r.transactions)
        }
    }
    
    func refresh() {
        self.source = []
        self.canLoadMore = true
        self.currentPage = 0
        
        self.requestData()
    }
    
    private func requestListTransactions() -> Observable<WalletTransactionsHistoryResponse?> {
        guard canLoadMore else {
            return Observable.empty()
        }
        let to = Date().timeIntervalSince1970 * 1000
        let from = to - Config.limitdays
        let p = currentPage
        let balanceType = self.balanceType
        let router = authenticated.firebaseAuthToken.take(1)
            .timeout(0.3, scheduler: MainScheduler.asyncInstance)
            .map({
                VatoAPIRouter.userTransactions(authToken: $0, fromDate: UInt64(from), toDate: UInt64(to), page: p, size: 10, balanceType: balanceType)
            })
        
        let request = router.flatMap ({ r -> Observable<(HTTPURLResponse, OptionalMessageDTO<WalletTransactionsHistoryResponse>)> in
            Requester.requestDTO(using: r)
        }).map { item -> WalletTransactionsHistoryResponse? in
            return item.1.data
        }.do(onNext: { [weak self](r) in
            self?.canLoadMore = r?.more ?? false
        }, onError: { [weak self](e) in
            self?.canLoadMore = false
            printDebug(e.localizedDescription)
        })
        return request
    }
    
    var eLoadingObser: Observable<(Bool, Double)> {
        return indicator.asObservable().observeOn(MainScheduler.asyncInstance)
    }
}
