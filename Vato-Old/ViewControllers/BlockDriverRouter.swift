//  File name   : BlockDriverRouter.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BlockDriverInteractable: Interactable, FindDriverListener, BlockDriverDetailListener {
    var router: BlockDriverRouting? { get set }
    var listener: BlockDriverListener? { get set }
}

protocol BlockDriverViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BlockDriverRouter: ViewableRouter<BlockDriverInteractable, BlockDriverViewControllable> {
    /// Class's constructor.
    init(interactor: BlockDriverInteractable, viewController: BlockDriverViewControllable,
         findDriverBuildable: FindDriverBuildable, detailBlockDriverBuildable: BlockDriverDetailBuildable) {
        self.findDriverBuildable = findDriverBuildable
        self.detailBlockDriverBuildable = detailBlockDriverBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let findDriverBuildable: FindDriverBuildable
    private let detailBlockDriverBuildable: BlockDriverDetailBuildable
}

// MARK: BlockDriverRouting's members
extension BlockDriverRouter: BlockDriverRouting {
    func goToFindDriver() {
        let router = findDriverBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router,
                                transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext),
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func goToDetailDriver(driver: BlockDriverInfo) {
        let router = detailBlockDriverBuildable.build(withListener: interactor, driver: driver)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension BlockDriverRouter {
}
