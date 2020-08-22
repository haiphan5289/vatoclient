//  File name   : CancelTicketRouter.swift
//
//  Author      : vato.
//  Created date: 10/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol CancelTicketInteractable: Interactable {
    var router: CancelTicketRouting? { get set }
    var listener: CancelTicketListener? { get set }
}

protocol CancelTicketViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CancelTicketRouter: ViewableRouter<CancelTicketInteractable, CancelTicketViewControllable> {
    /// Class's constructor.
    override init(interactor: CancelTicketInteractable, viewController: CancelTicketViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: CancelTicketRouting's members
extension CancelTicketRouter: CancelTicketRouting {
    
}

// MARK: Class's private methods
private extension CancelTicketRouter {
}
