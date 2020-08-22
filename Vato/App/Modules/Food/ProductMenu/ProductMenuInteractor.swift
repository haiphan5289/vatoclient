//  File name   : ProductMenuInteractor.swift
//
//  Author      : khoi tran
//  Created date: 12/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift



protocol ProductMenuRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ProductMenuPresentable: Presentable {
    var listener: ProductMenuPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ProductMenuListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func productMenuMoveBack()
    func productMenuConfirm(product: DisplayProduct, basketItem: BasketStoreValueProtocol?)
}

final class ProductMenuInteractor: PresentableInteractor<ProductMenuPresentable> {
    /// Class's public properties.
    weak var router: ProductMenuRouting?
    weak var listener: ProductMenuListener?

    var basketItem: ProductMenuItem?
    private var mMinValue = 0
    /// Class's constructor.
    init(presenter: ProductMenuPresentable, basketItem: ProductMenuItem?, minValue: Int) {
        self.basketItem = basketItem
        self.mMinValue = minValue
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
}

// MARK: ProductMenuInteractable's members
extension ProductMenuInteractor: ProductMenuInteractable {
}

// MARK: ProductMenuPresentableListener's members
extension ProductMenuInteractor: ProductMenuPresentableListener {
    var item: ProductMenuItem? {
        return basketItem
    }
    
    var minValue: Int {
        return mMinValue
    }
    
    func productMenuMoveBack() {
        self.listener?.productMenuMoveBack()
    }
    
    func productMenuConfirm(basketItem: BasketStoreValueProtocol?) {
        guard let productItem = self.item else {
            return
        }
        self.listener?.productMenuConfirm(product: productItem.product, basketItem: basketItem?.quantity == 0 ? nil: basketItem)
    }
}

// MARK: Class's private methods
private extension ProductMenuInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
