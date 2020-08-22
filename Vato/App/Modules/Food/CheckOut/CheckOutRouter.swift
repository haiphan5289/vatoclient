//  File name   : CheckOutRouter.swift
//
//  Author      : khoi tran
//  Created date: 12/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCore

protocol CheckOutInteractable: Interactable, LocationPickerListener, NoteDeliveryListener, SwitchPaymentListener, StoreTrackingListener, StoreDetailPriceListener, ProductMenuListener, TopUpByThirdPartyListener, EcomPromotionListener, WalletListener {
    var router: CheckOutRouting? { get set }
    var listener: CheckOutListener? { get set }
    
    func selectTime(model: DateTime?)
    var interval: TimeInterval { get }
    func requestZaloPayToken() -> Observable<String>
}

protocol CheckOutViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CheckOutRouter: ViewableRouter<CheckOutInteractable, CheckOutViewControllable> {
    /// Class's constructor.
    init(interactor: CheckOutInteractable,
         viewController: CheckOutViewControllable,
         locationPickerBuildable: LocationPickerBuildable,
         noteDeliveryBuildable: NoteDeliveryBuildable,
         switchPaymentBuildable: SwitchPaymentBuildable,
         storeTrackingBuildable: StoreTrackingBuildable,
         storeDetailPriceBuildable: StoreDetailPriceBuildable,
         productMenuBuildable: ProductMenuBuildable,
         topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable,
         ecomPromotionBuildable: EcomPromotionBuildable,
         walletBuildable: WalletBuildable) {
        self.topUpByThirdPartyBuildable = topUpByThirdPartyBuildable
        self.switchPaymentBuildable = switchPaymentBuildable
        self.noteDeliveryBuildable = noteDeliveryBuildable
        self.locationPickerBuildable = locationPickerBuildable
        self.storeTrackingBuildable = storeTrackingBuildable
        self.storeDetailPriceBuildable = storeDetailPriceBuildable
        self.productMenuBuildable = productMenuBuildable
        self.ecomPromotionBuildable = ecomPromotionBuildable
        self.walletBuildable = walletBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let locationPickerBuildable: LocationPickerBuildable
    private let noteDeliveryBuildable: NoteDeliveryBuildable
    private let switchPaymentBuildable: SwitchPaymentBuildable
    private let storeTrackingBuildable: StoreTrackingBuildable
    private let storeDetailPriceBuildable: StoreDetailPriceBuildable
    private let productMenuBuildable: ProductMenuBuildable
    private let topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable
    private let ecomPromotionBuildable: EcomPromotionBuildable
    private let walletBuildable: WalletBuildable
}

// MARK: CheckOutRouting's members
extension CheckOutRouter: CheckOutRouting {
    func routeToPromotionStore(storeID: Int) {
        let router = ecomPromotionBuildable.build(withListener: interactor, storeID: storeID)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToTopup() {
        let router = topUpByThirdPartyBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToLocationPicker(placeModel: AddressProtocol?, searchType: SearchType, typeLocationPicker: LocationPickerDisplayType) {
        let route = locationPickerBuildable.build(withListener: interactor, placeModel: placeModel, searchType: searchType, typeLocationPicker: typeLocationPicker)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToChooseTime(model: DateTime?) {
        let vc = UIStoryboard(name: "PickerTime", bundle: nil).instantiateViewController(withIdentifier: "PickerTimeViewController") as! PickerTimeViewController
        vc.listener = self
        vc.defaultModel = model
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        
        vc.interval = self.interactor.interval
        self.viewController.uiviewController.present(vc, animated: true, completion: nil)
    }
    
    func routeToNote(note: NoteDeliveryModel?, noteTextConfig: NoteTextConfig) {
        let router = noteDeliveryBuildable.build(withListener: interactor,
                                                 noteDelivery: note,
                                                 noteTextConfig: noteTextConfig)
        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToPaymentMethod() {
        let router = switchPaymentBuildable.build(withListener: interactor, switchPaymentType: .food)
        let segue = RibsRouting(use: router,
                                transitionType: .presentNavigation,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToStoreTracking(order: SalesOrder) {
        let route = storeTrackingBuildable.build(withListener: interactor, order: order, id: order.id)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToDetailPrice() {
        let router = storeDetailPriceBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToProductMenu(product: DisplayProduct, basketItem: BasketStoreValueProtocol?) {
        let route = productMenuBuildable.build(withListener: interactor, product: product, basketItem: basketItem, minValue: 0)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToAddCard() {
        let route = walletBuildable.build(withListener: interactor, source: .booking)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension CheckOutRouter {
}

extension CheckOutRouter: PickerTimeViewControllerListener {
    func selectTime(model: DateTime?) {
        self.interactor.selectTime(model: model)
    }
}
