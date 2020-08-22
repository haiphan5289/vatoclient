
//
//  FoodHistoryViewController.swift
//  Vato
//
//  Created by khoi tran on 1/7/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import FwiCore
import FwiCoreRX
import RxSwift
import VatoNetwork

enum FoodHistoryShowType {
    case embeded
    case navigation
}

final class FoodHistoryViewController: UIViewController, SafeAccessProtocol, ActivityTrackingProgressProtocol, LoadingAnimateProtocol, DisposableProtocol, PagingListRequestDataProtocol {
    
       var historyItemType: HistoryItemType = .food
       private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
       private struct Config {
           static let limitDay: Double = 2505600000 // 29days
           static let pageSize = 10
           static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
       }
       
       /// Class's public properties.
       weak var listener: HistoryListenerProtocol?
       private var listView: PagingListView<FoodHistoryCell, FoodHistoryViewController, P>?
       var showingType = FoodHistoryShowType.embeded
    
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

struct FoodHistoryResponse: Codable, InitializeValueProtocol, ResponsePagingProtocol {
    var salesOrderList: [SalesOrder]?
    var sizePage: Int?
    var indexPage: Int?
    var totalPage: Int?
    var totalRows: Int?
    
    var items: [SalesOrder]? {
        return salesOrderList
    }
    
    var next: Bool {
        guard let indexPage = self.indexPage, let totalPage = self.totalPage else {
            return false
        }
        return indexPage < totalPage - 1
    }
        
}
extension FoodHistoryViewController {
    typealias Data = FoodHistoryResponse
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
     
        let param: [String : Any] = [
            "indexPage": max(paging.page, 0),
            "sizePage": Config.pageSize
        ]
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoFoodApi.getListSaleOrder(authenToken: key, params: param))
        }
    }
}

// MARK: View's event handlers
extension FoodHistoryViewController: RequestInteractorProtocol {
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
private extension FoodHistoryViewController {
    private func localize() {
        // todo: Localize view's here.
    }
    
    func handler(cell: FoodHistoryCell, item: SalesOrder) {
        let e = cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse))
        cell.btnPreOrder?.rx.tap.takeUntil(e).bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.detail(item: .preorder(order: item))
        })).disposed(by: disposeBag)
    }
    
    private func visualize() {
        // table view
        let pagingView = PagingListView<FoodHistoryCell, FoodHistoryViewController, P>.init(listener: self, type: .nib, pagingDefault: { () -> FoodHistoryViewController.P in
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
        
        pagingView.configureCell = { [unowned self] cell, item in
            self.handler(cell: cell, item: item)
        }

        self.listView = pagingView
        
        switch showingType {
        case .navigation:
            UIApplication.setStatusBar(using: .lightContent)
            view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            let navigationBar = navigationController?.navigationBar
            let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
            navigationBar?.setBackgroundImage(bgImage, for: .default)
            navigationBar?.barTintColor = Color.orange
            navigationBar?.isTranslucent = false
            navigationBar?.tintColor = .white
            navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            title = Text.tabbarHistory.localizedText
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
            
        default:
            break
        }
    }
    
    private func setupRX() {
        self.listView?.selected.bind(onNext: weakify({ (model, wSelf) in
            wSelf.listener?.detail(item: .food(order: model))
        })).disposed(by: disposeBag)        
    }
    
}


