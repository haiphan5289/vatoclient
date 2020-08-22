//  File name   : EcomPromotionVC.swift
//
//  Author      : Dung Vu
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import VatoNetwork
import FwiCore
import FwiCoreRX
import Atributika

protocol EcomPromotionPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var storeID: Int { get }
    func ecomPromotionMoveBack()
    func ecomPromotion(selected: EcomPromotion)
    func ecomPromotionVoucher(string: String?)
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : InitializeValueProtocol
}

final class EcomPromotionVC: UIViewController, EcomPromotionPresentable, EcomPromotionViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: EcomPromotionPresentableListener?
    @IBOutlet weak var textField: UITextField?
    @IBOutlet weak var btnApply: UIButton?
    @IBOutlet weak var containerView: UIView?
    internal lazy var disposeBag = DisposeBag()
    private var listView: PagingListView<EcomPromotionTVC, EcomPromotionVC, P>?
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
}

// MARK: View's event handlers
extension EcomPromotionVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension EcomPromotionVC: PagingListRequestDataProtocol, LoadingAnimateProtocol, DisposableProtocol {
    typealias Data = EcomPromotionResponse
    typealias P = Paging
    
    func buildRouter(from paging: P) -> Observable<APIRequestProtocol> {
        guard let storeId = listener?.storeID else { return Observable.empty() }
        let host = VatoFoodApi.host
        let p = "\(host)" + "/ecom/promotion/merchant/list-all-campaign/\(storeId)"
        var params = JSON()
        params["indexPage"] = 0
        params["sizePage"] = 1000
        let router = VatoAPIRouter.customPath(authToken: "", path: p, header: nil, params: params, useFullPath: true)
        return Observable.just(router)
    }
    
    func request<T>(router: APIRequestProtocol, decodeTo: T.Type) -> Observable<T> where T : InitializeValueProtocol {
        guard let listener = self.listener else {
            return Observable.empty()
        }
        return listener.request(router: router, decodeTo: decodeTo)
    }
}

// MARK: Class's private methods
private extension EcomPromotionVC {
    private func localize() {
        // todo: Localize view's here.
    }
    
    private func setupRX() {
        textField?.rx.text.bind(onNext: weakify({ (t, wSelf) in
            wSelf.btnApply?.isEnabled = t?.isEmpty == false
        })).disposed(by: disposeBag)
        showLoading(use: listView?.loadingProgress)
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map (KeyboardInfo.init)
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map (KeyboardInfo.init)
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] d in
            guard let wSelf = self else { return }
            UIView.animate(withDuration: d.duration, animations: {
                wSelf.listView?.snp.updateConstraints({ (make) in
                    make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: d.height, right: 0))
                })
                wSelf.view.layoutIfNeeded()
            }, completion: { _ in })
        }.disposed(by: disposeBag)
        
        btnApply?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.ecomPromotionVoucher(string: wSelf.textField?.text)
        })).disposed(by: disposeBag)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        title = FwiLocale.localized("Khuyến mãi của bạn")
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
                self?.listener?.ecomPromotionMoveBack()
            }.disposed(by: disposeBag)
        }
        btnApply?.setTitle(FwiLocale.localized("Áp dụng"), for: .normal)
        btnApply?.setBackground(using: #colorLiteral(red: 0.8156862745, green: 0.831372549, blue: 0.8470588235, alpha: 1), state: .disabled)
        btnApply?.setBackground(using: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), state: .normal)
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        let text = FwiLocale.localized("Nhập mã khuyến mãi")
        
        let all = Atributika.Style.foregroundColor(#colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)).font(UIFont.systemFont(ofSize: 15, weight: .regular))
        textField?.attributedPlaceholder = text.styleAll(all).attributedString
        let listView = PagingListView<EcomPromotionTVC, EcomPromotionVC, P>.init(listener: self, type: .nib, tableView: tableView) { (tableview) -> NoItemView? in
            NoItemView(imageName: "ic_food_noItem", message: FwiLocale.localized("Bạn chưa có khuyến mãi nào"), on: tableview)
        }
        self.listView = listView
        listView >>> containerView >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        listView.configureCell = { [weak self] cell, item in
            self?.handlerEvent(cell: cell, item: item)
        }
        
        listView.selected.bind(onNext: weakify({ (item, wSelf) in
            wSelf.detailPromotion(item: item)
        })).disposed(by: disposeBag)
    }
    
    private func detailPromotion(item: EcomPromotion) {
        FoodDetailPromotionVC.showDetailPromotion(on: self, foodSales: item).bind(onNext: weakify({ (type, wSelf) in
            guard type == .apply else {
                return
            }
            wSelf.listener?.ecomPromotion(selected: item)
        })).disposed(by: disposeBag)
    }
    
    private func handlerEvent(cell: EcomPromotionTVC, item: EcomPromotion) {
        cell.btnApply?.rx.tap.takeUntil(cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse))).bind(onNext: { [weak self](_) in
            self?.listener?.ecomPromotion(selected: item)
        }).disposed(by: disposeBag)
    }
}
