//  File name   : NotificationVC.swift
//
//  Author      : khoi tran
//  Created date: 1/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCore
import FwiCoreRX
import RxSwift
import VatoNetwork

protocol NotificationPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var authenticated: AuthenticatedStream { get }
    func request<T: Codable>(router: APIRequestProtocol, decodeTo: T.Type, block: ((JSONDecoder) -> Void)?) -> Observable<T>
    func selectNotification(notify: NotificationModel?)
    func notificationDismiss()
}

final class NotificationVC: UIViewController, NotificationPresentable, NotificationViewControllable, SafeAccessProtocol, ActivityTrackingProgressProtocol, LoadingAnimateProtocol, DisposableProtocol, PagingListRequestDataProtocol {
    
    
    /// Class's public properties.
    weak var listener: NotificationPresentableListener?
    
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
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    private struct Config {
        static let limitDay: Double = 2505600000 // 29days
        static let pageSize = 10
        static let pagingDefaut = Paging(page: -1, canRequest: true, size: 10)
    }
    private var listView: PagingListView<NotificationCell, NotificationVC, P>?
    
}

// MARK: View's event handlers
extension NotificationVC: RequestInteractorProtocol {
    var token: Observable<String> {
        guard let token = listener?.authenticated.firebaseAuthToken else {
            fatalError("Please Implement")
        }
        return token.take(1)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension NotificationVC {
}

// MARK: Class's private methods
private extension NotificationVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        let pagingView =  PagingListView<NotificationCell, NotificationVC, P>.init(listener: self, type: .nib, pagingDefault: { () -> NotificationVC.P in
            return Config.pagingDefaut
        }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "no-notify",
                              message: "Hiện tại, bạn không có thông báo mới nào.",
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
    
    private func setupNavigation() {
        let navigationBar = self.navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        self.title = Text.notification.localizedText
        
        let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        
        button.rx.tap.bind { [weak self] in
            self?.listener?.notificationDismiss()
        }.disposed(by: disposeBag)
        
        
    }
    
    private func setupRX() {
        self.listView?.selected.bind(onNext: weakify({ (model, wSelf) in
            guard let type = model.type else { return }
            switch type {
            case .web:
                WebVC.loadWeb(on: self, url: URL(string: model.extra ?? ""), title: model.title)
            case .manifest:
                self.listener?.selectNotification(notify: model)
            default:
                break
            }
        })).disposed(by: disposeBag)
    }

}

// MARK: Paging
struct NotificationResponse: Codable, InitializeValueProtocol , ResponsePagingProtocol {
    var notifications: [NotificationModel]?
    var more: Bool?
    
    var items: [NotificationModel]? {
        return notifications
    }
    
    var next: Bool {
        return more ?? false
    }
    
    func next(currentPage: Int) -> Paging {
        return Paging(page: currentPage + 1, canRequest: more ?? false, size: 10)
    }
}

extension NotificationVC {
    typealias Data = NotificationResponse
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
        
        let to = Date().timeIntervalSince1970 * 1000
        let from = to - Config.limitDay
        let param: [String : Any] = [
            "from": from,
            "to": to,
            "page": max(paging.page, 0),
            "size": Config.pageSize
        ]
        return self.request { key -> Observable<APIRequestProtocol> in
            return Observable.just(VatoAPIRouter.getUserNotification(authToken: key, params: param))
        }
    }
}
