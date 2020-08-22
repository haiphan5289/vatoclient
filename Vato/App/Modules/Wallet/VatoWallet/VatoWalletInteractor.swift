//  File name   : VatoWalletInteractor.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol VatoWalletRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol VatoWalletPresentable: Presentable {
    var listener: VatoWalletPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol VatoWalletListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class VatoWalletInteractor: PresentableInteractor<VatoWalletPresentable>, VatoWalletInteractable, VatoWalletPresentableListener {
    weak var router: VatoWalletRouting?
    weak var listener: VatoWalletListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init(presenter: VatoWalletPresentable) {
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
}
