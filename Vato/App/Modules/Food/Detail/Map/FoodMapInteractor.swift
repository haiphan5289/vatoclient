//  File name   : FoodMapInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/31/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol FoodMapRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol FoodMapPresentable: Presentable {
    var listener: FoodMapPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol FoodMapListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
    func foodMapMoveBack()
}

final class FoodMapInteractor: PresentableInteractor<FoodMapPresentable> {
    /// Class's public properties.
    weak var router: FoodMapRouting?
    weak var listener: FoodMapListener?

    /// Class's constructor.
    init(presenter: FoodMapPresentable, item: FoodExploreItem) {
        self.item = item
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
    var item: FoodExploreItem
}

// MARK: FoodMapInteractable's members
extension FoodMapInteractor: FoodMapInteractable {
}

// MARK: FoodMapPresentableListener's members
extension FoodMapInteractor: FoodMapPresentableListener {
    func foodMapMoveBack() {
        listener?.foodMapMoveBack()
    }
}

// MARK: Class's private methods
private extension FoodMapInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }
}
