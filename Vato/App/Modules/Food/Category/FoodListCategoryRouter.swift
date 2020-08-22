//  File name   : FoodListCategoryRouter.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol FoodListCategoryInteractable: Interactable, FoodListCategoryListener, FoodListListener {
    var router: FoodListCategoryRouting? { get set }
    var listener: FoodListCategoryListener? { get set }
}

protocol FoodListCategoryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FoodListCategoryRouter: ViewableRouter<FoodListCategoryInteractable, FoodListCategoryViewControllable> {
    /// Class's constructor.
    init(interactor: FoodListCategoryInteractable, viewController: FoodListCategoryViewControllable, foodListCategoryBuildable: FoodListCategoryBuildable, foodListBuildable: FoodListBuildable) {
        self.foodListCategoryBuildable = foodListCategoryBuildable
        self.foodListBuildable = foodListBuildable
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

// MARK: FoodListCategoryRouting's members
extension FoodListCategoryRouter: FoodListCategoryRouting {
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
private extension FoodListCategoryRouter {
}
