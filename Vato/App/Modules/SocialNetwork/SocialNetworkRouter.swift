//  File name   : SocialNetworkRouter.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol SocialNetworkInteractable: Interactable {
    var router: SocialNetworkRouting? { get set }
    var listener: SocialNetworkListener? { get set }
}

protocol SocialNetworkViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SocialNetworkRouter: ViewableRouter<SocialNetworkInteractable, SocialNetworkViewControllable>, SocialNetworkRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: SocialNetworkInteractable, viewController: SocialNetworkViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
