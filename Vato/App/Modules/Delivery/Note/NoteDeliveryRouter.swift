//  File name   : NoteDeliveryRouter.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol NoteDeliveryInteractable: Interactable {
    var router: NoteDeliveryRouting? { get set }
    var listener: NoteDeliveryListener? { get set }
}

protocol NoteDeliveryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class NoteDeliveryRouter: ViewableRouter<NoteDeliveryInteractable, NoteDeliveryViewControllable> {
    /// Class's constructor.
    override init(interactor: NoteDeliveryInteractable, viewController: NoteDeliveryViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: NoteDeliveryRouting's members
extension NoteDeliveryRouter: NoteDeliveryRouting {
    
}

// MARK: Class's private methods
private extension NoteDeliveryRouter {
}
