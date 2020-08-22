//  File name   : DeliveryBookingInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol DeliveryBookingRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DeliveryBookingPresentable: Presentable {
    var listener: DeliveryBookingPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol DeliveryBookingListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class DeliveryBookingInteractor: PresentableInteractor<DeliveryBookingPresentable> {
    /// Class's public properties.
    weak var router: DeliveryBookingRouting?
    weak var listener: DeliveryBookingListener?

    /// Class's constructor.
    override init(presenter: DeliveryBookingPresentable) {
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

// MARK: DeliveryBookingInteractable's members
extension DeliveryBookingInteractor: DeliveryBookingInteractable {
}

// MARK: DeliveryBookingPresentableListener's members
extension DeliveryBookingInteractor: DeliveryBookingPresentableListener {
}

// MARK: Class's private methods
private extension DeliveryBookingInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
