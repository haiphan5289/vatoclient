//  File name   : TicketDetailInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol TicketDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol TicketDetailPresentable: Presentable {
    var listener: TicketDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol TicketDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class TicketDetailInteractor: PresentableInteractor<TicketDetailPresentable> {
    /// Class's public properties.
    weak var router: TicketDetailRouting?
    weak var listener: TicketDetailListener?

    /// Class's constructor.p
    override init(presenter: TicketDetailPresentable) {
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

// MARK: TicketDetailInteractable's members
extension TicketDetailInteractor: TicketDetailInteractable {
}

// MARK: TicketDetailPresentableListener's members
extension TicketDetailInteractor: TicketDetailPresentableListener {
}

// MARK: Class's private methods
private extension TicketDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
