//  File name   : PromotionSearchRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol PromotionSearchInteractable: Interactable {
    var router: PromotionSearchRouting? { get set }
    var listener: PromotionSearchListener? { get set }
    var searchStream: PromotionSearchStream { get }
}

protocol PromotionSearchViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
    func attach(searchView: PromotionSearchView)
    
}

final class PromotionSearchRouter: Router<PromotionSearchInteractable>, PromotionSearchRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    init(interactor: PromotionSearchInteractable, viewController: PromotionSearchViewControllable) {
        self.viewController = viewController
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        // todo: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
        searchView.removeFromSuperview()
    }

    override func didLoad() {
        super.didLoad()
        viewController.attach(searchView: searchView)
    }
    
    /// Class's private properties
    private let viewController: PromotionSearchViewControllable
    private lazy var searchView: PromotionSearchView = PromotionSearchView(using: self.interactor.searchStream.listSearch, eSourceUpdateCommand: self.interactor.searchStream.eSearchCommand)
}
