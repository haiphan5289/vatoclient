//  File name   : NoteRouter.swift
//
//  Author      : Dung Vu
//  Created date: 9/19/18
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
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class NoteRouter: ViewableRouter<NoteInteractable, NoteViewControllable>, NoteRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: NoteInteractable, viewController: NoteViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
