//  File name   : WalletHistoryTableView.swift
//
//  Author      : Dung Vu
//  Created date: 12/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import RxSwift
import FwiCore
import QuartzCore
import FwiCoreRX

protocol WalletHistoryRequestProtocol: AnyObject {
    func requestListTransactions() -> Observable<[WalletItemDisplayProtocol]>
}

enum WalletHistoryTableAction {
    case list
    case detail(item: WalletDetailHistoryType)
    case refresh
}

final class WalletHistoryTableView: UIView {
    struct Config {
        static let minimumDisplay = 3
    }
    
    /// Class's public properties.
    private weak var interactor: WalletHistoryRequestProtocol?
    private (set)var tableView: UITableView?
    private var dataSource: [WalletItemDisplayProtocol] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    private lazy var disposeBag = DisposeBag()
    private lazy var noItemView = NoItemView(imageName: "notify_noItem",
                                             message: Text.youHaveNoActivities.localizedText,
                                             subMessage: Text.topUpVATOPay.localizedText,
                                             on: self.tableView)
    private lazy var footerView: UIView = createFooterView()
    
//    private lazy var refreshControl: UIRefreshControl = {
//        let r = UIRefreshControl(frame: .zero)
//        self.tableView?.addSubview(r)
//        return r
//    }()
    private (set)lazy var eAction = PublishSubject<WalletHistoryTableAction>()
    private lazy var indicator = ActivityIndicator()
    private var loading: Bool = false
    
    /// Class's private properties.
    init(with interactor: WalletHistoryRequestProtocol?) {
        super.init(frame: .zero)
        self.interactor = interactor
        initialize()
        setupRX()
        requestData()
        NotificationCenter.default.rx.notification(NSNotification.Name.topupSuccess).observeOn(MainScheduler.asyncInstance).bind { [weak self](_) in
            // Refesh
            self?.requestData()
        }.disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestData() {
        self.interactor?.requestListTransactions().do(onError: { (e) in
            printDebug(e.localizedDescription)
        })
            .catchErrorJustReturn([])
            .trackActivity(self.indicator)
            .observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self](items) in
                self?.handle(response: items)
            }).disposed(by: disposeBag)
    }
    
    deinit {
        printDebug("\(#function)")
    }
}


// MARK: Class's private methods
private extension WalletHistoryTableView {
    private func createFooterView() -> UIView {
        let v = UIButton.create {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.frame = CGRect(origin: .zero, size: CGSize(width: self.bounds.width, height: 48))
            $0.backgroundColor = .white
        }
        
        v.setTitleColor(Color.orange, for: .normal)
        v.setTitle(Text.seeMore.localizedText, for: .normal)
        
        v.rx.tap.bind { [weak self] in
            printDebug("More")
            self?.eAction.onNext(.list)
        }.disposed(by: disposeBag)
        
        return v
    }
    
    private func initialize() {
        // todo: Initialize view's here.
        self.backgroundColor = .clear
        self.clipsToBounds = true
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.separatorColor = #colorLiteral(red: 0.8920077682, green: 0.9186214805, blue: 0.943768084, alpha: 1)
        tableView.rowHeight = 64
        tableView.backgroundColor = .clear
        
        tableView >>> self >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        tableView.register(WalletItemTVC.self, forCellReuseIdentifier: WalletItemTVC.identifier)
        tableView.clipsToBounds = false
        self.tableView = tableView
        
//        if #available(iOS 11, *) {
//            tableView.contentInset = UIEdgeInsetsMake(-17, 0, 0, 0)
//        }
//        else {
//            tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
//            //            print(s)
//            self.refreshControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        }
        
        
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
    
    private func handle(response items: [WalletItemDisplayProtocol]) {
        self.dataSource = items
        let c = items.count
        c > 0 ? noItemView.detach() : noItemView.attach()
        let f = c > Config.minimumDisplay ? self.footerView : nil
        self.tableView?.tableFooterView = f
    }
    
    private func setupRX() {
        self.tableView?.rx.setDataSource(self).disposed(by: disposeBag)
        self.tableView?.rx.setDelegate(self).disposed(by: disposeBag)
        
        indicator.asObservable().observeOn(MainScheduler.asyncInstance).bind { [weak self] in
            self?.loading = $0
//            let b: () -> () = $0 ? {} : {
//                self?.refreshControl.endRefreshing()
//            }
//            b()
        }.disposed(by: disposeBag)
        
//        self.refreshControl.rx.controlEvent(.valueChanged).bind { [weak self] in
//            guard let wSelf = self , !wSelf.loading else {
//                return
//            }
//            wSelf.refreshControl.beginRefreshing()
//            wSelf.eAction.onNext(.refresh)
//        }.disposed(by: disposeBag)
    }
}

extension WalletHistoryTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(self.dataSource.count, Config.minimumDisplay)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = WalletItemTVC.dequeueCell(tableView: tableView)
        let item = dataSource[indexPath.item]
        cell.setupDisplay(by: item)
        return cell
    }
}

extension WalletHistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = self.dataSource[indexPath.item]
        self.eAction.onNext(.detail(item: WalletDetailHistoryType.detail(item: item)))
    }
}
