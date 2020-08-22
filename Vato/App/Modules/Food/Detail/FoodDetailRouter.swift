//  File name   : FoodDetailRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol FoodDetailInteractable: Interactable, FoodMapListener, ProductMenuListener, CheckOutListener {
    var router: FoodDetailRouting? { get set }
    var listener: FoodDetailListener? { get set }
}

protocol FoodDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FoodDetailRouter: ViewableRouter<FoodDetailInteractable, FoodDetailViewControllable> {
    /// Class's constructor.
    init(interactor: FoodDetailInteractable, viewController: FoodDetailViewControllable, foodMapBuildable: FoodMapBuildable, productMenuBuildable: ProductMenuBuildable, checkOutBuildable: CheckOutBuildable) {
        self.foodMapBuildable = foodMapBuildable
        self.productMenuBuildable = productMenuBuildable
        self.checkOutBuildable = checkOutBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let foodMapBuildable: FoodMapBuildable
    private let productMenuBuildable: ProductMenuBuildable
    
    private let checkOutBuildable: CheckOutBuildable

}


// MARK: FoodDetailRouting's members
extension FoodDetailRouter: FoodDetailRouting {
    func routeToMap(item: FoodExploreItem) {
        let route = foodMapBuildable.build(withListener: interactor,item: item)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToProductMenu(product: DisplayProduct, basketItem: BasketStoreValueProtocol?) {
        let route = productMenuBuildable.build(withListener: interactor, product: product, basketItem: basketItem, minValue: 0)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToCheckOut(item: FoodExploreItem) {
        let route = checkOutBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension FoodDetailRouter {
}

