//  File name   : OrderContractRouter.swift
//
//  Author      : Phan Hai
//  Created date: 18/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol OrderContractInteractable: Interactable, ChatOrderContractListener {
    var router: OrderContractRouting? { get set }
    var listener: OrderContractListener? { get set }
}

protocol OrderContractViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class OrderContractRouter: ViewableRouter<OrderContractInteractable, OrderContractViewControllable> {
    /// Class's constructor.
    init(interactor: OrderContractInteractable,
         viewController: OrderContractViewControllable,
         chatOCBuildable: ChatOrderContractBuildable) {
        self.chatOCBuildable = chatOCBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    private let chatOCBuildable: ChatOrderContractBuildable
    /// Class's private properties.
}

// MARK: OrderContractRouting's members
extension OrderContractRouter: OrderContractRouting {
    func routeToChatOC() {
        let router = chatOCBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension OrderContractRouter {
}
