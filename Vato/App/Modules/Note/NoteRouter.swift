//  File name   : NoteRouter.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol NoteInteractable: Interactable {
    var router: NoteRouting? { get set }
    var listener: NoteListener? { get set }
}

protocol NoteViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
}

final class NoteRouter: Router<NoteInteractable>, NoteRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    init(interactor: NoteInteractable, viewController: NoteViewControllable) {
        self.viewController = viewController
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        // todo: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }

    /// Class's private properties
    private let viewController: NoteViewControllable
}
