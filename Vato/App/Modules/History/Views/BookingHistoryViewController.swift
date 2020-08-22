//
//  BookingHistoryViewController.swift
//  Vato
//
//  Created by vato. on 12/26/19.
//  Copyright © 2019 Vato. All rights reserved.
//
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

struct BookingHistoryResponse: Codable, InitializeValueProtocol, ResponsePagingProtocol {
    var trips: [BookingHistoryModel]?
    var more: Bool?
    
    var items: [BookingHistoryModel]? {
        return trips
    }
    
    var next: Bool {
        return more ?? false
    }
    
    func next(currentPage: Int) -> Paging {
        return Paging(page: currentPage + 1, canRequest: more ?? false, size: 10)
    }
}

protocol BookingHistoryProtocol {
    var dateCreate: Date? { get }
    var code: String? { get }
    var originLocation: String? { get }
    var destLocation: String? { get }
    var serviceName: String? { get }
    var statusStr: String? { get }
    var priceStr: String? { get }
    var statusColor: UIColor? { get }
    
    var waypoints: [PointViewType]? { get }
}

final class BookingHistoryViewController: UIViewController, SafeAccessProtocol, ActivityTrackingProgressProtocol, LoadingAnimateProtocol, DisposableProtocol, PagingListRequestDataProtocol {
    var historyItemType: HistoryItemType = .booking
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private struct Config {
        static let limitDay: Double = 2505600000 // 29days
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }
    
    /// Class's public properties.
    weak var listener: HistoryListenerProtocol?
    private var listView: PagingListView<BookingHistoryCell, BookingHistoryViewController, P>?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
}

// MARK: Paging
extension BookingHistoryViewController {
    typealias Data = BookingHistoryResponse
    typealias P = Paging
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T: Codable {
        guard let listener = listener  else {
            return Observable.empty()
        }
         
        return listener.request(router: router, decodeTo: OptionalMessageDTO<T>.self, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        }).map { $0.data }.filterNil()
    }
    
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        var arrServiceType = [
            VatoServiceType.car.rawValue,
            VatoServiceType.carPlus.rawValue,
            VatoServiceType.car7.rawValue,
            VatoServiceType.moto.rawValue,
            VatoServiceType.motoPlus.rawValue,
            VatoServiceType.taxi.rawValue,
            VatoServiceType.taxi7.rawValue
        ]
        
        if self.historyItemType == .expressUrBan {
            arrServiceType = [VatoServiceType.delivery.rawValue]
        } else if self.historyItemType == .supply {
            arrServiceType = [VatoServiceType.shopping.rawValue]
        }
        
        let to = Date().timeIntervalSince1970 * 1000
        let from = to - Config.limitDay
        let param: [String : Any] = [
            "from": Int64(from),
            "page": max(paging.page, 0),
            "serviceId": arrServiceType.compactMap({ "\($0)" }).joined(separator: ","),
            "size": Config.pageSize,
            "to": Int64(to)]
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoAPIRouter.bookingHistory(token: key, param: param))
        }
    }
}

// MARK: View's event handlers
extension BookingHistoryViewController: RequestInteractorProtocol {
    var token: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil().take(1)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension BookingHistoryViewController {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // table view
        let pagingView =  PagingListView<BookingHistoryCell, BookingHistoryViewController, P>.init(listener: self, type: .nib, pagingDefault: { () -> BookingHistoryViewController.P in
            return Config.pagingDefaut
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "location_empty",
                            message: Text.noTripMessage.localizedText,
                            subMessage: "",
                            on: tableView,
                            customLayout: nil)
        }
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }

        self.listView = pagingView
    }
    
    private func setupRX() {
        self.listView?.selected.bind(onNext: weakify({ (model, wSelf) in
            guard let tripCode = model.id else { return }
            wSelf.listener?.detail(item: .trip(id: tripCode))
        })).disposed(by: disposeBag)
        
        
        self.listView?.configureCell = {(cell, item) in
            cell.btnReport?.rx.tap
                .takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .bind(onNext: { [weak self] in
                guard let wSelf = self else { return }
                    guard let tripCode = item.id, let serviceName = item.serviceName else { return }
                
                    wSelf.listener?.report(tripCode: tripCode, service: serviceName)
            }).disposed(by: self.disposeBag)
        }
    }
    
}

