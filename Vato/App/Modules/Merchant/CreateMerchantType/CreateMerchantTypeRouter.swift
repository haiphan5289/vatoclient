//  File name   : CreateMerchantTypeRouter.swift
//
//  Author      : khoi tran
//  Created date: 10/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol CreateMerchantTypeInteractable: Interactable, CreateMerchantDetailListener {
    var router: CreateMerchantTypeRouting? { get set }
    var listener: CreateMerchantTypeListener? { get set }
}

protocol CreateMerchantTypeViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CreateMerchantTypeRouter: ViewableRouter<CreateMerchantTypeInteractable, CreateMerchantTypeViewControllable> {
    /// Class's constructor.
    init(interactor: CreateMerchantTypeInteractable, viewController: CreateMerchantTypeViewControllable, createMerchantDetailBuildable: CreateMerchantDetailBuildable) {
        self.createMerchantDetailBuildable = createMerchantDetailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let createMerchantDetailBuildable: CreateMerchantDetailBuildable

}

// MARK: CreateMerchantTypeRouting's members
extension CreateMerchantTypeRouter: CreateMerchantTypeRouting {
    func routeToCreateMerchantDetail(category: MerchantCategory) {
        let route = createMerchantDetailBuildable.build(withListener: interactor, category: category)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    
}

// MARK: Class's private methods
private extension CreateMerchantTypeRouter {
}
