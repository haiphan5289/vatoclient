//  File name   : StoreTrackingRouter.swift
//
//  Author      : khoi tran
//  Created date: 12/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol StoreTrackingInteractable: Interactable, ChatListener {
    var router: StoreTrackingRouting? { get set }
    var listener: StoreTrackingListener? { get set }
}

protocol StoreTrackingViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class StoreTrackingRouter: ViewableRouter<StoreTrackingInteractable, StoreTrackingViewControllable> {
    /// Class's constructor.
    init(interactor: StoreTrackingInteractable, viewController: StoreTrackingViewControllable, chatBuildable: ChatBuildable) {
        self.chatBuildable = chatBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let chatBuildable: ChatBuildable
}

// MARK: StoreTrackingRouting's members
extension StoreTrackingRouter: StoreTrackingRouting {
    func routeToChat() {
        let route = chatBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext) , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToCancel() {
//        let reasonVC = ReasonCancelVC()
//        reasonVC.didSelectConfirm = { [weak self] result in
//            self?.interactor.inTripCancel(result)
//        }
//        self.viewControllable.uiviewController.present(reasonVC, animated: true, completion: nil)
    }
}

// MARK: Class's private methods
private extension StoreTrackingRouter {
}
