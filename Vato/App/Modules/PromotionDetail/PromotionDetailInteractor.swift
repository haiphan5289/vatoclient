//  File name   : PromotionDetailInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

enum PromotionDetailCommand {
    case apply
    case cancel
    case notUse
    case notify(index: Int)
}

protocol PromotionDetailRouting: ViewableRouting, RoutableProtocol {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol PromotionDetailPresentable: Presentable {
    var listener: PromotionDetailPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol PromotionDetailListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
//    func update(by commandDetail: PromotionDetailCommand)
    func dismissDetail()
}

final class PromotionDetailInteractor: PresentableInteractor<PromotionDetailPresentable>, PromotionDetailInteractable, PromotionDetailPresentableListener {
    weak var router: PromotionDetailRouting?
    weak var listener: PromotionDetailListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: PromotionDetailPresentable, with type: PromotionDetailPresentation, manifest: PromotionList.Manifest?, code: String) {
        self.currentType = type
        self.manifest = manifest
        self.code = code
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
    
    func dismissDetail() {
        self.listener?.dismissDetail()
    }
    
    private(set) var manifest: PromotionList.Manifest?
    private(set) var code: String
    private(set) var currentType: PromotionDetailPresentation
}
