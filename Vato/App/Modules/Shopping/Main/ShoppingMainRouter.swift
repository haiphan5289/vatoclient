//  File name   : ShoppingMainRouter.swift
//
//  Author      : khoi tran
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCoreRX
import FwiCore

protocol ShoppingMainInteractable: Interactable , LocationPickerListener, PinAddressListener, ShoppingFillInformationListener, BookingConfirmListenerProtocol, NoteDeliveryListener, InTripListener {
    var router: ShoppingMainRouting? { get set }
    var listener: ShoppingMainListener? { get set }
    
    var errorStream: ErrorBookingStream { get }
    var eMethod: Observable<PaymentCardDetail> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var profileStream: ProfileStream { get }
    var eApplyPromotion: Observable<Void> { get }
    
    func detachMe()
    func tripCompleted()

}

protocol ShoppingMainViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
    func addBooking(view: MainDeliveryBookingView)
    
}

final class ShoppingMainRouter: BookingConfirmRouteBase<ShoppingMainInteractor, ShoppingMainVC>, LoadingAnimateProtocol, DisposableProtocol {
    /// Class's constructor.
    init(interactor: ShoppingMainInteractor,
         viewController: ShoppingMainVC,
         locationPickerBuildable: LocationPickerBuildable,
         pinAddressBuilable: PinAddressBuildable,
         shoppingFillInformationBuilable: ShoppingFillInformationBuildable,
         tipBuilder: TipBuildable,
         changeMethod: ConfirmBookingChangeMethodBuilder,
         promotionBuilder: BookingConfirmPromotionBuildable,
         promotionListBuilder: PromotionBuilder,
         promotionDetailBuilder: PromotionDetailBuildable,
         bookingRequestBuilder: BookingRequestBuildable,
         switchPaymentBuilder: SwitchPaymentBuildable,
         confirmDetailBuildable: ConfirmDetailBuildable,
         confirmBookingServiceMoreBuildable: ConfirmBookingServiceMoreBuildable,
         noteDeliveryBuildable: NoteDeliveryBuildable,
         inTripBuildable: InTripBuildable) {
        self.inTripBuildable = inTripBuildable
        self.locationPickerBuildable = locationPickerBuildable
        self.pinAddressBuilable = pinAddressBuilable
        self.shoppingFillInformationBuilable = shoppingFillInformationBuilable
        self.noteDeliveryBuildable = noteDeliveryBuildable
        super.init(interactor: interactor,
                   controller: viewController,
                   tipBuilder: tipBuilder,
                   changeMethod: changeMethod,
                   promotionBuilder: promotionBuilder,
                   promotionListBuilder: promotionListBuilder,
                   promotionDetailBuilder: promotionDetailBuilder,
                   bookingRequestBuilder: bookingRequestBuilder,
                   switchPaymentBuilder: switchPaymentBuilder,
                   confirmDetailBuildable: confirmDetailBuildable,
                   confirmBookingServiceMoreBuildable: confirmBookingServiceMoreBuildable)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        setupRX()
        self.viewController.addBooking(view: bookingConfirmView)
        
    }
    
    /// Class's private properties.
    private let locationPickerBuildable: LocationPickerBuildable
    private let pinAddressBuilable: PinAddressBuildable
    private let shoppingFillInformationBuilable: ShoppingFillInformationBuildable
    private let noteDeliveryBuildable: NoteDeliveryBuildable
    private let inTripBuildable: InTripBuildable

    private lazy var bookingConfirmView: MainDeliveryBookingView = MainDeliveryBookingView.loadXib(type: .URBAN_DELIVERY)
    private (set) lazy var handlerIntrip: BookingConfirmHandlerIntrip = BookingConfirmHandlerIntrip()
    
    var disposeBag: DisposeBag = DisposeBag()
        
    override func update(from type: BookingConfirmUpdateType) {
        Observable.just(type).do(onDispose: { [weak self] in
            self?.dismissCurrentRoute(completion: nil)
        }).subscribe(onNext: { [weak self] update in
            self?.bookingConfirmView.eUpdate.onNext(update)
        }).disposeOnDeactivate(interactor: interactor)
    }
    
    override func moveToIntrip(by tripId: String) {
        self.loadTrip(by: tripId)
        let route = inTripBuildable.build(withListener: interactor, tripId: tripId)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    override func valid(promotion model: PromotionModel?) -> Observable<PromotionCheckType> {
        guard let model = model, !model.canApply else {
            return Observable.just(.next)
        }
        return self.warningPromotion()
    }
    
    override func routeToNote() {
        self.interactor.routeToNote()
    }
}

// MARK: ShoppingMainRouting's members
extension ShoppingMainRouter: ShoppingMainRouting {
    func detactCurrentChild() {
        self.dismissCurrentRoute(completion: nil)
    }
    
    func routeToShoppingFillInformation(info: DeliveryInputInformation) {
        let route = shoppingFillInformationBuilable.build(withListener: interactor, old: info)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true )
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
    
    func routeToPinLocation(address: AddressProtocol?, isOrigin: Bool) {
        let route = pinAddressBuilable.build(withListener: interactor, defautPlace: address, isOrigin: isOrigin)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func presentAlert(message: String) {
        let actionCancel = AlertAction(style: .default, title: Text.retry.localizedText, handler: {})
        AlertVC.show(on: viewController.uiviewController, title: "Vato", message: message, from: [actionCancel], orderType: .horizontal)
    }
    
    func showAlertIntrip(tripId: String) {
        let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText) { [weak self] in
            self?.moveToIntrip(by: tripId)
        }
        
        AlertVC.show(on: self.viewControllable.uiviewController, title: Text.notification.localizedText, message: Text.messageHaveTrip.localizedText, from: [actionOK], orderType: .horizontal)
    }
    
    func presentMessage(message: String) {
        let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText, handler: {})
        AlertVC.show(on: self.viewControllable.uiviewController, title: Text.notification.localizedText, message: message, from: [actionOK], orderType: .horizontal)
    }
    
    func showAlert(from error: Error) {
        guard let promotionError = error as? PromotionError else {
            let alertOK = AlertAction(style: .default, title: "OK", handler: {})
            AlertVC.show(on: self.viewController.uiviewController, title: "Lỗi", message: error.localizedDescription, from: [alertOK], orderType: .vertical)
            return
        }
        bookingConfirmView.showAlertPromotion(with: .fail(e: promotionError))
    }
    
    func routeNoteDelivery(note: NoteDeliveryModel?) {
        let router = noteDeliveryBuildable.build(withListener: interactor, noteDelivery: note, noteTextConfig: nil)
        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension ShoppingMainRouter {
    func setupRX() {
        
        self.interactor.errorStream.eError.bind { [weak self] e in
            self?.showAlert(from: e)
        }.disposeOnDeactivate(interactor: interactor)
        
        self.bookingConfirmView.eUserInfor = self.interactor.profileStream.user
        self.bookingConfirmView
            .eAction
            .debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.instance).bind { [weak self] in
                self?.interactor.move(to: $0)
        }.disposeOnDeactivate(interactor: interactor)
        
        self.interactor.eApplyPromotion.bind { [weak self] in
            self?.bookingConfirmView.showAlertPromotion(with: .success)
        }.disposeOnDeactivate(interactor: self.interactor)
        
        self.handlerIntrip.state
            .observeOn(MainScheduler.asyncInstance)
            .bind
            { [weak self](s) in
                guard let wSelf = self else { return }
                switch s {
                case .cancel:
                    wSelf.interactor.requestBookCancel(revert: false)
                case .completed:
                    wSelf.interactor.tripCompleted()
                case .clientCancel:
                    wSelf.interactor.requestBookCancel(revert: false)
                case .newTrip:
                    wSelf.interactor.detachMe()
                case .dismiss:
                    wSelf.interactor.moveBack()
                }
        }.disposeOnDeactivate(interactor: interactor)
        
        self.interactor.eMethod
            .map { BookingConfirmUpdateType.updateMethod(method: $0) }
            .bind(to: self.bookingConfirmView.eUpdate)
            .disposeOnDeactivate(interactor: interactor)
        
        showLoading(use: interactor.eLoadingObser)
        
        
        //        self.domesticBookingView.e
    }
    
    private func warningPromotion() -> Observable<PromotionCheckType> {
        return Observable.create({ [weak self](s) -> Disposable in
            let alertOK = AlertAction.init(style: .default, title: PromotionConfig.titleWarningReviewPromotion) {
                s.onNext(.review)
                s.onCompleted()
            }
            
            let alertCancel = AlertAction.init(style: .cancel, title: PromotionConfig.titleWarningOKPromotion) {
                s.onNext(.next)
                s.onCompleted()
            }
            
            AlertVC.show(on: self?.viewController.uiviewController, title: PromotionConfig.titleWarningPromotion, message: PromotionConfig.titleWarningMessagePromotion, from: [alertOK, alertCancel], orderType: .vertical)
            return Disposables.create()
        })
        
    }
}

