//  File name   : StoreBasketControl.swift
//
//  Author      : Dung Vu
//  Created date: 11/28/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol StoreBasketListenerProtocol: AnyObject {
    var basket: Observable<BasketModel> { get }
}

final class StoreBasketControl: UIControl, Weakifiable {
    struct Configs {
        static let formatItem = "%d món"
    }
    /// Class's public properties.
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblNumber: UILabel?
    @IBOutlet var lblPrice: UILabel?
    /// Class's private properties.
    weak var listener: StoreBasketListenerProtocol? {
        didSet {
            setupRX()
        }
    }
    private var dispose: Disposable?
    
    private func setupRX() {
        guard let basket = listener?.basket else {
            return
        }
        dispose?.dispose()
        dispose = basket.bind(onNext: weakify({ (products, wSelf) in
            var numberItems = 0
            let totalPrice = products.reduce(0, { (old, item) -> Double in
                let p = item.key.price ?? 0
                numberItems += item.value.quantity
                let next = p * Double(item.value.quantity)
                return old + next
            })
            
            wSelf.lblNumber?.text = String(format: Configs.formatItem, numberItems)
            wSelf.lblPrice?.text = totalPrice.currency
            
        }))
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        dispose?.dispose()
    }
    
}

// MARK: Class's public methods
extension StoreBasketControl {
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
private extension StoreBasketControl {
    private func initialize() {
        // todo: Initialize view's here.
        clipsToBounds = true
    }
    private func visualize() {
        // todo: Visualize view's here.
        let h = self.bounds.height
        layer.cornerRadius = h / 2
    }
}
