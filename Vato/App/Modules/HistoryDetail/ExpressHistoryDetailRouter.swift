//  File name   : ExpressHistoryDetailRouter.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ExpressHistoryDetailInteractable: Interactable {
    var router: ExpressHistoryDetailRouting? { get set }
    var listener: ExpressHistoryDetailListener? { get set }
}

protocol ExpressHistoryDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ExpressHistoryDetailRouter: ViewableRouter<ExpressHistoryDetailInteractable, ExpressHistoryDetailViewControllable> {
    /// Class's constructor.
    override init(interactor: ExpressHistoryDetailInteractable, viewController: ExpressHistoryDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ExpressHistoryDetailRouting's members
extension ExpressHistoryDetailRouter: ExpressHistoryDetailRouting {
    func routeQRCode() {
        let controller = ExpressQRCodeVC()
        
        let navi = UINavigationController(rootViewController: controller)
        navi.modalTransitionStyle = .coverVertical
        navi.modalPresentationStyle = .fullScreen
        self.viewController.uiviewController.present(navi, animated: true, completion: nil)
    }
}

// MARK: Class's private methods
private extension ExpressHistoryDetailRouter {
}
