//  File name   : CheckOutConfirmView.swift
//
//  Author      : Dung Vu
//  Created date: 7/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import FwiCore
import RxSwift

final class CheckOutConfirmView: UIView, UpdateDisplayProtocol, Weakifiable {
    /// Class's public properties.
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblTitleDest: UILabel?
    @IBOutlet var lblDest: UILabel?
    @IBOutlet var lblTitleNumberItem: UILabel?
    @IBOutlet var lblNumberItem: UILabel?
    @IBOutlet var lblTitleTime: UILabel?
    @IBOutlet var lblTime: UILabel?
    @IBOutlet var lblPaymentMethod: UILabel?
    @IBOutlet var lblPrice: UILabel?
    @IBOutlet var bgMethod: UIView?
    
    private lazy var disposeBag = DisposeBag()
    /// Class's private properties.
    
    func setupDisplay(item: Observable<QuoteCart>?) {
        item?.bind(onNext: weakify({ (quoteCard, wSelf) in
            let a = quoteCard.quoteAddresses?.first
            let p = quoteCard.quotePayments?.first
            
            wSelf.lblDest?.text = a?.address
            let qty = quoteCard.quoteItems?.compactMap(\.qty).reduce(0, { $0 + $1 })
            wSelf.lblNumberItem?.text = "\(qty.orNil(0))"
            wSelf.lblPrice?.text = quoteCard.grandTotal?.currency
            guard let method = PaymentCardType(rawValue: p?.paymentMethod ?? -1) else { return }
            wSelf.bgMethod?.backgroundColor = method.color
            wSelf.lblPaymentMethod?.text = method.generalName
        })).disposed(by: disposeBag)
    }
}

// MARK: Class's public methods
extension CheckOutConfirmView {
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        visualize()
    }
}

// MARK: Class's private methods
private extension CheckOutConfirmView {
    private func initialize() {
        // todo: Initialize view's here.
        lblTitle?.text = FwiLocale.localized("Xác nhận đơn hàng")
        lblTitleDest?.text = FwiLocale.localized("Giao hàng tới")
        lblTitleNumberItem?.text = FwiLocale.localized("Số sản phẩm")
        lblTitleTime?.text = FwiLocale.localized("Hẹn giờ")
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
}
