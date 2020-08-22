//  File name   : ChangeDestinationConfirmRouter.swift
//
//  Author      : Dung Vu
//  Created date: 4/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ChangeDestinationConfirmInteractable: Interactable {
    var router: ChangeDestinationConfirmRouting? { get set }
    var listener: ChangeDestinationConfirmListener? { get set }
}

protocol ChangeDestinationConfirmViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ChangeDestinationConfirmRouter: ViewableRouter<ChangeDestinationConfirmInteractable, ChangeDestinationConfirmViewControllable> {
    /// Class's constructor.
    override init(interactor: ChangeDestinationConfirmInteractable, viewController: ChangeDestinationConfirmViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ChangeDestinationConfirmRouting's members
extension ChangeDestinationConfirmRouter: ChangeDestinationConfirmRouting {
    
}

// MARK: Class's private methods
private extension ChangeDestinationConfirmRouter {
}
