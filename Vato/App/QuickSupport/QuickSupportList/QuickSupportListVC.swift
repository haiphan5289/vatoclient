//  File name   : QuickSupportListVC.swift
//
//  Author      : khoi tran
//  Created date: 1/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX
import VatoNetwork
import SnapKit

protocol QuickSupportListPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable
    func detail(model: QuickSupportModel)
    func quickSupportListMoveBack()
}

final class QuickSupportListVC: UIViewController, QuickSupportListPresentable, QuickSupportListViewControllable, DisposableProtocol, PagingListRequestDataProtocol {
    
    
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        let param: [String : Any] = [
            "indexPage": max(paging.page, 0),
            "sizePage": Config.pageSize
        ]
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoFoodApi.getListSaleOrder(authenToken: key, params: param))
        }
        
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : Decodable {
        guard let listener = listener  else {
            return Observable.empty()
        }
         
        return listener.request(router: router, decodeTo: decodeTo, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        })
        
    }
    
    private struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }
    
    /// Class's public properties.
    weak var listener: QuickSupportListPresentableListener?

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
    private var listView: PagingListView<QSRequestTVC, QuickSupportListVC, P>?
    typealias Data = QuickSupportListResponse
    typealias P = Paging
    internal lazy var disposeBag: DisposeBag = DisposeBag()
    private var requestSupportButton: UIButton?
}

struct QuickSupportListResponse: Codable, ResponsePagingProtocol {
    var values: [QuickSupportModel]?
    
    var items: [QuickSupportModel]? {
        let newValues = values?.map({ (item) -> QuickSupportModel in
            var newItem = item
            newItem.type = .home
            return newItem
        })
        return newValues
    }
    
    var next: Bool {
        return false
    }
        
}
// MARK: View's event handlers
extension QuickSupportListVC: RequestInteractorProtocol {
    var token: Observable<String> {
        return Observable.just("")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension QuickSupportListVC {
}

// MARK: Class's private methods
private extension QuickSupportListVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.title = "Danh sách yêu cầu hỗ trợ"
        self.view.backgroundColor = #colorLiteral(red: 0.9750739932, green: 0.9750967622, blue: 0.9750844836, alpha: 1)
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = #colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
         let image = UIImage(named: "ic_back")?.withRenderingMode(.alwaysOriginal)
         let leftBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
         self.navigationItem.leftBarButtonItem = leftBarItem
         leftBarItem.rx.tap.bind { [weak self] in
             guard let wSelf = self else {
                 return
             }
             wSelf.listener?.quickSupportListMoveBack()
         }.disposed(by: disposeBag)
         
        
         let pagingView = PagingListView<QSRequestTVC, QuickSupportListVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportListVC.P in
             return Config.pagingDefaut
         }) { (tableView) -> NoItemView? in
             return NoItemView(imageName: "illusNoti",
                             message: "Hiện tại, bạn không có dữ liệu.",
                             subMessage: "",
                             on: tableView,
                             customLayout: nil)
         }
        
        view.addSubview(pagingView)
     
        pagingView.clipsToBounds = false
        pagingView.tableView.clipsToBounds = false
        self.listView = pagingView
        
        let requestSupportButton = UIButton.create { (button) in
            button.cornerRadius = 20
            button.setTitle("Gửi hỗ trợ", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1)
            button.setImage(UIImage(named: "ic_request_support"), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
        requestSupportButton >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(40)
                make.bottom.equalTo(view.snp.bottom).offset(-26)
                make.centerX.equalToSuperview()
            }
        }
        self.requestSupportButton = requestSupportButton
        
        pagingView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(requestSupportButton.snp.top)
        }
    }
    
    private func setupRX() {
         self.listView?.selected.bind(onNext: weakify({ (model, wSelf) in
            wSelf.listener?.detail(model: model)
         })).disposed(by: disposeBag)
        
        requestSupportButton?.rx.tap.bind { [weak self] (_) in
            guard let wSelf = self else { return }
            wSelf.listener?.quickSupportListMoveBack()
        }.disposed(by: disposeBag)
    }
    
}


