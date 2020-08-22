//  File name   : PromotionSearchInteractor.swift
//
//  Author      : Dung Vu
//  Created date: 10/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol PromotionSearchRouting: Routing {
    func cleanupViews()
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol PromotionSearchListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
//    func 
}

final class PromotionSearchInteractor: Interactor, PromotionSearchInteractable {

    weak var router: PromotionSearchRouting?
    weak var listener: PromotionSearchListener?
    private(set) var searchStream: PromotionSearchStream
    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    
    init(searchStream: PromotionSearchStream) {
        self.searchStream = searchStream
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()

        router?.cleanupViews()
        // todo: Pause any business logic.
    }
    
    
}
