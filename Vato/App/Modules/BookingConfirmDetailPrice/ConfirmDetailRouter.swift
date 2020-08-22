//  File name   : ConfirmDetailRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ConfirmDetailInteractable: Interactable {
    var router: ConfirmDetailRouting? { get set }
    var listener: ConfirmDetailListener? { get set }
}

protocol ConfirmDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ConfirmDetailRouter: ViewableRouter<ConfirmDetailInteractable, ConfirmDetailViewControllable>, ConfirmDetailRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: ConfirmDetailInteractable, viewController: ConfirmDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
