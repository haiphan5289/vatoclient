//  File name   : ConfirmDetailInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol ConfirmDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ConfirmDetailPresentable: Presentable {
    var listener: ConfirmDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ConfirmDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func closeDetailPrice()
    func detailBook()
}

final class ConfirmDetailInteractor: PresentableInteractor<ConfirmDetailPresentable>, ConfirmDetailInteractable, ConfirmDetailPresentableListener {
    weak var router: ConfirmDetailRouting?
    weak var listener: ConfirmDetailListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: ConfirmDetailPresentable, priceUpdate: PriceStream, transportStream: TransportStream, promotionStream: PromotionStream) {
        self.priceUpdate = priceUpdate
        self.transportStream = transportStream
        self.promotionStream = promotionStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    func closeDetail() {
        self.listener?.closeDetailPrice()
    }

    func detailBook() {
        self.listener?.detailBook()
    }

    private(set) var priceUpdate: PriceStream
    private(set) var transportStream: TransportStream
    private(set) var promotionStream: PromotionStream
}
