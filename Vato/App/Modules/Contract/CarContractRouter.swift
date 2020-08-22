//  File name   : CarContractRouter.swift
//
//  Author      : an.nguyen
//  Created date: 8/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol CarContractInteractable: Interactable, OrderContractListener, LocationPickerListener {
    var router: CarContractRouting? { get set }
    var listener: CarContractListener? { get set }
    
    var interval: TimeInterval { get }
    
    func selectTime(model: DateTime?)
}

protocol CarContractViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CarContractRouter: ViewableRouter<CarContractInteractable, CarContractViewControllable> {
    /// Class's constructor.
    init(interactor: CarContractInteractable,
                  viewController: CarContractViewControllable,
                  ordertContract: OrderContractBuildable,
                  locationBuilder: LocationPickerBuildable) {
        self.ordertContract = ordertContract
        self.locationBuilder = locationBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
        
    /// Class's private properties.
    private let ordertContract: OrderContractBuildable
    private let locationBuilder: LocationPickerBuildable
}

// MARK: CarContractRouting's members
extension CarContractRouter: CarContractRouting {
    func routeToOrder() {
        let router = ordertContract.build(withListener: interactor)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToMap(type: SearchType, address: AddressProtocol?) {
        let route = locationBuilder.build(withListener: interactor,
                                                  placeModel: address,
                                                  searchType: type,
                                                  typeLocationPicker: .full)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
//    func routeToPickTime(model: DateTime?) {
//        let vc = UIStoryboard(name: "PickerTime", bundle: nil).instantiateViewController(withIdentifier: "PickerTimeViewController") as! PickerTimeViewController
//        vc.listener = self
//        vc.defaultModel = model
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .fullScreen
//        vc.isUpdate = true
//        vc.interval = self.interactor.interval
//        self.viewController.uiviewController.present(vc, animated: true, completion: nil)
//    }
    
    func routeToPickTime(model: DateTime?) {
        let vc = PickerDateTimeVC(nibName: PickerDateTimeVC.identifier, bundle: nil)
        vc.defaultModel = model
        vc.listener = self
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.viewController.uiviewController.present(vc, animated: true, completion: nil)
    }

}

// MARK: Class's private methods
private extension CarContractRouter {
}

extension CarContractRouter: PickerTimeViewControllerListener {
    func selectTime(model: DateTime?) {
        self.interactor.selectTime(model: model)
    }
}
