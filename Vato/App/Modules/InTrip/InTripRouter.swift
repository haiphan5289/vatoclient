//  File name   : InTripRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

typealias InTripHandlerProtocol = ChatListener & TOShortcutListener & AddDestinationConfirmListener & LocationPickerListener
protocol InTripInteractable: Interactable, InTripHandlerProtocol {
    var router: InTripRouting? { get set }
    var listener: InTripListener? { get set }
    
    func inTripCancel(_ reason: JSON)
}

protocol InTripViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class InTripRouter: ViewableRouter<InTripInteractable, InTripViewControllable> {
    /// Class's constructor.
    init(interactor: InTripInteractable, viewController: InTripViewControllable, chatBuildable: ChatBuildable, shortcutBuildable: TOShortcutBuildable, addDestinationConfirmBuildable: AddDestinationConfirmBuildable, locationPickerBuildable: LocationPickerBuildable) {
        self.locationPickerBuildable = locationPickerBuildable
        self.addDestinationConfirmBuildable = addDestinationConfirmBuildable
        self.chatBuildable = chatBuildable
        self.shortcutBuildable = shortcutBuildable
        super.init(interactor: interactor, viewController: viewController)        
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let chatBuildable: ChatBuildable
    private let shortcutBuildable: TOShortcutBuildable
    private let locationPickerBuildable: LocationPickerBuildable
    private let addDestinationConfirmBuildable: AddDestinationConfirmBuildable
}

// MARK: InTripRouting's members
extension InTripRouter: InTripRouting {
    func routeToAddDestinationConfirm(type: AddNewDestinationType, tripId: String) {
        let route = addDestinationConfirmBuildable.build(withListener: interactor, type: type, tripId: tripId)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToShortcut() {
        let route = shortcutBuildable.build(withListener: interactor, type: .inTrip)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToChat() {
        let route = chatBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext) , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToCancel() {
        let reasonVC = ReasonCancelVC()
        reasonVC.didSelectConfirm = { [weak self] result in
            self?.interactor.inTripCancel(result)
        }
        self.viewControllable.uiviewController.present(reasonVC, animated: true, completion: nil)
    }
    
    func routeToLocationPicker() {
        let route = locationPickerBuildable.build(withListener: interactor, placeModel: nil, searchType: .booking(origin: false, placeHolder: "Bạn muốn đi đâu?", icon: UIImage(named: "ic_destination"), fillInfo: false), typeLocationPicker: .full)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension InTripRouter {
}
