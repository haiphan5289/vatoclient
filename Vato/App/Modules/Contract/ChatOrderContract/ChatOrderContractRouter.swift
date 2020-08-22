//  File name   : ChatOrderContractRouter.swift
//
//  Author      : Phan Hai
//  Created date: 21/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ChatOrderContractInteractable: Interactable {
    var router: ChatOrderContractRouting? { get set }
    var listener: ChatOrderContractListener? { get set }
}

protocol ChatOrderContractViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ChatOrderContractRouter: ViewableRouter<ChatOrderContractInteractable, ChatOrderContractViewControllable> {
    /// Class's constructor.
    override init(interactor: ChatOrderContractInteractable, viewController: ChatOrderContractViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ChatOrderContractRouting's members
extension ChatOrderContractRouter: ChatOrderContractRouting {
    
}

// MARK: Class's private methods
private extension ChatOrderContractRouter {
}
