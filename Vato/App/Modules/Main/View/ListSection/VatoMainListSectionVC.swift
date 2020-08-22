//  File name   : VatoMainListSectionVC.swift
//
//  Author      : Dung Vu
//  Created date: 7/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import VatoNetwork
 
final class VatoMainListSectionTVC: UITableViewCell, UpdateDisplayProtocol {
    private var view = VatoMainItemLayout2(frame: .zero)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        visualize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func visualize() {
        selectionStyle = .none
        view >>> contentView >>> {
            $0.layer.cornerRadius = 6
            $0.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
            $0.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: UIScreen.main.bounds.width - 32, height: 224))
                make.top.equalTo(16)
                make.bottom.equalToSuperview().priority(.high)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    func setupDisplay(item: VatoHomeLandingItem?) {
        view.setupDisplay(item: item)
    }
}

struct VatoMainListData: ResponsePagingProtocol, InitializeValueProtocol {
    var items: [VatoHomeLandingItem]?
    var next: Bool {
        let count = (items?.count).orNil(0)
        return count >= 10
    }
}

final class VatoMainListSectionVC: UIViewController {
    /// Class's public properties.
    private let section: VatoHomeLandingItemSection
    @Published private var mVatoHomeLandingItem: VatoHomeLandingItem?
    // MARK: View's lifecycle
    private var pagingView: PagingListView<VatoMainListSectionTVC, VatoMainListSectionVC, P>?
    private lazy var disposeBag = DisposeBag()
    init(use section: VatoHomeLandingItemSection) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
}

// MARK: View's event handlers
extension VatoMainListSectionVC: PagingListRequestDataProtocol {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func buildRouter(from paging: Paging) -> Observable<APIRequestProtocol> {
        let id = section.id
        return VatoLocationManager.shared
        .geoHash()
        .map { (hash) -> APIRequestProtocol in
            var params = JSON()
            let hash = hash
            params["geohash"] = hash
            params["page"] = paging.page
            params["size"] = paging.size
            return VatoAPIRouter.customPath(authToken: "", path: "landing-page/home/sections/\(id)/items", header: nil, params: params, useFullPath: false)
        }
    }
    
    func request(router: APIRequestProtocol, decodeTo: VatoMainListData.Type) -> Observable<VatoMainListData> {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router,
                        decodeTo: OptionalMessageDTO<[VatoHomeLandingItem]>.self,
                        ignoreCache: true)
            .map { (result) -> VatoMainListData in
                switch result {
                case .success(let data):
                    return VatoMainListData(items: data.data)
                case .failure(let e):
                    assert(false, e.localizedDescription)
                    return VatoMainListData(items: nil)
                }
        }
    }
    
    static func showList(on controller: UIViewController?, section: VatoHomeLandingItemSection) -> Observable<VatoHomeLandingItem?> {
        return Observable.create { (s) -> Disposable in
            let vc = VatoMainListSectionVC.init(use: section)
            let navi = UINavigationController(rootViewController: vc)
            
            controller?.present(navi, animated: true, completion: nil)
            let dispose = vc.$mVatoHomeLandingItem.take(1).subscribe(s)
            return Disposables.create {
                vc.dismiss(animated: true, completion: nil)
                dispose.dispose()
            }
        }.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
    }
}

// MARK: Class's private methods
private extension VatoMainListSectionVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        view.backgroundColor = .white
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        title = section.title
        if self.tabBarController == nil {
            let image = UIImage(named: "ic_arrow_back")?.withRenderingMode(.alwaysTemplate)
            let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
            button.setImage(image, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
            let leftBarButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = leftBarButton
            self.navigationItem.leftBarButtonItem = leftBarButton
            
            UIApplication.setStatusBar(using: .lightContent)
            
            button.rx.tap.bind { [weak self] in
                self?.mVatoHomeLandingItem = nil
            }.disposed(by: disposeBag)
        }
        
        let pagingView = PagingListView<VatoMainListSectionTVC, VatoMainListSectionVC, P>.init(listener: self, pagingDefault: { return Paging(page: -1, canRequest: true, size: 10) }) { (tableView) -> NoItemView? in
            return NoItemView(imageName: "ic_food_noItem", message: FwiLocale.localized("Không có dữ liệu"), on: tableView)
        }
        self.pagingView = pagingView
        
        pagingView >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func setupRX() {
        self.pagingView?.selected.bind(to: $mVatoHomeLandingItem).disposed(by: disposeBag)
    }
}
