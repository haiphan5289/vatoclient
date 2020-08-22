//  File name   : WalletRouter.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

protocol WalletInteractable: Interactable, WalletDetailHistoryListener, WalletListHistoryListener, PaymentMethodManageListener, TopUpByThirdPartyListener {
    var router: WalletRouting? { get set }
    var listener: WalletListener? { get set }
    func processNapasPaymentSuccess(showAlert: Bool)
    func processNapasPaymentFailure(status: Int, message: String)
}

protocol WalletViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class WalletRouter: ViewableRouter<WalletInteractable, WalletViewControllable>, WalletRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    private lazy var disposeBag = DisposeBag()
    init(interactor: WalletInteractable,
         viewController: WalletViewControllable,
         historyDetailBuilder: WalletDetailHistoryBuildable,
         listHistoryBuildabler : WalletListHistoryBuildable,
         paymentMethodManageBuildabler: PaymentMethodManageBuildable, topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable)
    {
        self.topUpByThirdPartyBuildable = topUpByThirdPartyBuildable
        self.historyDetailBuilder = historyDetailBuilder
        self.listHistoryBuildabler = listHistoryBuildabler
        self.paymentMethodManageBuildabler = paymentMethodManageBuildabler
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
//    func showTopup(items: [TopupLinkConfigureProtocol], paymentStream: MutablePaymentStream?) {
//        let topupVC = TopUpChooseVC(with: items, paymentStream: paymentStream)
//        self.viewController.uiviewController.navigationController?.pushViewController(topupVC, animated: true)
//    }
    
    func routeToTopup() {
        let router = topUpByThirdPartyBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func showDetail(by item: WalletDetailHistoryType) {
        let router = historyDetailBuilder.build(withListener: self.interactor, use: item)
        let transition = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: true)
        self.perform(with: transition, completion: nil)
    }
    
    func showListWalletHistory() {
        let router = listHistoryBuildabler.build(withListener: self.interactor, balanceType: 3)
        let transition = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: true)
        self.perform(with: transition, completion: nil)
    }
    
    func routeToManageCard() {
        let router = paymentMethodManageBuildabler.build(withListener: self.interactor)
        let transition = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: true)
        self.perform(with: transition, completion: nil)
    }
    
    func showTopupNapas(type: TopUpNapasWebType) {
        TopUpNapasWebVC.loadWeb(on: self.viewController.uiviewController, title: Text.confirmPayment.localizedText, type: type)
            .observeOn(MainScheduler.asyncInstance).subscribe {[weak self] e in
                guard let wSelf = self else { return }
                switch e {
                case .next:
                    wSelf.interactor.processNapasPaymentSuccess(showAlert: true)
                case .error(let r):
                    wSelf.interactor.processNapasPaymentFailure(status: -10001, message: r.localizedDescription)
                case .completed:
                    printDebug("Completed")
                }
                
        }.disposed(by: disposeBag)
    }
    
    private let historyDetailBuilder: WalletDetailHistoryBuildable
    private let listHistoryBuildabler : WalletListHistoryBuildable
    private let paymentMethodManageBuildabler: PaymentMethodManageBuildable
    private let topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable
}
