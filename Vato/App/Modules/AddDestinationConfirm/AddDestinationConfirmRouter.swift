//  File name   : AddDestinationConfirmRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
protocol AddDestinationConfirmInteractable: Interactable, ChangeDestinationConfirmListener {
    var router: AddDestinationConfirmRouting? { get set }
    var listener: AddDestinationConfirmListener? { get set }
}

protocol AddDestinationConfirmViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class AddDestinationConfirmRouter: ViewableRouter<AddDestinationConfirmInteractable, AddDestinationConfirmViewControllable> {
    /// Class's constructor.
    init(interactor: AddDestinationConfirmInteractable, viewController: AddDestinationConfirmViewControllable, changeDestinationConfirmBuildable: ChangeDestinationConfirmBuildable) {
        self.changeDestinationConfirmBuildable = changeDestinationConfirmBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let changeDestinationConfirmBuildable: ChangeDestinationConfirmBuildable
}

// MARK: AddDestinationConfirmRouting's members
extension AddDestinationConfirmRouter: AddDestinationConfirmRouting {
    func routeToWaiting(request: InTripRequestChangeDestination, tripId: String) {
        let route = changeDestinationConfirmBuildable.build(withListener: interactor, request: request, tripId: tripId)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToAlert(type: ChangeDestinationUpdateType) -> Observable<AddDestinationAlertType> {
        return AddDestinationAlertViewController.show(on: self.viewControllable.uiviewController, message: type.message)
    }
}

// MARK: Class's private methods
private extension AddDestinationConfirmRouter {
}
