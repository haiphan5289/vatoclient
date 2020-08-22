//  File name   : StoreParentListRouter.swift
//
//  Author      : Dung Vu
//  Created date: 11/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol StoreParentListInteractable: Interactable, FoodListCategoryListener, FoodListListener {
    var router: StoreParentListRouting? { get set }
    var listener: StoreParentListListener? { get set }
}

protocol StoreParentListViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class StoreParentListRouter: ViewableRouter<StoreParentListInteractable, StoreParentListViewControllable> {
    /// Class's constructor.
    init(interactor: StoreParentListInteractable, viewController: StoreParentListViewControllable, foodListCategoryBuildable: FoodListCategoryBuildable, foodListBuildable: FoodListBuildable) {
        self.foodListBuildable = foodListBuildable
        self.foodListCategoryBuildable = foodListCategoryBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let foodListCategoryBuildable: FoodListCategoryBuildable
    private let foodListBuildable: FoodListBuildable
}

// MARK: StoreParentListRouting's members
extension StoreParentListRouter: StoreParentListRouting {
    func routeToListCategory(detail: CategoryRequestProtocol) {
        let route = foodListCategoryBuildable.build(withListener: interactor, current: detail)
        let segue = RibsRouting(use: route, transitionType: .push, needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToList(type: FoodListType) {
        let route = foodListBuildable.build(withListener: interactor, type: type)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension StoreParentListRouter {
}
