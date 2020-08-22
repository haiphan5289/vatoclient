//  File name   : CheckOutVC.swift
//
//  Author      : khoi tran
//  Created date: 12/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCore
import FwiCoreRX
import RxSwift
import Eureka

protocol CheckOutPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var receiver: Observable<DestinationDisplayProtocol> { get }
    var basket: Observable<BasketModel> { get }
    var quoteCart: Observable<QuoteCart?> { get }
    var timeDelivery: Observable<DateTime?> { get }
    var errorObserable: Observable<MerchantState>{ get }
    var loadingProgress: Observable<ActivityProgressIndicator.Element> { get }
    var store: Observable<FoodExploreItem?> { get }
    var listPromotions: Observable<[EcomPromotionDisplay]?> { get }
    var paymentStream: PaymentStream { get }
    var eMethod: Observable<PaymentCardDetail> { get }

    func dismissCheckOut()
    func routeToLocationPicker()
    func routeToChooseTime()
    func move(to type: BookingConfirmType)
    func routeToProductMenu(productId: Int)
    func routeToFoodDetail()
    func routeToTopup()
    func clearBasket()
    func routeToPromotionStore()
    func removePromotionItem()
    func removeProduct(productId: Int)
    func applyPromotion(item: EcomPromotion?)
    func update(payment method: PaymentCardDetail)
    func routeToAddCard()
    func changeInfoOrder()
}

final class CheckOutVC: FormViewController, CheckOutPresentable, CheckOutViewControllable, DisposableProtocol, LoadingAnimateProtocol {
    private struct Config {
        static let DeliverySection = "DeliverySection"
        static let DeliveryPickUpTimeSection = "DeliveryPickUpTimeSection"
        static let DeliveryBasketSection = "DeliveryBasketSection"
        static let DeliveryBasketHeaderCell = "DeliveryBasketHeaderCells"
        static let DeliveryCellIdentifier = "DeliveryCellIdentifier"
        static let DeliveryPickUpTimeCell = "DeliveryPickUpTimeCell"
        static let DeliveryBasketDetailPriceCell = "DeliveryBasketDetailPriceCell"
    }
    
    /// Class's public properties.
    weak var listener: CheckOutPresentableListener?
    internal lazy var disposeBag = DisposeBag()
    private lazy var bookingConfirmView: CheckOutBookingView = CheckOutBookingView.loadXib()
    private var paymentView: VatoPaymentSelectView?
    private var source: [EcomPromotionDisplay] = [] {
        didSet {
            DispatchQueue.main.async {
                self.bookingConfirmView.updateListPromotions(list: self.source)
                self.updateSelectItemPromotion()
            }
        }
    }
    
    private func updateSelectItemPromotion() {
        guard let idx = self.source.firstIndex(where: { $0.applied == true }) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.bookingConfirmView.collectionView?.scrollToItem(at: IndexPath(item: idx, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    // MARK: View's lifecycle
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        let w = UIScreen.main.bounds.width / 2
        tableView.separatorInset = UIEdgeInsets(top: 0, left: w, bottom: 0, right: w)
        self.tableView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defer {
            let userId = Auth.auth().currentUser?.uid ?? ""
            LogEventHelper.log(key: "food_checkout_iOS", params: ["user": userId])
        }
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.setStatusBar(using: .default)
        localize()
    }

    /// Class's private properties.
    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? { return nil }
    override func tableView(_: UITableView, heightForFooterInSection s: Int) -> CGFloat { return 0.1 }
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return UIView.create{ $0.backgroundColor = .clear } }
    override func tableView(_: UITableView, heightForHeaderInSection s: Int) -> CGFloat { return 10 }
}

// MARK: View's event handlers
extension CheckOutVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func showDetailPromotion(promotionItem: EcomPromotion?, removed: Bool) {
        FoodDetailPromotionVC.showDetailPromotion(on: self,
                                                  foodSales: promotionItem,
                                                  removed: removed)
            .bind(onNext: weakify({ (type, wSelf) in
                switch type {
                case .remove:
                    wSelf.listener?.removePromotionItem()
                case .apply:
                    wSelf.listener?.applyPromotion(item: promotionItem)
                default:
                    break
                }
                guard type == .remove else { return }
                wSelf.listener?.removePromotionItem()
        })).disposed(by: disposeBag)
    }
    
    func showAlertComfirmClearBasket() {
        let okAction = AlertAction(style: .default, title: Text.ok.localizedText, handler: { [weak self] in
            defer {
                let userId = Auth.auth().currentUser?.uid ?? ""
                LogEventHelper.log(key: "food_clear_basket_iOS", params: ["user": userId])
            }
            self?.listener?.clearBasket()
        })
        
        AlertVC.show(on: self, title: Text.notification.localizedText, message: Text.emptyBasketAlert.localizedText, from: [okAction], orderType: .horizontal)
    }
}

// MARK: Class's public methods
extension CheckOutVC {
    func update(from type: BookingConfirmUpdateType) {
        self.bookingConfirmView.eUpdate.onNext(type)
    }
    
    func showAlertTopUp() {
        AlertVC.showMessageAlert(for: UIApplication.topViewController(controller: self),
                                 title: Text.walletVATOPayNotEnoughBalance.localizedText,
                                 message: Text.walletVATOPayNotEnoughBalanceMessage.localizedText,
                                 actionButton1: Text.cancel.localizedText,
                                 actionButton2: Text.depositVATOPay.localizedText,
                                 handler1: nil,
                                 handler2: { [weak self] in
                                    self?.listener?.routeToTopup()
        })
    }
    
    func resetListenAddCard() {
        paymentView?.resetListenAddCard()
    }
    
    func cleanUpWindows(completion: (() -> ())?) {
        if self.presentedViewController != nil {
            self.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
    }
    
    func alertNotifyRemoveOrder(cancel: @escaping AlertBlock, ok: @escaping AlertBlock) {
        let topVC = UIApplication.topViewController(controller: self)
        let cancelAction = AlertAction(style: .cancel, title: Text.cancel.localizedText, handler: cancel)
        let okAction = AlertAction(style: .default, title: Text.ok.localizedText, handler: ok)
        AlertVC.show(on: topVC, title: Text.notification.localizedText, message: FwiLocale.localized("Bạn có đơn hàng đang chờ thanh toán. Bạn có muốn huỷ đơn hàng không?"), from: [cancelAction, okAction], orderType: .horizontal)
    }
}

// MARK: Class's private methods
private extension CheckOutVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.setupNavigation()
        
        let section1 = Section() { (s) in
            s.tag = Config.DeliverySection
        }
        
        let receiver = DeliveryInputInformation.init(type: .receiver)
        section1 <<< self.createDeliveryCell(item: receiver)
        
        let section2 = Section() { (s) in
            s.tag = Config.DeliveryPickUpTimeSection
        }
        
        section2 <<<  RowDetailGeneric<TimeSelectionCell>.init(Config.DeliveryPickUpTimeCell , { [weak self] (row) in
            row.cell.schedulerButton.isUserInteractionEnabled = false
            row.onCellSelection({ [weak self] (cell, row) in
                self?.listener?.routeToChooseTime()
            })
        })
        
        UIView.performWithoutAnimation {
            self.form += [section1, section2]
        }
        
        bookingConfirmView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.bottom.left.right.equalToSuperview()
            })
        }
        
        tableView >>> {
            $0?.snp.makeConstraints({ (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
                make.bottom.equalTo(bookingConfirmView.snp.top).priority(.high)
            })
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        guard let listener = listener else { return }
        let vPayment = VatoPaymentSelectView.createPaymentView(use: listener.paymentStream, service: .service(service: .food))
        vPayment >>> bookingConfirmView.containerPayment >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        vPayment.loadDefaultMethod = false
        vPayment.controller = self
        vPayment.updateLayout.bind { [weak self](constant) in
            UIView.animate(withDuration: 0.3) {
                self?.bookingConfirmView.hContainerPayment?.constant = constant
                self?.view.layoutIfNeeded()
            }
        }.disposed(by: disposeBag)
        vPayment.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), position: .top)
//        vPayment.addSeperator(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        self.paymentView = vPayment
        loadMethodQuote()
    }
    
    private func setupListenChangeMethod() {
        paymentView?.selected.skip(1).distinctUntilChanged().bind(onNext: weakify({ (card, wSelf) in
            if card.addCard {
                wSelf.listener?.routeToAddCard()
            } else {
                wSelf.listener?.update(payment: card)
            }
        })).disposed(by: disposeBag)
    }
    
    private func loadMethodQuote() {
        listener?.eMethod.take(1).bind(onNext: weakify({ (card, wSelf) in
            wSelf.paymentView?.select(card: card)
            wSelf.setupListenChangeMethod()
        })).disposed(by: disposeBag)
    }
    
    struct CheckOutAction: AlertActionProtocol {
        var autoDismiss = false
        let handler: AlertBlock
        var invokedDismissMethod: Observable<Void> {
            return Observable.empty()
        }
        var custom: ((UIButton) -> ())?
        func apply(button: UIButton) {
            custom?(button)
        }
    }
    
    private func moveTo(type: BookingConfirmType) {
        let action: AlertBlock = { [weak self] in
            self?.listener?.move(to: type)
        }
        
        if type == .booking {
            let checkoutView = CheckOutConfirmView.loadXib()
            checkoutView.setupDisplay(item: listener?.quoteCart.filterNil())
            let cancel = CheckOutAction(handler: weakify({ (wSelf) in
                wSelf.listener?.changeInfoOrder()
            })) { (button) in
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                button.setTitleColor(#colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1), for: .normal)
                button.setTitle(FwiLocale.localized("Thay đổi"), for: .normal)
            }
            
            let ok = CheckOutAction(handler: action) { (button) in
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                button.setTitleColor(#colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), for: .normal)
                button.setTitle(FwiLocale.localized("Xác nhận"), for: .normal)
            }
            
            self.listener?.timeDelivery.bind(onNext: { [weak checkoutView](item) in
                guard let dateTime = item else {
                    checkoutView?.lblTime?.text = Text.asSoonAsPossible.localizedText
                    return
                }
                
                checkoutView?.lblTime?.text = dateTime.string()
            }).disposed(by: disposeBag)
            
            AlertCustomVC.show(on: self, option: .customView, arguments: [.customView: checkoutView], buttons: [cancel, ok], orderType: .horizontal, alignment: .fill)
        } else {
           action()
        }
    }
    
    private func setupRX() {
        bookingConfirmView.applyPromotion.bind(onNext: weakify({ (item, wSelf) in
            if item.applied {
                wSelf.listener?.removePromotionItem()
            } else {
                wSelf.listener?.applyPromotion(item: item.promotion)
            }
        })).disposed(by: disposeBag)
        
        bookingConfirmView.collectionView?.rx.itemSelected.map({ [weak self](idx) -> EcomPromotionDisplay? in
            return self?.source[safe: idx.item]
        }).filterNil().bind(onNext: weakify({ (item, wSelf) in
            wSelf.showDetailPromotion(promotionItem: item.promotion, removed: item.applied)
        })).disposed(by: disposeBag)
        
        listener?.listPromotions.filterNil().bind(onNext: weakify({ (list, wSelf) in
            wSelf.source = list
        })).disposed(by: disposeBag)
        
        showLoading(use: listener?.loadingProgress)
        self.bookingConfirmView.eAction.debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.instance).bind { [weak self] in
            self?.moveTo(type: $0)
        }.disposed(by: disposeBag)
        
        self.listener?.receiver.bind(onNext: {[weak self] (d) in
            guard let wSelf = self else { return }
            wSelf.updateDeliveryCell(item: d)
        }).disposed(by: disposeBag)
        
        self.listener?.timeDelivery.bind(onNext: {[weak self] (d) in
            guard let wSelf = self else { return }
            wSelf.updateTimeDeliveryCell(item: d)
        }).disposed(by: disposeBag)
        
        self.listener?.quoteCart.bind(onNext: {[weak self] (q) in
            guard let wSelf = self, let quoteCart = q else { return }
            
            UIView.performWithoutAnimation {
                wSelf.form += [wSelf.generateBasketSection(item: quoteCart)]
            }
            
            wSelf.bookingConfirmView.setupDisplay(item: quoteCart)
            wSelf.setupDisplay(item: quoteCart)
        }).disposed(by: disposeBag)
        
        self.listener?.errorObserable.observeOn(MainScheduler.asyncInstance).bind(onNext: { [weak self](err) in
            let topUpVC = UIApplication.topViewController(controller: self)
            AlertVC.showError(for: topUpVC, message: err.getMsg())
        }).disposed(by: disposeBag)
        
        self.listener?.store.bind(onNext: weakify({ (store, wSelf) in
            wSelf.title = store?.name ?? Text.confirmOrder.localizedText
        })).disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.backgroundColor = .white
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .black
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0), .font: UIFont.systemFont(ofSize: 18, weight: .medium)]
        
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        
        self.title = Text.confirmOrder.localizedText
        button.rx.tap.bind { [weak self] () in
            guard let me = self else { return }
            defer {
                let userId = Auth.auth().currentUser?.uid ?? ""
                LogEventHelper.log(key: "food_cancel_checkout_iOS", params: ["user": userId])
            }
            
            me.listener?.dismissCheckOut()
        }.disposed(by: disposeBag )
    }
    
    private func createDeliveryCell(item: DestinationDisplayProtocol) -> RowDetailGeneric<CheckOutInformationCell> {
        return RowDetailGeneric<CheckOutInformationCell>.init(Config.DeliveryCellIdentifier , { [weak self] (row) in
            guard let me = self else { return }
            row.cell.updateData(item: item)
            row.onCellSelection({ [weak self] (cell, row) in
                self?.listener?.routeToLocationPicker()
            })
            row.cell.rightIconButton.rx.tap.bind(onNext: { [weak self] in
                guard let me = self else { return }
                me.listener?.routeToLocationPicker()
            }).disposed(by: me.disposeBag)
        })
    }
    
    private func updateDeliveryCell(item: DestinationDisplayProtocol) {
        guard let section = self.form.sectionBy(tag: Config.DeliverySection) else {
            return
        }
        if !section.isEmpty {
            section.remove(at: 0)
        }
        section <<< self.createDeliveryCell(item: item)
    }

    private func updateTimeDeliveryCell(item: DateTime?) {
        guard let timeCell = self.form.rowBy(tag: Config.DeliveryPickUpTimeCell) as? RowDetailGeneric<TimeSelectionCell> else {
            return
        }
        timeCell.cell.setupDisplay(item: item)
    }
    
    private func generateBasketSection(item: QuoteCart) -> Section {
        
        self.form.removeAll { (s) -> Bool in
            return s.tag == Config.DeliveryBasketSection
        }
        
        let section = Section() { (s) in
            s.tag = Config.DeliveryBasketSection
        }
        
        section <<< RowDetailGeneric<BasketItemHeaderCell>.init(Config.DeliveryBasketHeaderCell , {(row) in
            row.cell.addButton.rx.tap
                .takeUntil(row.cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .bind(onNext: weakify({ (wSelf) in
                    wSelf.listener?.routeToFoodDetail()
                })).disposed(by: disposeBag)
        })
        
        item.quoteItems?.forEach({
            section <<< self.generateBasketItemCell(item: $0)
        })
        
        return section
    }
    
    private func generateBasketItemCell(item: QuoteItem) -> RowDetailGeneric<BasketItemCell> {
        guard let productId = item.productId else {
            fatalError("error")
        }
        
        return RowDetailGeneric<BasketItemCell>.init("\(productId)" , {(row) in
            row.value = item
            row.onCellSelection {[weak self] (cell, row) in
                guard let wSelf = self else { return }
                wSelf.listener?.routeToProductMenu(productId: productId)
            }
            
            row.cell.btnDelete.rx.tap.bind(onNext: { [weak self] in
                self?.listener?.removeProduct(productId: productId)
            }).disposed(by: disposeBag)
            
            row.cell.editView.rx.controlEvent(.touchUpInside)
                .takeUntil(row.cell.rx.methodInvoked(#selector(UITableViewCell.prepareForReuse)))
                .bind(onNext: weakify({ (wSelf) in
                    wSelf.listener?.routeToProductMenu(productId: productId)
                })).disposed(by: disposeBag)
        })
    }
    
    func setupDisplay(item: QuoteCart?) {
        guard var s = form.sectionBy(tag: Config.DeliveryBasketSection) else {
            return
        }
        
        s.removeAll { (r) -> Bool in
            r.tag == Config.DeliveryBasketDetailPriceCell
        }
        
        s <<< RowDetailGeneric<CheckOutDetailPriceCell>.init(Config.DeliveryBasketDetailPriceCell, { (r) in
            r.value = item
        })
    }
}
