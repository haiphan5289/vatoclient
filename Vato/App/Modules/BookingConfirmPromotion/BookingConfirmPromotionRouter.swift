//  File name   : BookingConfirmPromotionRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BookingConfirmPromotionInteractable: Interactable {
    var router: BookingConfirmPromotionRouting? { get set }
    var listener: BookingConfirmPromotionListener? { get set }
}

protocol BookingConfirmPromotionViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BookingConfirmPromotionRouter: ViewableRouter<BookingConfirmPromotionInteractable, BookingConfirmPromotionViewControllable>, BookingConfirmPromotionRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: BookingConfirmPromotionInteractable, viewController: BookingConfirmPromotionViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
