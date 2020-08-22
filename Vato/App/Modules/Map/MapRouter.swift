//  File name   : MapRouter.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol MapInteractable: Interactable, HomeListener, SearchLocationListener, PickLocationListener, BookingConfirmListener, PromotionListener, PromotionDetailListener, MainDeliveryListener, VatoTaxiListener, LocationPickerListener, SetLocationListener, CarContractListener {
    var router: MapRouting? { get set }
    var listener: MapListener? { get set }

    func handlePromotionAction()
    func handleLookupManifestAction(with extra: String)

    func usePromotion(code: String, from manifest: PromotionList.Manifest)
}

protocol MapViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MapRouter: ViewableRouter<MapInteractable, MapViewControllable>, MapRouting {
    
    weak var currentChild: Routing?
    weak var currentRoute: ViewableRouting?

    init(interactor: MapInteractable,
         viewController: MapViewControllable,
         homeBuilder: HomeBuildable,
         searchLocationBuilder: SearchLocationBuildable,
         bookingConfirmBuilder: BookingConfirmBuildable,
         pickLocationBuilder: PickLocationBuildable,
         promotionBuilder: PromotionBuildable,
         promotionDetailBuilder: PromotionDetailBuildable,
         mainDeliveryBuildable: MainDeliveryBuildable,
         vatoTaxiBuildable: VatoTaxiBuildable,
         locationPickerBuildable: LocationPickerBuildable,
         setLocationBuildable: SetLocationBuildable,
//         contractBuildable: BookContractBuildable) {
        contractBuildable: CarContractBuildable) {
        
        self.homeBuilder = homeBuilder
        self.bookingConfirmBuilder = bookingConfirmBuilder
        self.searchLocationBuilder = searchLocationBuilder
        self.pickLocationBuilder = pickLocationBuilder

        self.promotionBuilder = promotionBuilder
        self.promotionDetailBuilder = promotionDetailBuilder
        self.mainDeliveryBuildable = mainDeliveryBuildable
        self.vatoTaxiBuilder = vatoTaxiBuildable
        self.locationPickerBuildable = locationPickerBuildable
        self.setLocationBuildable = setLocationBuildable
        
        self.contractBuildable = contractBuildable
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
    }

    /// Class's private properties
    private let bookingConfirmBuilder: BookingConfirmBuildable
    private let homeBuilder: HomeBuildable
    private let pickLocationBuilder: PickLocationBuildable
    private let searchLocationBuilder: SearchLocationBuildable

    private let promotionBuilder: PromotionBuildable
    private let promotionDetailBuilder: PromotionDetailBuildable
    private let mainDeliveryBuildable: MainDeliveryBuildable
    private let vatoTaxiBuilder: VatoTaxiBuildable
    private let locationPickerBuildable: LocationPickerBuildable
    private let setLocationBuildable: SetLocationBuildable
//    private let contractBuildable: BookContractBuildable
    private let contractBuildable: CarContractBuildable
}

// MARK: Class's public methods
extension MapRouter {
    func routeToHome(service: VatoServiceType) {
        let router = homeBuilder.build(withListener: interactor)
        router.nextService = service
        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToSearchLocation() {
        let router = searchLocationBuilder.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToLocationPicker(type: SearchType, address: AddressProtocol?) {
        let route = locationPickerBuildable.build(withListener: interactor,
                                                  placeModel: address,
                                                  searchType: type,
                                                  typeLocationPicker: .full)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToDelivery() {
        let router = mainDeliveryBuildable.build(withListener: interactor)
        
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }

    func routeToPickLocation() {
        let router = pickLocationBuilder.build(withListener: interactor)

        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }

    func routeToConfirmBooking() {
        let router = bookingConfirmBuilder.build(withListener: interactor)

        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }

    func routeToVatoTaxi() {
        let router = vatoTaxiBuilder.build(withListener: interactor)
        
        let segue = RibsRouting(use: router, transitionType: .childView, needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToPromotion(coordinate: CLLocationCoordinate2D?) {
        let router = promotionBuilder.build(withListener: interactor, type: .home, coordinate: coordinate)

        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .currentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }

    func routeToContract() {
        let router = contractBuildable.build(withListener: interactor)
        
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }

    func routeToPromotionDetail(manifest: PromotionList.Manifest) {
        guard let code = manifest.code else {
            return
        }

        let actionOkay = AlertAction(style: .default, title: Text.quickBooking.localizedText, handler: { [weak self] in
            self?.dismissCurrentRoute(completion: nil)
            self?.interactor.usePromotion(code: code, from: manifest)
        })

        let router = promotionDetailBuilder.build(withListener: interactor, mode: .detail(action: actionOkay), manifest: manifest, code: code)

        let segue = RibsRouting(use: router, transitionType: .modal(type: .coverVertical, presentStyle: .currentContext), needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    func routeToPromotionDetail(predecate: PromotionList.ManifestPredicate, manifest: PromotionList.Manifest) {
        guard let type = ManifestAction(rawValue: predecate.type) else {
            return
        }
        let actions: [AlertAction]

        switch type {
        case .web:
            let actionOkay = AlertAction(style: .default, title: Text.seeMore.localizedText, handler: { [weak self] in
                guard let url = URL(string: predecate.extra), let controller = self?.viewController.uiviewController else {
                    return
                }

                self?.dismissCurrentRoute(completion: nil)
                WebVC.loadWeb(on: controller, url: url, title: "")
            })
            actions = [actionOkay]

        case .manifest:
            let actionCancel = AlertAction(style: .cancel, title: Text.dismiss.localizedText, handler: { [weak self] in
                self?.dismissCurrentRoute(completion: nil)
            })
            let actionOkay = AlertAction(style: .default, title: Text.seeMore.localizedText, handler: { [weak self] in
                self?.interactor.handleLookupManifestAction(with: predecate.extra)
            })
            actions = [actionCancel, actionOkay]
        default:
            return

        }

        let router = promotionDetailBuilder.build(withListener: interactor, mode: .notify(actions: actions), manifest: manifest, code: "")

        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToSetLocation() {
        let route = setLocationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func presentAlert(message: String) {
        let actionCancel = AlertAction(style: .default, title: Text.retry.localizedText, handler: {})
        AlertVC.show(on: viewController.uiviewController, title: "Vato", message: message, from: [actionCancel], orderType: .horizontal)
    }

    func presentAlert(title: String, message: String, cancelAction: String) {
        let actionCancel = AlertAction(style: .default, title: cancelAction, handler: {})
        AlertVC.show(on: viewController.uiviewController, title: title, message: message, from: [actionCancel], orderType: .horizontal)
    }
}

// MARK: Class's private methods
private extension MapRouter {
    private func detachCurrentChild() {
        if let currentChild = currentChild {
            detachChild(currentChild)
        }
    }
}
