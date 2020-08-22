//  File name   : ListProductVC.swift
//
//  Author      : khoi tran
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import RxSwift
import FwiCore
import FwiCoreRX

protocol ListProductPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var errorObserable: Observable<MerchantState>{ get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    
    var listProductCategory: Observable<[DisplayProductCategory]> { get }
    
    var currentStore: Store? { get }
    
    func dismisListProduct()
    func routeToAddProduct(currentProduct: DisplayProduct?)
    
    func publicProduct(productId: Int?, value: Bool)
    func refresh()
}

final class ListProductVC: FormViewController, ListProductPresentable, ListProductViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: ListProductPresentableListener?

    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorColor = .clear
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
    @IBOutlet weak var categoryHeaderView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    lazy var categoryView: StoreSelectCategoryView = StoreSelectCategoryView(frame: .zero)
    internal lazy var disposeBag = DisposeBag()
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
 
    private lazy var mRefreshControl: UIRefreshControl = {
           let f = UIRefreshControl(frame: .zero)
           return f
       }()
}

// MARK: View's event handlers
extension ListProductVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension ListProductVC {
}

// MARK: Class's private methods
private extension ListProductVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        
        searchTextField.placeholder = "Tìm kiếm món"
        categoryView >>> categoryHeaderView >>> {
            $0.snp.makeConstraints({ (make) in
                make.left.equalTo(0)
                make.bottom.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(48)
            })
        }
        
        tableView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.top.equalTo(categoryHeaderView.snp.bottom)
                make.bottom.equalTo(0)
                make.left.equalTo(0)
                make.right.equalTo(0)
            })
        }
        
        tableView.refreshControl = mRefreshControl
    }
    
    private func setupRX() {
        self.listener?.listProductCategory.bind(onNext: { [weak self] (listProductCategory) in
            guard let me = self else { return }
            me.categoryView.setupDisplay(item: listProductCategory)
            me.bindData(listProductCategory: listProductCategory)
            me.categoryView.select(at: 0)
            
            guard me.mRefreshControl.isRefreshing else {
                return
            }
            me.mRefreshControl.endRefreshing()
            
        }).disposed(by: disposeBag)
        
        self.categoryView.selected.bind {[weak self] (index) in
            guard let me = self else { return }
            me.tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
        }.disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        mRefreshControl.rx.controlEvent(.valueChanged).bind { [weak self] in
            guard let wSelf = self else { return }
            wSelf.mRefreshControl.beginRefreshing()
            wSelf.listener?.refresh()
        }.disposed(by: disposeBag)
        
        let showEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hideEvent = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        
        Observable.merge([showEvent, hideEvent]).filterNil().bind { [weak self] in
            let h = $0.height
            UIView.animate(withDuration: $0.duration) {
                self?.tableView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(-h)
                })
            }
        }.disposed(by: disposeBag)

    }
    
    func bindData(listProductCategory: [DisplayProductCategory]) {
        self.form.removeAll()
        self.form += listProductCategory.map({ self.bindSection(productCategory: $0) })
    }
    
    func bindSection(productCategory: DisplayProductCategory) -> Section {
        guard let categoryId = productCategory.id else {
            fatalError("binding error")
        }
        
        var section = Section() { section in
            section.tag = "\(categoryId)"
            var header = HeaderFooterView<UIView>(.callback({ UIView() }))
            header.onSetupView = { (view, _) in
                view.backgroundColor = .clear
                let label = UILabel(frame: .zero)
                label >>> view >>> {
                    $0.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
                    $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                    $0.text = productCategory.name
                    $0.snp.makeConstraints({ (make) in
                        make.left.equalTo(16)
                        make.centerY.equalToSuperview()
                    })
                }
            }

            header.height = { 50 }
            section.header = header
        }
        if let listProduct = productCategory.products {
            section += listProduct.compactMap({ $0 }).map({ self.bindRow(product: $0) })
        }
        return section
    }
    
    func bindRow(product: DisplayProduct) -> RowDetailGeneric<MerchantStoreProductCell> {
        
        guard let productId = product.productId else {
            fatalError("Binding error")
        }
        
        return RowDetailGeneric<MerchantStoreProductCell>.init("\(productId)", { (row) in
            row.value = product
            row.onCellSelection({[weak self] (cell, row) in
                guard let me = self else {  return }                
                me.listener?.routeToAddProduct(currentProduct: row.value)
            })
            
            row.cell.onProductEnableChanged(callback: {[weak self] (productId, value) in
                guard let me = self else {  return }
                me.listener?.publicProduct(productId: productId, value: value)
            })
        })
    }
    
    private func setupNavigation() {
        self.title = Text.menu.localizedText
        
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        
        let imageRight = UIImage(named: "add")
        let buttonRight = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        buttonRight.setImage(imageRight, for: .normal)
        buttonRight.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -30)
        let barButtonRight = UIBarButtonItem(customView: buttonRight)
        navigationItem.rightBarButtonItem = barButtonRight
        
        buttonRight.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.routeToAddProduct(currentProduct: nil)
        }).disposed(by: disposeBag)
        
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.dismisListProduct()
        }).disposed(by: disposeBag)
        
        
    }
    
    
    
}


