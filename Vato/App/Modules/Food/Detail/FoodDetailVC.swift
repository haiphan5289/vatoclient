//  File name   : FoodDetailVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/29/19
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
import KeyPathKit

protocol FoodDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var item: FoodExploreItem { get }
    var menu: Observable<[DisplayProductCategory]> { get }
    var loading: Observable<(Bool, Double)> { get }
    var basket: Observable<BasketModel> { get }
    var errorObserable: Observable<MerchantState>{ get }
    var itemsPromotion: Observable<[EcomPromotion]?> { get }

    func detailFoodMoveBack()
    func routeToMap()
    func routeToCheckOut(item: FoodExploreItem)
    func routeToProductMenu(item: DisplayProduct)
    func removeProduct(item: DisplayProduct)
    func createQuoteCard()
    func value(from item: DisplayProduct) -> BasketStoreValueProtocol?
}

enum FoodDetailCellType: Int, CaseIterable {
    case description = 0
    case discount
    case other
}

enum ScrollDirection {
    case none
    case down
    case up
}

final class FoodDetailVC: FormViewController, FoodDetailPresentable, FoodDetailViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    typealias ElementCell = StoreProductSelectCell
    /// Class's public properties.
    weak var listener: FoodDetailPresentableListener?
    @IBOutlet var btnBack: UIButton!
    var disposeBag = DisposeBag()
    private weak var selectCategoryView: StoreSelectCategoryView?
    private var scrolling: Bool = false
    private var direction: ScrollDirection = .none
    private var headerView: EcomProductTableHeaderView?
    private lazy var basketView: BasketItemsView = BasketItemsView(frame: .zero, value: listener?.basket)
    private var containerBasket: UIView?
    private var currentHeader: Int = 0 {
        didSet {
            guard currentHeader != oldValue else {
                return
            }
            direction = currentHeader > oldValue ? .down : .up
        }
    }
    
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .lightContent)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        localize()
        updateUIBasketIfNeeded() 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        currentHeader = indexPath.section * 10 + indexPath.item
    }
    
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }

    private func updateUIBasketIfNeeded() {
        guard !form.rows.isEmpty else { return }
        listener?.basket.take(1).filter { !$0.isEmpty }.bind(onNext: weakify({ (i, wSelf) in
            wSelf.form.rows.forEach { (r) in
                guard let row = r as? RowDetailGeneric<ElementCell>, let v = row.value else {
                    return
                }
                let number = i[v]
                row.cell.display(item: v, number: number)
            }
        })).disposed(by: disposeBag)
    }
    /// Class's private properties.
    func add(item: DisplayProduct, number: BasketStoreValueProtocol?) {
        guard let productId = item.productId else { return }
        let row = form.rowBy(tag: "\(productId)") as? RowDetailGeneric<ElementCell>
        row?.cell.display(item: item, number: number)
    }
    
    internal func showConfirmRemoveBasketAlert(cancelHandler: @escaping AlertBlock, confirmHandler: @escaping AlertBlock) {
        
        var arguments: AlertArguments = [:]
        
        let titleStyle = AlertLabelValue(text: "Tạo giỏ hàng mới", style: AlertStyleText(color: #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1), font: UIFont.systemFont(ofSize: 18, weight: .medium), numberLines: 1, textAlignment: .center))
        arguments[.title] = titleStyle

        let messagerStyle = AlertLabelValue(text: "Chọn món này thì các món hiện tại trong giỏ hàng sẽ bị xoá. Bạn có muốn tiếp tục không?", style: AlertStyleText(color: #colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1), font: UIFont.systemFont(ofSize: 15, weight: .regular), numberLines: 0, textAlignment: .center))
        arguments[.message] = messagerStyle
        
        let imageStyle = AlertImageValue(imageName: "ic_food_promotion_alert", style: AlertImageStyle(contentMode: .scaleAspectFill, size: CGSize(width: 160, height: 120)))
        
        arguments[.image] = imageStyle
        
        let buttons: [AlertAction] = [AlertAction(style: .newCancel, title: "Không", handler: cancelHandler), AlertAction(style: .newDefault, title: "Có", handler: confirmHandler)]
        
        AlertCustomVC.show(on: self, option: .all, arguments: arguments, buttons: buttons, orderType: .horizontal)
        
    }
}

// MARK: View's event handlers
extension FoodDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's private methods
private extension FoodDetailVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let edge: UIEdgeInsets = .zero
        let h = EcomProductTableHeaderView(frame: CGRect(origin: .zero, size: CGSize(width: 0.5, height: 0.5)))
        h.lblTitle.text = listener?.item.name
        h.view.setupDisplay(item: listener?.item)
        let s = h.view.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        self.selectCategoryView = h.selectCategoryView
        self.headerView = h
        tableView.addSubview(h)
        h.setMaximumContentHeight(s.height - edge.top, resetAnimated: false)
        headerView?.view.listPromotionView?.segmentView?.scrollView = tableView
        h.view.eventLayout.observeOn(MainScheduler.asyncInstance).bind(onNext: weakify({ (wSelf) in
            guard let headerView = wSelf.headerView else {
                return
            }
            let s = headerView.view.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            headerView.setMaximumContentHeight(s.height - edge.top, resetAnimated: true)
        })).disposed(by: disposeBag)
        
        let containerBasket = UIView(frame: .zero)
        containerBasket >>> view >>> {
            $0.backgroundColor = .clear
            $0.clipsToBounds = true
            $0.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0)
            })
        }
        self.containerBasket = containerBasket
        view.insertSubview(tableView, belowSubview: btnBack)
        view.backgroundColor = .white
        tableView >>> {
            $0?.backgroundColor = .clear
            $0?.snp.makeConstraints({ (make) in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalTo(containerBasket.snp.top).priority(.high)
            })
        }
        
        basketView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        
        loadDummy()
    }
    
    struct Item: Comparable {
        static func < (lhs: Item, rhs: Item) -> Bool {
            if lhs.indexPaths.count != rhs.indexPaths.count {
                return lhs.indexPaths.count < rhs.indexPaths.count
            } else {
                return lhs.section < rhs.section
            }
        }
        
        let section: Int
        let indexPaths: [IndexPath]
        
        
        static func ==(lhs: Item, rhs: Item) -> Bool {
            return lhs.indexPaths.count == rhs.indexPaths.count
        }
    }
    
    func checkSection() {
        guard scrolling else {
            return
        }
        guard tableView.contentOffset.y > 0 else {
            self.selectCategoryView?.select(at: 0)
            return
        }
        
        let cells = self.tableView.visibleCells.compactMap { self.tableView.indexPath(for: $0) }
        let groups = cells.groupBy(\.section).map { (v) -> Item in
            return Item(section: v.key, indexPaths: v.value)
        }
        
        var i: Item?
        switch direction {
        case .down:
            i = groups.sorted(by: >).first
        case .up:
            i = groups.sorted(by: <).first
        default:
            break
        }
        
        guard let idx = i else {
            return
        }
        self.selectCategoryView?.select(at: idx.section)
    }
    
    func loadDummy() {
        self.tableView.isUserInteractionEnabled = false
        let section = Section()
        (0...10).forEach { (idx) in
            section <<< RowDetailGeneric<ElementCell>.init("\(idx)", { (row) in
                row.cell.loadDummyView()
            })
        }
        UIView.performWithoutAnimation {
            self.form += [section]
        }
    }
    
    private func showPromotionItem(item: PromotionEcomProtocol?) {
        FoodDetailPromotionVC
            .showDetailPromotion(on: self, foodSales: item)
            .bind { (_) in }
            .disposed(by: disposeBag)
    }
    
    
    private func shareLink() {
        guard let p = listener?.item.shortLink, let url = URL(string: p) else {
            return
        }
        
        let shareVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }
    
    func setupRX() {
        headerView?.view.btnShowMap?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.routeToMap()
        })).disposed(by: disposeBag)
        headerView?.view.btnShare?.isHidden = listener?.item.shortLink == nil
        headerView?.view.btnShare?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.shareLink()
        })).disposed(by: disposeBag)
        
        headerView?.view.listPromotionView?.segmentView?.selected.bind(onNext: weakify({ (item, wSelf) in
            wSelf.showPromotionItem(item: item)
        })).disposed(by: disposeBag)
        
        listener?.itemsPromotion.bind(onNext: weakify({ (items, wSelf) in
            wSelf.headerView?.view.listPromotionView?.setupDisplay(item: items)
        })).disposed(by: disposeBag)
        
        let e1 = tableView.rx.willBeginDragging.map { _ in true }
        let e2 = tableView.rx.didEndDecelerating.map { _ in false }
        
        Observable.merge([e1, e2]).distinctUntilChanged().bind(onNext: weakify({ (scrolling, wSelf) in
            wSelf.scrolling = scrolling
        })).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.loading)
        
        tableView.rx.didScroll.bind(onNext: weakify({ (wSelf) in
            wSelf.checkSection()
        })).disposed(by: disposeBag)
        
        btnBack?.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.detailFoodMoveBack()
        })).disposed(by: disposeBag)
        
        listener?.menu.bind(onNext: weakify({ (list, wSelf) in
            wSelf.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            wSelf.form.removeAll()
            wSelf.tableView.isUserInteractionEnabled = true
            guard !list.isEmpty else {
                return
            }
            wSelf.selectCategoryView?.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                wSelf.selectCategoryView?.alpha = 1
            })
            
            wSelf.headerView?.view.updateListSelect(items: list)
            wSelf.bindData(listProductCategory: list)
            DispatchQueue.main.async {
                wSelf.selectCategoryView?.select(at: 0)
            }
        })).disposed(by: disposeBag)
        
        selectCategoryView?.selected.bind {[weak self] (index) in
            guard let me = self else { return }
            me.tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
        }.disposed(by: disposeBag)
        
        basketView.state.map { $0.height }
            .distinctUntilChanged()
            .delay(.milliseconds(200), scheduler: MainScheduler.asyncInstance).bind(onNext: weakify({ (next, wSelf) in
                wSelf.containerBasket?.snp.updateConstraints({ (make) in
                    make.height.equalTo(next)
                })
        })).disposed(by: disposeBag)

        listener?.basket.map { !$0.keys.isEmpty }.distinctUntilChanged().bind(onNext: weakify({ (show, wSelf) in
            let state: BasketItemsState = show ? .compact : .none
            wSelf.basketView.update(state: state)
            wSelf.view.bringSubviewToFront(wSelf.basketView)
        })).disposed(by: disposeBag)
        
        basketView.action.bind {[weak self] (type) in
            guard let wSelf = self else { return }
            switch type {
            case .checkout:
                wSelf.listener?.createQuoteCard()
            }
        }.disposed(by: disposeBag)
        
        basketView.select.bind(onNext: weakify({ (item, wSelf) in
            wSelf.listener?.routeToProductMenu(item: item)
        })).disposed(by: disposeBag)
        
        basketView.deleteItem.bind(onNext: weakify({ (item, wSelf) in
            wSelf.listener?.removeProduct(item: item)
        })).disposed(by: disposeBag)
        
         self.listener?.errorObserable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self](err) in
             AlertVC.showError(for: self, message: err.getMsg())
         }).disposed(by: disposeBag)
    }
    
    func bindData(listProductCategory: [DisplayProductCategory]) {
        self.form += listProductCategory.map({ self.bindSection(productCategory: $0) })
        DispatchQueue.main.async {
            guard let h = self.headerView else { return }
            self.tableView.bringSubviewToFront(h)
        }
    }
    
    func bindSection(productCategory: DisplayProductCategory) -> Section {
        guard let categoryId = productCategory.id else {
            fatalError("binding error")
        }
        var section = Section() { section in
            section.tag = "\(categoryId)"
            var header = HeaderFooterView<UIView>(.callback({
                let view = UIView()
                view.backgroundColor = .white
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
                return view
            }))
            header.height = { 50 }
            section.header = header
        }
        if let listProduct = productCategory.products {
            section += listProduct.compactMap({ $0 }).map({ self.bindRow(product: $0) })
        }
        return section
    }
    
    func bindRow(product: DisplayProduct) -> RowDetailGeneric<ElementCell> {
        guard let productId = product.productId else {
            fatalError("Binding error")
        }
        
        return RowDetailGeneric<ElementCell>.init("\(productId)", { (row) in
            row.value = product
            if let v = listener?.value(from: product) {
                row.cell.display(item: product, number: v)
            }
            row.onCellSelection { [weak self](_, _) in
                guard let wSelf = self else { return }
                wSelf.listener?.routeToProductMenu(item: product)
            }
            row.cell.editView.rx.controlEvent(.touchUpInside).bind(onNext: weakify({ (wSelf) in
                wSelf.listener?.routeToProductMenu(item: product)
            })).disposed(by: disposeBag)
        })
    }
}
