//  File name   : FoodListRouter.swift
//
//  Author      : Dung Vu
//  Created date: 11/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol FoodListInteractable: Interactable, FoodDetailListener, CheckOutListener {
    var router: FoodListRouting? { get set }
    var listener: FoodListListener? { get set }
}

protocol FoodListViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FoodListRouter: ViewableRouter<FoodListInteractable, FoodListViewControllable> {
    /// Class's constructor.
    init(interactor: FoodListInteractable,
         viewController: FoodListViewControllable,
         foodDetailBuildable: FoodDetailBuildable,
         checkOutBuildable: CheckOutBuildable)
    {
        self.foodDetailBuildable = foodDetailBuildable
        self.checkOutBuildable = checkOutBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let foodDetailBuildable: FoodDetailBuildable
    private let checkOutBuildable: CheckOutBuildable
}

// MARK: FoodListRouting's members
extension FoodListRouter: FoodListRouting {
    func routeToDetail(item: FoodExploreItem) {
        let route = foodDetailBuildable.build(withListener: interactor,item: item)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToCheckOut() {
        let route = checkOutBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension FoodListRouter {
}
