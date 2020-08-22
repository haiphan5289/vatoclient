//  File name   : TipRouter.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TipInteractable: Interactable {
    var router: TipRouting? { get set }
    var listener: TipListener? { get set }
}

protocol TipViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TipRouter: ViewableRouter<TipInteractable, TipViewControllable>, TipRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: TipInteractable, viewController: TipViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
