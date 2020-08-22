//  File name   : EcomReceiptVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol EcomReceiptPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var order: Observable<SalesOrder> { get }
    
    func ecomReceiptMoveBack()
    func ecomReceiptPreorder()
}

final class EcomReceiptVC: FormViewController, EcomReceiptPresentable, EcomReceiptViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: EcomReceiptPresentableListener?
    private lazy var disposeBag = DisposeBag()
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .grouped)
        let w = UIScreen.main.bounds.width / 2
        tableView.separatorInset = UIEdgeInsets(top: 0, left: w, bottom: 0, right: w)
    }

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
    
    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { return 0.1 }
    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? { return nil }
    /// Class's private properties.
}

// MARK: View's event handlers
extension EcomReceiptVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension EcomReceiptVC {
}

// MARK: Class's private methods
private extension EcomReceiptVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        UIApplication.setStatusBar(using: .lightContent)
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        title = "Chi tiết chuyến đi"
        let btn = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        btn.setImage(UIImage(named: "ic_close_white"), for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
        let rightView = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = rightView
        
        btn.rx.tap.bind { [weak self] in
            self?.listener?.ecomReceiptMoveBack()
        }.disposed(by: disposeBag)
        
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let btnPreOrder = UIButton(frame: .zero)
        btnPreOrder.applyButton(style: StyleButton(view: .default, textColor: .white, font: .systemFont(ofSize: 16, weight: .semibold), cornerRadius: 24, borderWidth: 1, borderColor: .clear))
        btnPreOrder.setTitle(Text.preorder.localizedText, for: .normal)
        btnPreOrder >>> view >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-16)
                make.height.equalTo(48)
            }
        }
        
        btnPreOrder.rx.tap.bind { [weak self] in
            self?.listener?.ecomReceiptPreorder()
        }.disposed(by: disposeBag)
        
        tableView >>> view >>> {
            $0.backgroundColor = .clear
            $0.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.bottom.equalTo(btnPreOrder.snp.top).offset(-16)
            }
        }
    }
    
    func setup(item: SalesOrder) {
        let headerView = EcomReceiptShortInfoView.loadXib()
        headerView.setupDisplay(item: item)
        let s = headerView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: .infinity), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        headerView.frame = CGRect(origin: .zero, size: s)
        tableView.tableHeaderView = headerView
        let section1 = Section { (s) in
            s.tag = "section1"
            var footerView = HeaderFooterView<UIView>.init(.callback({ () -> UIView in
                let v = UIView(frame: .zero)
                v.backgroundColor = .clear
                return v
            }))
            footerView.height = { 9 }
            s.footer = footerView
        }
        
        let origin = item.originLocation ?? ""
        let destination = item.destLocation ?? ""
        let addressCell = RowDetailGeneric<InTripAddressCell>.init(InTripCellType.addressInfo.rawValue) { (row) in
            row.value = [origin, destination]
        }
        section1 <<< addressCell
        
        let section2 = Section { (s) in
            s.tag = "section2"
        }
        
        let titleCell = RowDetailGeneric<EcomTitleCell>.init("TitleCell") { (row) in
            row.value = "Đơn hàng từ \(origin)"
        }
        section2 <<< titleCell
        let orderItems = item.orderItems ?? []
        orderItems.forEach { (order) in
            let cell = RowDetailGeneric<EcomItemCell>.init(order.name ?? "") { (row) in
                row.value = order
            }
            section2 <<< cell
        }
        var styles = [PriceInfoDisplayStyle]()
        let d1 = PriceInfoDisplayStyle(attributeTitle: "Phí đơn hàng".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (item.baseGrandTotal?.currency ?? "").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
        styles.append(d1)
        let d2 = PriceInfoDisplayStyle(attributeTitle: "Phí giao hàng".attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (item.salesOrderShipments?.first?.price?.currency ?? "").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: false, edge: .zero)
        styles.append(d2)
        
        if let shippingFree = item.discountShippingFee, shippingFree > 0 {
            let att4 = FwiLocale.localized("Hỗ trợ giao hàng").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            let price4 = (0 - shippingFree).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
            let d3 = PriceInfoDisplayStyle(attributeTitle: att4, attributePrice: price4, showLine: false, edge: .zero)
            styles.append(d3)
        }
        
        if let vatoDiscountShippingFee = item.vatoDiscountShippingFee, vatoDiscountShippingFee > 0 {
            let att4 = FwiLocale.localized("Vato KM vận chuyển").attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            let price4 = (0 - vatoDiscountShippingFee).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
            let d3 = PriceInfoDisplayStyle(attributeTitle: att4, attributePrice: price4, showLine: false, edge: .zero)
            styles.append(d3)
        }
        
        item.vatoCampaignDiscountInfo?.forEach({ (i) in
            guard i.value > 0 else { return }
            let att0 = i.key.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            let price0 = (0 - i.value).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
            let d0 = PriceInfoDisplayStyle(attributeTitle: att0, attributePrice: price0, showLine: false, edge: .zero)
            styles.append(d0)
        })
        
        if (item.discountAmount ?? 0) > 0 {
            let att5 = Text.promotion.localizedText.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey)
            let price5 = (0 - (item.discountAmount ?? 0)).currency.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.orange)
            let d4 = PriceInfoDisplayStyle(attributeTitle: att5, attributePrice: price5, showLine: false, edge: .zero)
            styles.append(d4)
        }
        
        let desPayment = item.salesOrderPayments?.first?.paymentMethodDes ?? ""
        let d5 = PriceInfoDisplayStyle(attributeTitle: desPayment.attribute >>> .font(f: .systemFont(ofSize: 15, weight: .regular)) >>> .color(c: Color.battleshipGrey), attributePrice: (item.grandTotal?.currency ?? "").attribute >>> .font(f: .systemFont(ofSize: 20, weight: .medium)) >>> .color(c: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)), showLine: true, edge: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        styles.append(d5)
        let priceCell = RowDetailGeneric<AddDestinationPriceCell>.init("AddDestinationPriceCell") { (row) in
            row.value = styles
        }
        section2 <<< priceCell
        
        UIView.performWithoutAnimation {
            self.form += [section1, section2]
        }
        
    }
    
    func setupRX() {
        listener?.order.bind(onNext: weakify({ (order, wSelf) in
            wSelf.setup(item: order)
        })).disposed(by: disposeBag)
    }
}
