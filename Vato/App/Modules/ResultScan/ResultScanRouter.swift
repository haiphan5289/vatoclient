//  File name   : ResultScanRouter.swift
//
//  Author      : vato.
//  Created date: 9/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ResultScanInteractable: Interactable {
    var router: ResultScanRouting? { get set }
    var listener: ResultScanListener? { get set }
}

protocol ResultScanViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ResultScanRouter: ViewableRouter<ResultScanInteractable, ResultScanViewControllable> {
    /// Class's constructor.
    override init(interactor: ResultScanInteractable, viewController: ResultScanViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ResultScanRouting's members
extension ResultScanRouter: ResultScanRouting {
    
}

// MARK: Class's private methods
private extension ResultScanRouter {
}
