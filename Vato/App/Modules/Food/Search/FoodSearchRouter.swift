//  File name   : FoodSearchRouter.swift
//
//  Author      : Dung Vu
//  Created date: 11/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol FoodSearchInteractable: Interactable, FoodDetailListener {
    var router: FoodSearchRouting? { get set }
    var listener: FoodSearchListener? { get set }
}

protocol FoodSearchViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FoodSearchRouter: ViewableRouter<FoodSearchInteractable, FoodSearchViewControllable> {
    /// Class's constructor.
    init(interactor: FoodSearchInteractable, viewController: FoodSearchViewControllable, foodDetailBuildable: FoodDetailBuildable) {
        self.foodDetailBuildable = foodDetailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let foodDetailBuildable: FoodDetailBuildable
}

// MARK: FoodSearchRouting's members
extension FoodSearchRouter: FoodSearchRouting {
    func routeToDetail(item: FoodExploreItem) {
        let route = foodDetailBuildable.build(withListener: interactor,item: item)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension FoodSearchRouter {
}
