//  File name   : NoteInteractor.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol NoteRouting: Routing {
    func cleanupViews()
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NoteListener: class {
    // todo: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class NoteInteractor: Interactor, NoteInteractable {
    weak var router: NoteRouting?
    weak var listener: NoteListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    override init() {}

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
