//  File name   : QuickSupportMainVC.swift
//
//  Author      : khoi tran
//  Created date: 1/14/20
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

protocol QuickSupportMainPresentableListener: class {
    // todo: Declare properties and methods that the viewcontroller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func quickSupportMoveBack()
    var listQuickSupport: Observable<[QuickSupportRequest]> { get }
    func routeRequestQickSupport(requestModel: QuickSupportRequest)
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : InitializeValueProtocol
    func routeToListQS()
    var eLoadingObser: Observable<(Bool, Double)> { get }
}

final class QuickSupportMainVC: UIViewController, QuickSupportMainPresentable, QuickSupportMainViewControllable, LoadingAnimateProtocol, DisposableProtocol, PagingListRequestDataProtocol {
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        let param: [String : Any] = [
            "indexPage": max(paging.page, 0),
            "sizePage": Config.pageSize
        ]
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoFoodApi.getListSaleOrder(authenToken: key, params: param))
        }
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : InitializeValueProtocol {
        guard let listener = listener  else {
            return Observable.empty()
        }
         
        return listener.request(router: router, decodeTo: decodeTo, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        })
    }
    
    typealias Data = QuickSupportMainResponse
    typealias P = Paging
    
    private struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }
    
    /// Class's public properties.
    weak var listener: QuickSupportMainPresentableListener?

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
    private var listView: PagingListView<QuickSupportTVC, QuickSupportMainVC, P>?
    private lazy var button = UIButton.init(frame: .zero)
}

struct QuickSupportMainResponse: Codable, InitializeValueProtocol , ResponsePagingProtocol {
    var values: [QuickSupportRequest]?
    
    var items: [QuickSupportRequest]? {
        return values
    }
    
    var next: Bool {
        return false
    }
}

extension QuickSupportMainResponse {
    init?(use value: Any?) {
        guard let values = value as? [QuickSupportRequest] else {
            return nil
        }
        let new = QuickSupportMainResponse(values: values)
        self = new
    }
}
// MARK: View's event handlers
extension QuickSupportMainVC: RequestInteractorProtocol {
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
extension QuickSupportMainVC {
}

// MARK: Class's private methods
private extension QuickSupportMainVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.title = Text.quickSupport.localizedText
        
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.quickSupportMoveBack()
        }.disposed(by: disposeBag)

        button >>> self.view >>> {
            $0.cornerRadius = 8
            $0.setBackground(using: #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1), state: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.setTitle(Text.viewRequestedLists.localizedText, for: .normal)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(-16)
                make.height.equalTo(56)
            }
        }
        
        button.rx.tap.bind { [weak self] in
            guard let wSelf = self else { return }
            wSelf.listener?.routeToListQS()
        }.disposed(by: disposeBag)
        
        let pagingView = PagingListView<QuickSupportTVC, QuickSupportMainVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportMainVC.P in
            return Config.pagingDefaut
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "ic_quick_support_empty",
                            message: "Không có dữ liệu.",
                            subMessage: "",
                            on: tableView,
                            customLayout: nil)
        }
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalTo(button.snp.top).offset(-10)
            }
        }
        pagingView.clipsToBounds = true
        self.listView = pagingView
    }
    
    private func setupRX() {
        self.listView?.selected.bind(onNext: { [weak self] (requestModel) in
            self?.listener?.routeRequestQickSupport(requestModel: requestModel)
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
    }
}

