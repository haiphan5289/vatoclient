//  File name   : TicketUserInfomationRouter.swift
//
//  Author      : vato.
//  Created date: 10/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketUserInfomationInteractable: Interactable, TicketBusStationListener {
    var router: TicketUserInfomationRouting? { get set }
    var listener: TicketUserInfomationListener? { get set }
}

protocol TicketUserInfomationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketUserInfomationRouter: ViewableRouter<TicketUserInfomationInteractable, TicketUserInfomationViewControllable> {
    /// Class's constructor.
    init(interactor: TicketUserInfomationInteractable,
         viewController: TicketUserInfomationViewControllable,
         ticketBusStationBuildable: TicketBusStationBuildable) {
        self.ticketBusStationBuildable = ticketBusStationBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private var ticketBusStationBuildable: TicketBusStationBuildable
}

// MARK: TicketUserInfomationRouting's members
extension TicketUserInfomationRouter: TicketUserInfomationRouting {
    func routeToBusStation(originLocation: TicketLocation, destLocation: TicketLocation, streamType: BuslineStreamType) {
        let model = ChooseBusStationParam(originCode: originLocation.code, destinationCode: destLocation.code)
        let router = ticketBusStationBuildable.build(withListener: interactor, viewType: .ticketRoute, busParam: model, stopParam: nil, streamType: streamType)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func openTermOfTicket(url: URL, title: String) {
        WebVC.loadWeb(on: self.viewControllable.uiviewController, url: url, title: title)
    }
}

// MARK: Class's private methods
private extension TicketUserInfomationRouter {
}
