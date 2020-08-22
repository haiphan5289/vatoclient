//  File name   : OrderContractInteractor.swift
//
//  Author      : Phan Hai
//  Created date: 18/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol OrderContractRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeToChatOC()
}

protocol OrderContractPresentable: Presentable {
    var listener: OrderContractPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol OrderContractListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func moveBackCarContract()
}

final class OrderContractInteractor: PresentableInteractor<OrderContractPresentable> {
    /// Class's public properties.
    weak var router: OrderContractRouting?
    weak var listener: OrderContractListener?

    /// Class's constructor.
    override init(presenter: OrderContractPresentable) {
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

// MARK: OrderContractInteractable's members
extension OrderContractInteractor: OrderContractInteractable {
    func moveBackOC() {
        self.router?.dismissCurrentRoute(completion: nil)
    }
}

// MARK: OrderContractPresentableListener's members
extension OrderContractInteractor: OrderContractPresentableListener {
    func moveBackCarContract() {
        self.listener?.moveBackCarContract()
    }
    func moveToChatOC() {
        self.router?.routeToChatOC()
    }
}

// MARK: Class's private methods
private extension OrderContractInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
