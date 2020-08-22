//  File name   : MainDeliveryRouter.swift
//
//  Author      : Dung Vu
//  Created date: 8/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import VatoNetwork
import RxSwift
import RxCocoa
import FwiCoreRX

protocol MainDeliveryInteractable: NoteDeliveryListener, BookingConfirmListenerProtocol, FillInformationListener, LocationPickerListener, PinAddressListener, InTripListener, WalletListener {
    var router: MainDeliveryRouting? { get set }
    var listener: MainDeliveryListener? { get set }
    
    var currentMethod: PaymentMethod { get }
    var eMethod: Observable<PaymentCardDetail> { get }
    var eLoadingObser: Observable<(Bool, Double)> { get }
    var profileStream: ProfileStream { get }
    var errorStream: ErrorBookingStream { get }
    var eApplyPromotion: Observable<Void> { get }
    
    func move(to type: BookingConfirmType)
    func update(payment method: PaymentCardDetail)
    func cancelPromotion()
    func detachMe()
    func forceUseCash()
    func requestBookCancel(revert need: Bool)
    func tripCompleted()
    func routeToNote()
}

protocol MainDeliveryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
    func addBooking(view: MainDeliveryBookingView)
}

final class MainDeliveryRouter: BookingConfirmRouteBase<MainDeliveryInteractor, MainDeliveryVC>, LoadingAnimateProtocol, DisposableProtocol {
    /// Class's constructor.
    struct Config {
        struct NapasError {
            static let overMax = Text.payOverLimitNapas.localizedText
            static let onTouch = "Chuyến đi một chạm không hỗ trợ phương thức thanh toán qua Visa/MasterCard. Vui lòng chọn hình thức thanh toán khác"
        }
        
        struct Button {
            static let napas = Text.changePaymentMethod.localizedText
        }
    }

    init(interactor: MainDeliveryInteractor,
         controller: MainDeliveryVC,
         tipBuilder: TipBuildable,
         changeMethod: ConfirmBookingChangeMethodBuilder,
         promotionBuilder: BookingConfirmPromotionBuildable,
         promotionListBuilder: PromotionBuilder,
         promotionDetailBuilder: PromotionDetailBuildable,
         bookingRequestBuilder: BookingRequestBuildable,
         switchPaymentBuilder: SwitchPaymentBuildable,
         confirmDetailBuildable: ConfirmDetailBuildable,
         noteDeliveryBuildable: NoteDeliveryBuildable,
         fillInformationBuildable: FillInformationBuildable,
         searchDeliveryBuildable: LocationPickerBuildable,
         confirmBookingServiceMoreBuildable: ConfirmBookingServiceMoreBuildable,
         pinAddressBuilable: PinAddressBuildable,
         inTripBuildable: InTripBuildable,
         walletBuildable: WalletBuildable) {
        self.inTripBuildable = inTripBuildable
        self.pinAddressBuilable = pinAddressBuilable
        self.locationPickerBuildable = searchDeliveryBuildable
        self.noteDeliveryBuildable = noteDeliveryBuildable
        self.fillInformationBuildable = fillInformationBuildable
        self.walletBuildable = walletBuildable
        super.init(interactor: interactor,
                   controller: controller,
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
    
    override func routeToNote() {
        self.interactor.routeToNote()
    }
    
    override func updateDiscount() {
        bookingConfirmView.updatePromotionInfor()
    }
    
    override func valid(promotion model: PromotionModel?) -> Observable<PromotionCheckType> {
        guard let model = model, !model.canApply else {
            return Observable.just(.next)
        }
        return self.warningPromotion()
    }
    
    override func moveToIntrip(by tripId: String) {
        self.loadTrip(by: tripId)
    }
    
    override func update(from type: BookingConfirmUpdateType) {
        Observable.just(type).do(onDispose: { [weak self] in
            guard let last = self?.children.last, !(last is WalletRouter) else { return }
            self?.dismissCurrentRoute(completion: nil)
        }).subscribe(onNext: { [weak self] update in
            self?.bookingConfirmView.eUpdate.onNext(update)
        }).disposeOnDeactivate(interactor: interactor)
    }
    
    /// Class's private properties.
    private var booking: Booking?
    var disposeBag: DisposeBag = DisposeBag()
    private (set) lazy var handlerIntrip: BookingConfirmHandlerIntrip = BookingConfirmHandlerIntrip()
    private let noteDeliveryBuildable: NoteDeliveryBuildable
    private let fillInformationBuildable: FillInformationBuildable
    private (set) lazy var bookingConfirmView: MainDeliveryBookingView = MainDeliveryBookingView.loadXib(type: .URBAN_DELIVERY)
    private let locationPickerBuildable: LocationPickerBuildable
    private let pinAddressBuilable: PinAddressBuildable
    private let inTripBuildable: InTripBuildable
    private let walletBuildable: WalletBuildable
//    private let confirmBookingServiceMoreBuildable: ConfirmBookingServiceMoreBuildable
}

// MARK: MainDeliveryRouting's members
extension MainDeliveryRouter: MainDeliveryRouting {
    func detactCurrentChild() {
        self.dismissCurrentRoute(completion: nil)
    }
    
    func routeToInputInformation(_ type: DeliveryInputInformation, serviceType: DeliveryServiceType) {
        let router = fillInformationBuildable.build(withListener: interactor, value: type, serviceType: serviceType)
        
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeNoteDelivery(note: NoteDeliveryModel?) {
        let router = noteDeliveryBuildable.build(withListener: interactor, noteDelivery: note, noteTextConfig: nil)
        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func presentAlert(message: String) {
        let actionCancel = AlertAction(style: .default, title: Text.retry.localizedText, handler: {})
        AlertVC.show(on: viewController.uiviewController, title: "Vato", message: message, from: [actionCancel], orderType: .horizontal)
    }
    
    func presentMessage(message: String) {
        let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText, handler: {})
        AlertVC.show(on: self.viewControllable.uiviewController, title: Text.notification.localizedText, message: message, from: [actionOK], orderType: .horizontal)
    }
    
    func showAlertIntrip(tripId: String) {
        let actionOK = AlertAction.init(style: .default, title: Text.ok.localizedText) { [weak self] in
            self?.moveToIntrip(by: tripId)
        }
        
        AlertVC.show(on: self.viewControllable.uiviewController, title: Text.notification.localizedText, message: Text.messageHaveTrip.localizedText, from: [actionOK], orderType: .horizontal)
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
    
    func routeToDeliverySuccess() {
        guard let vc = UIStoryboard(name: "DeliverySuccess", bundle: nil).instantiateViewController(withIdentifier: DeliverySuccessVC.identifier) as? DeliverySuccessVC else { fatalError("Please Implement") }
        
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.viewController.uiviewController.present(vc, animated: true, completion: nil)
    }
    
    func routeToIntrip(tripId: String) {
        let route = inTripBuildable.build(withListener: interactor, tripId: tripId)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToAddCard() {
        let route = walletBuildable.build(withListener: interactor, source: .booking)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension MainDeliveryRouter {
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
    
    func showAlert(from error: Error) {
        guard let promotionError = error as? PromotionError else {
            let alertOK = AlertAction(style: .default, title: "OK", handler: {})
            AlertVC.show(on: self.viewController.uiviewController, title: "Lỗi", message: error.localizedDescription, from: [alertOK], orderType: .vertical)
            return
        }
        bookingConfirmView.showAlertPromotion(with: .fail(e: promotionError))
    }
    
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
    }
}
