//  File name   : EcomReceiptInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 3/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol EcomReceiptRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol EcomReceiptPresentable: Presentable {
    var listener: EcomReceiptPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol EcomReceiptListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func ecomReceiptMoveBack()
    func ecomReceiptPreorder(item: SalesOrder)
}

final class EcomReceiptInteractor: PresentableInteractor<EcomReceiptPresentable> {
    /// Class's public properties.
    weak var router: EcomReceiptRouting?
    weak var listener: EcomReceiptListener?

    /// Class's constructor.
    init(presenter: EcomReceiptPresentable, order: SalesOrder) {
        super.init(presenter: presenter)
        presenter.listener = self
        mOrder = order
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
    @Replay(queue: MainScheduler.asyncInstance) private var mOrder: SalesOrder
}

// MARK: EcomReceiptInteractable's members
extension EcomReceiptInteractor: EcomReceiptInteractable, Weakifiable {
}

// MARK: EcomReceiptPresentableListener's members
extension EcomReceiptInteractor: EcomReceiptPresentableListener {
    var order: Observable<SalesOrder> {
        return $mOrder
    }
    
    func ecomReceiptMoveBack() {
        listener?.ecomReceiptMoveBack()
    }
    
    func ecomReceiptPreorder() {
        $mOrder.take(1).bind(onNext: weakify({ (item, wSelf) in
            wSelf.listener?.ecomReceiptPreorder(item: item)
        })).disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension EcomReceiptInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
