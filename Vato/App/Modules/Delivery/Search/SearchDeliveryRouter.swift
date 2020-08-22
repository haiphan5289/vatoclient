//  File name   : SearchDeliveryRouter.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol SearchDeliveryInteractable: Interactable, PinAddressListener {
    var router: SearchDeliveryRouting? { get set }
    var listener: SearchDeliveryListener? { get set }
}

protocol SearchDeliveryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SearchDeliveryRouter: ViewableRouter<SearchDeliveryInteractable, SearchDeliveryViewControllable> {
    /// Class's constructor.
    init(interactor: SearchDeliveryInteractable,
         viewController: SearchDeliveryViewControllable,
         pinAddressBuildable: PinAddressBuildable) {
        self.pinAddressBuildable = pinAddressBuildable
        super.init(interactor: interactor,
                   viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let pinAddressBuildable: PinAddressBuildable
}

// MARK: SearchDeliveryRouting's members
extension SearchDeliveryRouter: SearchDeliveryRouting {
    func moveToPin(defautPlace: AddressProtocol?, isOrigin: Bool) {
        let router = pinAddressBuildable.build(withListener: self.interactor, defautPlace: defautPlace, isOrigin: isOrigin)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension SearchDeliveryRouter {
}
