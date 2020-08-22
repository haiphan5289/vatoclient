//  File name   : BlockDriverDetailRouter.swift
//
//  Author      : admin
//  Created date: 6/25/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BlockDriverDetailInteractable: Interactable {
    var router: BlockDriverDetailRouting? { get set }
    var listener: BlockDriverDetailListener? { get set }
}

protocol BlockDriverDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BlockDriverDetailRouter: ViewableRouter<BlockDriverDetailInteractable, BlockDriverDetailViewControllable> {
    /// Class's constructor.
    override init(interactor: BlockDriverDetailInteractable, viewController: BlockDriverDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: BlockDriverDetailRouting's members
extension BlockDriverDetailRouter: BlockDriverDetailRouting {
    
}

// MARK: Class's private methods
private extension BlockDriverDetailRouter {
}
