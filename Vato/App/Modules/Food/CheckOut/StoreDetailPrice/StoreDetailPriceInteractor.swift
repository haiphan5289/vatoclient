//  File name   : StoreDetailPriceInteractor.swift
//
//  Author      : khoi tran
//  Created date: 12/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol StoreDetailPriceRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol StoreDetailPricePresentable: Presentable {
    var listener: StoreDetailPricePresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol StoreDetailPriceListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func detailPriceCheckOut()
    func detailPriceDismiss()
}

final class StoreDetailPriceInteractor: PresentableInteractor<StoreDetailPricePresentable> {
    /// Class's public properties.
    weak var router: StoreDetailPriceRouting?
    weak var listener: StoreDetailPriceListener?

    /// Class's constructor.
    init(presenter: StoreDetailPricePresentable, mutableStoreStream: MutableStoreStream) {
        self.mutableStoreStream = mutableStoreStream
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
    private let mutableStoreStream: MutableStoreStream

}

// MARK: StoreDetailPriceInteractable's members
extension StoreDetailPriceInteractor: StoreDetailPriceInteractable {
    var quoteCard: Observable<QuoteCart?> {
        return mutableStoreStream.quoteCart
    }
    
    func checkOut() {
        self.listener?.detailPriceCheckOut()
    }
    
    func dismiss() {
        self.listener?.detailPriceDismiss()
    }
    
}

// MARK: StoreDetailPricePresentableListener's members
extension StoreDetailPriceInteractor: StoreDetailPricePresentableListener {
}

// MARK: Class's private methods
private extension StoreDetailPriceInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
