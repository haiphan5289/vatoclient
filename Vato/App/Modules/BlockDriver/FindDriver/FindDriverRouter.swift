//  File name   : FindDriverRouter.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol FindDriverInteractable: Interactable, BlockDriverDetailListener {
    var router: FindDriverRouting? { get set }
    var listener: FindDriverListener? { get set }
}

protocol FindDriverViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FindDriverRouter: ViewableRouter<FindDriverInteractable, FindDriverViewControllable> {
    /// Class's constructor.
//    override init(interactor: FindDriverInteractable, viewController: FindDriverViewControllable) {
//        super.init(interactor: interactor, viewController: viewController)
//        interactor.router = self
//    }
    
    init(interactor: FindDriverInteractable, viewController: FindDriverViewControllable,
         blockDriverDetailBuildable: BlockDriverDetailBuildable) {
        self.blockDriverDetailBuildable = blockDriverDetailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let blockDriverDetailBuildable: BlockDriverDetailBuildable

}

// MARK: FindDriverRouting's members
extension FindDriverRouter: FindDriverRouting {
    func goToBlock(driver: BlockDriverInfo) {
        let router = blockDriverDetailBuildable.build(withListener: interactor, driver: driver)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension FindDriverRouter {
}
