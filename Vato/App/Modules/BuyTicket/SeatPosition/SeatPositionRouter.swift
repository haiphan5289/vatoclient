//  File name   : SeatPositionRouter.swift
//
//  Author      : vato.
//  Created date: 10/8/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol SeatPositionInteractable: Interactable, ConfirmBuyTicketListener, BuyTicketPaymenListener {
    var router: SeatPositionRouting? { get set }
    var listener: SeatPositionListener? { get set }
}

protocol SeatPositionViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SeatPositionRouter: ViewableRouter<SeatPositionInteractable, SeatPositionViewControllable> {
    /// Class's constructor.
    init(interactor: SeatPositionInteractable,
         viewController: SeatPositionViewControllable,
         confirmBuyTicketBuildable: ConfirmBuyTicketBuildable,
         buyTicketPaymentBuildable: BuyTicketPaymentBuildable) {
        self.confirmBuyTicketBuildable = confirmBuyTicketBuildable
        self.buyTicketPaymentBuildable = buyTicketPaymentBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private var confirmBuyTicketBuildable: ConfirmBuyTicketBuildable
    private var buyTicketPaymentBuildable: BuyTicketPaymentBuildable
}

// MARK: SeatPositionRouting's members
extension SeatPositionRouter: SeatPositionRouting {
    func routeToConfirmScreen() {
        let router = confirmBuyTicketBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToPayment(streamType: BuslineStreamType) {
        let router = buyTicketPaymentBuildable.build(withListener: interactor, streamType: streamType)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension SeatPositionRouter {
}
