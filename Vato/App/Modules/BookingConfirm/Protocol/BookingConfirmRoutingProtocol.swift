//  File name   : BookingConfirmRoutingProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 8/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol BookingConfirmRoutingProtocol {
    // MARK: - Move to acess
    func routeToNote()
    func routeToWallet(vatoServiceType: VatoServiceType)
//    func routeToTip()
    func routeToServiceMore(listService: [AdditionalServices], listCurrentSelectedService: [AdditionalServices])
    func routeToChooseMethod()
    func routeToTopupWallet()
    func routeToPromotion(coordinate: CLLocationCoordinate2D?)
    func routeToBookingRequest()
    func routeToSwitchMethod(vatoServiceType: VatoServiceType)
    func routeToDetailPrice()
    func updateDiscount()
    func update(from type: BookingConfirmUpdateType)
    func routeToDetailPromotion(with code: String, maifest: PromotionList.Manifest?)
    func moveToIntrip(by tripId: String)
    func checkPaymentError(from e: Error)
    func valid(promotion model: PromotionModel?) -> Observable<PromotionCheckType>
}

protocol BookingConfirmBuilderDependency {
    var tipBuilder: TipBuildable { get }
    var changeMethod: ConfirmBookingChangeMethodBuilder { get }
    var promotionBuilder: BookingConfirmPromotionBuildable { get }
    var promotionListBuilder: PromotionBuilder { get }
    var promotionDetailBuilder: PromotionDetailBuildable { get }
    var bookingRequestBuilder: BookingRequestBuildable { get }
    var switchPaymentBuilder: SwitchPaymentBuildable { get }
}

protocol BookingConfirmCancelPromotion {
    func cancelPromotion()
}

protocol BookingConfirmForceCashProtocol {
    func cancelPromotion()
    func forceUseCash()
}

typealias BookingConfirmListenerProtocol = TipListener & ConfirmBookingChangeMethodListener & BookingConfirmPromotionListener & PromotionListener & PromotionDetailListener & BookingRequestListener & SwitchPaymentListener & BookingConfirmCancelPromotion & BookingConfirmForceCashProtocol & ConfirmDetailListener & ConfirmBookingServiceMoreListener

class BookingConfirmRouteBase<E, F: ViewControllable>: ViewableRouter<E, F>, BookingConfirmRoutingProtocol, BookingConfirmBuilderDependency where E: BookingConfirmListenerProtocol
{
    private (set)var tipBuilder: TipBuildable
    private (set)var changeMethod: ConfirmBookingChangeMethodBuilder
    private (set)var promotionBuilder: BookingConfirmPromotionBuildable
    private (set)var promotionListBuilder: PromotionBuilder
    private (set)var promotionDetailBuilder: PromotionDetailBuildable
    private (set)var bookingRequestBuilder: BookingRequestBuildable
    private (set)var switchPaymentBuilder: SwitchPaymentBuildable
    private (set)var confirmDetailBuildable: ConfirmDetailBuildable
    private (set)var confirmBookingServiceMoreBuildable: ConfirmBookingServiceMoreBuildable

    init(interactor: E,
         controller: F,
         tipBuilder: TipBuildable,
         changeMethod: ConfirmBookingChangeMethodBuilder,
         promotionBuilder: BookingConfirmPromotionBuildable,
         promotionListBuilder: PromotionBuilder,
         promotionDetailBuilder: PromotionDetailBuildable,
         bookingRequestBuilder: BookingRequestBuildable,
         switchPaymentBuilder: SwitchPaymentBuildable,
         confirmDetailBuildable: ConfirmDetailBuildable,
         confirmBookingServiceMoreBuildable: ConfirmBookingServiceMoreBuildable)
    {
        self.confirmBookingServiceMoreBuildable = confirmBookingServiceMoreBuildable
        self.changeMethod = changeMethod
        self.promotionBuilder = promotionBuilder
        self.promotionListBuilder = promotionListBuilder
        self.promotionDetailBuilder = promotionDetailBuilder
        self.bookingRequestBuilder = bookingRequestBuilder
        self.switchPaymentBuilder = switchPaymentBuilder
        self.tipBuilder = tipBuilder
        self.confirmDetailBuildable = confirmDetailBuildable
        super.init(interactor: interactor, viewController: controller)
    }
    
    // MARK: - Route
    func routeToNote() {
        fatalError("Please Implement")
    }
    
    func valid(promotion model: PromotionModel?) -> Observable<PromotionCheckType> {
        fatalError("Please Implement")
    }
    
    func routeToWallet(vatoServiceType: VatoServiceType) {
        let router = switchPaymentBuilder.build(withListener: interactor, switchPaymentType: .service(service: vatoServiceType))
        route(by: router, transiton: .presentNavigation)
    }
    
    func routeToDetailPrice() {
        let router = confirmDetailBuildable.build(withListener: self.interactor, service: .delivery)
        route(by: router, transiton: .modal(type: .crossDissolve,
                                            presentStyle: .overCurrentContext))
    }
    
    private func route(by router: Routing,
                       transiton: TransitonType = .modal(type: .crossDissolve,
                                                         presentStyle: .currentContext),
                       needRemoveCurrent: Bool = false)
    {
        let segue = RibsRouting(use: router,
                                transitionType: transiton,
                                needRemoveCurrent: needRemoveCurrent)
        perform(with: segue, completion: nil)
    }
    
    func routeToTip() {
        let router = tipBuilder.build(withListener: self.interactor)
        route(by: router, transiton: .modal(type: .crossDissolve,
                                            presentStyle: .overCurrentContext))
    }

    func routeToServiceMore(listService: [AdditionalServices], listCurrentSelectedService: [AdditionalServices]) {
        let router = confirmBookingServiceMoreBuildable.build(withListener: self.interactor, listService: listService, listCurrentSelectedService: listCurrentSelectedService)
        route(by: router, transiton: .modal(type: .crossDissolve,
                                            presentStyle: .overCurrentContext))
    }
    
    func routeToChooseMethod() {
        let router = changeMethod.build(withListener: self.interactor)
        route(by: router, transiton: .modal(type: .crossDissolve,
                                            presentStyle: .overCurrentContext))
    }
    
    func routeToTopupWallet() {
        fatalError("Please Implement")
    }
    
    func routeToPromotion(coordinate: CLLocationCoordinate2D?) {
        let router = promotionListBuilder.build(withListener: self.interactor, type: .booking, coordinate: coordinate)
        route(by: router, transiton: .modal(type: .coverVertical, presentStyle: .fullScreen))
    }
    
    func routeToBookingRequest() {
        let router = bookingRequestBuilder.build(withListener: self.interactor)
        route(by: router)
    }
    
    func routeToSwitchMethod(vatoServiceType: VatoServiceType) {
        let router = switchPaymentBuilder.build(withListener: interactor, switchPaymentType: .service(service: vatoServiceType))
        route(by: router, transiton: .presentNavigation)
    }
    
    func updateDiscount() {
        fatalError("Please Implement")
    }
    
    func update(from type: BookingConfirmUpdateType) {
        fatalError("Please Implement")
    }
    
    func routeToDetailPromotion(with code: String, maifest: PromotionList.Manifest?) {
        let alert = AlertAction.init(style: .default, title: PromotionConfig.detroyPromotion) { [weak self] in
            self?.interactor.cancelPromotion()
        }
        
        let router = promotionDetailBuilder.build(withListener: self.interactor, mode: .recheck(action: alert), manifest: maifest, code: code)
        let transition = TransitonType.modal(type: .coverVertical, presentStyle: .fullScreen)
        route(by: router, transiton: transition)
    }
    
    func moveToIntrip(by tripId: String) {
        fatalError("Please Implement")
    }
    
    func checkPaymentError(from e: Error) {
        guard let e = e as? PaymentError else {
            return
        }
        let message: String
        switch e {
        case .napasExceedAllow(let defaultMoney):
            message = String(format: BookingConfirmRouter.Config.NapasError.overMax, defaultMoney.currency)
        case .napsNotApplyOneTouch:
            message = BookingConfirmRouter.Config.NapasError.onTouch
        default:
            message = ""
        }
        
        let actionOK = AlertAction.init(style: .default, title: BookingConfirmRouter.Config.Button.napas) { [weak self] in
            self?.interactor.forceUseCash()
        }
        AlertVC.show(on: self.viewControllable.uiviewController, title: nil, message: message, from: [actionOK], orderType: .horizontal)
    }
}
