//  File name   : TopUpByThirdPartyRouter.swift
//
//  Author      : khoi tran
//  Created date: 2/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TopUpByThirdPartyInteractable: Interactable {
    var router: TopUpByThirdPartyRouting? { get set }
    var listener: TopUpByThirdPartyListener? { get set }
}

protocol TopUpByThirdPartyViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TopUpByThirdPartyRouter: ViewableRouter<TopUpByThirdPartyInteractable, TopUpByThirdPartyViewControllable> {
    /// Class's constructor.
    override init(interactor: TopUpByThirdPartyInteractable, viewController: TopUpByThirdPartyViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: TopUpByThirdPartyRouting's members
extension TopUpByThirdPartyRouter: TopUpByThirdPartyRouting {
    
}

// MARK: Class's private methods
private extension TopUpByThirdPartyRouter {
}
