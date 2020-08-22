//  File name   : QuickSupportDetailVC.swift
//
//  Author      : khoi tran
//  Created date: 1/16/20
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

protocol QuickSupportDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T> where T : Decodable
    func quickSupportDetailMoveBack()
    var quickSupportRequest: Observable<QuickSupportItemRequest> { get }
    func dummyInsertData() -> [QuickSupportItemResponse]
    func showImages(currentIndex: Int, stackView: UIStackView)
}

final class QuickSupportDetailVC: UIViewController, QuickSupportDetailPresentable, QuickSupportDetailViewControllable, DisposableProtocol, PagingListRequestDataProtocol {
    private struct Config {
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }
    
    /// Class's public properties.
    weak var listener: QuickSupportDetailPresentableListener?
    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: nil, action: nil)
        return tap
    }()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        requestView.listener = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
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
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : Decodable {
        guard let listener = listener  else {
            return Observable.empty()
        }
        
        return listener.request(router: router, decodeTo: decodeTo, block: {
            $0.dateDecodingStrategy = .customDateFireBase
        })
        
    }
    
    /// Class's private properties.
    private var listView: PagingListView<QSResponseTVC, QuickSupportDetailVC, P>?
    typealias Data = QuickSupportDetailResponse
    typealias P = Paging
    internal lazy var disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var _inputView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomTextView: NSLayoutConstraint?
    @IBOutlet weak var sendButton: UIButton!
    private lazy var requestView = QSRequestView.loadXib()
}

struct QuickSupportDetailResponse: Codable, ResponsePagingProtocol {
    var values: [QuickSupportItemResponse]?
    
    var items: [QuickSupportItemResponse]? {
        return values
    }
    
    var next: Bool {
        return false
    }
        
}
extension QuickSupportDetailVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        defer {
            textView?.resignFirstResponder()
        }
        return false
    }
}

// MARK: View's event handlers
extension QuickSupportDetailVC: RequestInteractorProtocol {
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
extension QuickSupportDetailVC {
}

// MARK: Class's private methods
private extension QuickSupportDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        let image = UIImage(named: "ic_back")?.withRenderingMode(.alwaysOriginal)
        let leftBarItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = leftBarItem
        leftBarItem.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.listener?.quickSupportDetailMoveBack()
        }.disposed(by: disposeBag)
        
        
        let pagingView = PagingListView<QSResponseTVC, QuickSupportDetailVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> QuickSupportDetailVC.P in
            return Config.pagingDefaut
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "illusNoti",
                              message: "Hiện tại, bạn không có dữ liệu.",
                              subMessage: "",
                              on: tableView,
                              customLayout: nil)
        }
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(_inputView.snp.top)
            }
        }
        
        
        
        
        self.listView = pagingView
        _inputView.addSeperator(with: .zero, position: .top)
        self.title = "Chi tiết yêu cầu hỗ trợ"
        tap.delegate = self
        pagingView.tableView.addGestureRecognizer(tap)
        pagingView.tableView.keyboardDismissMode = .interactive
        textView.tintColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    }
    
    func setupRX() {
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        let safe = UIApplication.shared.keyWindow?.edgeSafe.bottom ?? 0
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] in
            let h = $0.height == 0 ? 0 : $0.height - safe
            UIView.animate(withDuration: $0.duration) {
                self?.bottomTextView?.constant = -h
                self?.view.layoutIfNeeded()
            }
        }.disposed(by: disposeBag)
        
        sendButton.rx.tap.bind { [weak self] in
            guard let me = self else { return }
            
            
            me.listView?.insert(items: me.listener?.dummyInsertData() ?? [])
            
        }.disposed(by: disposeBag)
        
        self.listener?.quickSupportRequest.bind(onNext: { [weak self](item) in
            guard let me = self else {return}
            let v = UIView(frame: .zero)
            me.requestView.setupDisplay(item: item)
            me.requestView >>> v >>> {
                $0.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            
            let s = v.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            v.frame = CGRect(origin: .zero, size: s)
            
            me.listView?.tableView.tableHeaderView = v
            me._inputView.isHidden = (item.status == .complete)
        }).disposed(by: disposeBag)
    }
}


extension QuickSupportDetailVC: QSRequestViewHandlerProtocol {
    func selectImage(index: Int) {
        self.listener?.showImages(currentIndex: index, stackView: self.requestView.imageStackView)
    }
}

