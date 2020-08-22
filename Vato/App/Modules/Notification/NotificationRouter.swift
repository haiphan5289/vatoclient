//  File name   : NotificationRouter.swift
//
//  Author      : khoi tran
//  Created date: 1/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol NotificationInteractable: Interactable {
    var router: NotificationRouting? { get set }
    var listener: NotificationListener? { get set }
}

protocol NotificationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class NotificationRouter: ViewableRouter<NotificationInteractable, NotificationViewControllable> {
    /// Class's constructor.
    override init(interactor: NotificationInteractable, viewController: NotificationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: NotificationRouting's members
extension NotificationRouter: NotificationRouting {
    
}

// MARK: Class's private methods
private extension NotificationRouter {
}
