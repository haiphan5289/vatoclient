//  File name   : TipInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol TipRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TipPresentable: Presentable {
    var listener: TipPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TipListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func closeTip()
    func update(tip: Double)
}

final class TipInteractor: PresentableInteractor<TipPresentable>, TipInteractable, TipPresentableListener {
    weak var router: TipRouting?
    weak var listener: TipListener?

    private(set) var tipStream: MutableTip

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: TipPresentable, tipStream: MutableTip) {
        self.tipStream = tipStream
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

    func closeTip() {
        listener?.closeTip()
    }

    func update(tip: Double) {
        self.listener?.update(tip: tip)
    }
}
