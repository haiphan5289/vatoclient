//  File name   : ExpressHistoryDetailInteractor.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

struct DeliveryLocation {
    var adress: String = "102 Trần Hưng Đạo, Phường Phạm Ngũ Lão, Quận 1, Hồ Chí Minh"
}


protocol ExpressHistoryDetailRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
    func routeQRCode()
}

protocol ExpressHistoryDetailPresentable: Presentable {
    var listener: ExpressHistoryDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol ExpressHistoryDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func historyDetailMoveBack()
}

final class ExpressHistoryDetailInteractor: PresentableInteractor<ExpressHistoryDetailPresentable> {
    /// Class's public properties.
    weak var router: ExpressHistoryDetailRouting?
    weak var listener: ExpressHistoryDetailListener?

    /// Class's constructor.
    override init(presenter: ExpressHistoryDetailPresentable) {
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

// MARK: ExpressHistoryDetailInteractable's members
extension ExpressHistoryDetailInteractor: ExpressHistoryDetailInteractable {
}

// MARK: ExpressHistoryDetailPresentableListener's members
extension ExpressHistoryDetailInteractor: ExpressHistoryDetailPresentableListener {
    func routeQRCode() {
        router?.routeQRCode()
    }
    
    func historyDetailMoveBack() {
        self.listener?.historyDetailMoveBack()
    }
}

// MARK: Class's private methods
private extension ExpressHistoryDetailInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
