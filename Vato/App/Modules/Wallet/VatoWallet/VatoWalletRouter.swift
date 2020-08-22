//  File name   : VatoWalletRouter.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol VatoWalletInteractable: Interactable {
    var router: VatoWalletRouting? { get set }
    var listener: VatoWalletListener? { get set }
}

protocol VatoWalletViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class VatoWalletRouter: ViewableRouter<VatoWalletInteractable, VatoWalletViewControllable>, VatoWalletRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: VatoWalletInteractable, viewController: VatoWalletViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
