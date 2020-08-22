//  File name   : TicketMainFillInformationRouter.swift
//
//  Author      : khoi tran
//  Created date: 5/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol TicketMainFillInformationInteractable: Interactable, TicketFillInformationListener, BuyTicketPaymenListener {
    var router: TicketMainFillInformationRouting? { get set }
    var listener: TicketMainFillInformationListener? { get set }
    
    var eventsForm: [Observable<Bool>] { get set }
    func addChildPageController(_ childVC: UIViewController)
}

protocol TicketMainFillInformationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
    func validateBtnNext(isValidate: Bool)
}

final class TicketMainFillInformationRouter: ViewableRouter<TicketMainFillInformationInteractable, TicketMainFillInformationViewControllable> {
    /// Class's constructor.
    init(interactor: TicketMainFillInformationInteractable, viewController: TicketMainFillInformationViewControllable, ticketFillInformationBuildable: TicketFillInformationBuildable, buyTicketPaymentBuildable: BuyTicketPaymentBuildable) {
        self.ticketFillInformationBuildable = ticketFillInformationBuildable
        self.buyTicketPaymentBuildable = buyTicketPaymentBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        self.setupRX()
    }
    
    /// Class's private properties.
  
    private let ticketFillInformationBuildable: TicketFillInformationBuildable
    private let buyTicketPaymentBuildable: BuyTicketPaymentBuildable
    private weak var startTripRouting: ViewableRouting?
    private weak var returnTripRouting: ViewableRouting?
    private let disposeBag = DisposeBag()
}

// MARK: TicketMainFillInformationRouting's members
extension TicketMainFillInformationRouter: TicketMainFillInformationRouting {
    
    func attachFillInformation(isRoundTrip: Bool, type: TicketRoundTripType, busStationParam: ChooseBusStationParam?) {
        if type == .startTicket {
            self.performStartTripRouting(busStationParam: busStationParam)
        }
        
        if (type == .returnTicket) {
            self.performRetunTripRouting(busStationParam: busStationParam)
        }
    }
    
    func initChildScreens(isRoundTrip: Bool, startTripBusStationParam: ChooseBusStationParam?, returnTripBusStationParam: ChooseBusStationParam?) {
        
        let transition = TransitonType.custom(customVC: { [unowned self](controller) in
            self.interactor.addChildPageController(controller)
        }) { (_) in }
        
        let startRouter = ticketFillInformationBuildable.build(withListener: interactor, viewType: .ticketRoute, streamType: .buyNewticket, busStationParam: startTripBusStationParam, ticketRoundTripType: .startTicket)
        
        let segue = RibsRouting(use: startRouter,
                                transitionType: transition,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
        startTripRouting = startRouter
        
        if isRoundTrip {
            let returnRouter = ticketFillInformationBuildable.build(withListener: interactor, viewType: .ticketRoute, streamType: .buyNewticket, busStationParam: returnTripBusStationParam, ticketRoundTripType: .returnTicket)
            returnTripRouting = returnRouter
            let segue = RibsRouting(use: returnRouter,
                                    transitionType: transition,
                                    needRemoveCurrent: false)
            perform(with: segue, completion: nil)
        }
        self.initListener(isRoundTrip: isRoundTrip)
    }
    
    func performStartTripRouting(busStationParam: ChooseBusStationParam?) {
    }
    
    
    func performRetunTripRouting(busStationParam: ChooseBusStationParam?) {
    }
    
    func routeToPayment(streamType: BuslineStreamType) {
        let router = buyTicketPaymentBuildable.build(withListener: interactor, streamType: streamType)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func setupRX() {
        
        
    }
    
    private func initListener(isRoundTrip: Bool) {
        guard let startVC = self.startTripRouting?.viewControllable.uiviewController as? TicketFillInformationVC else { return }
        if !isRoundTrip {
            interactor.eventsForm.append(startVC.$isFormValidated.asObservable())
            startVC.$isFormValidated.bind(onNext: {[weak self] (isValidate) in
                self?.viewController.validateBtnNext(isValidate: isValidate)
            }).disposed(by: disposeBag)
        } else {
            guard let returnVC = self.returnTripRouting?.viewControllable.uiviewController as? TicketFillInformationVC else { return }
            interactor.eventsForm.append(startVC.$isFormValidated.asObservable())
            interactor.eventsForm.append(returnVC.$isFormValidated.asObservable())
            
            Observable.combineLatest(startVC.$isFormValidated, returnVC.$isFormValidated).bind {[weak self] (v1, v2) in
                self?.viewController.validateBtnNext(isValidate: v1 || v2)
            }.disposed(by: disposeBag)
        }
    }
}

// MARK: Class's private methods
private extension TicketMainFillInformationRouter {
}
