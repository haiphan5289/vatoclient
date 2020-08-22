//  File name   : BuyTicketPaymentRouter.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FwiCore

protocol BuyTicketPaymenInteractable: Interactable, SwitchPaymentListener, NoteDeliveryListener, ResultBuyTicketListener, TopUpByThirdPartyListener, WalletListener {
    var router: BuyTicketPaymenRouting? { get set }
    var listener: BuyTicketPaymenListener? { get set }
    
    func processNapasPaymentSuccess()
    func processNapasPaymentFailure(status: Int, message: String)
    func requestZaloPayToken() -> Observable<String>
    func moveBackBuyNewTicket()
}

protocol BuyTicketPaymentViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BuyTicketPaymentRouter: ViewableRouter<BuyTicketPaymenInteractable, BuyTicketPaymentViewControllable> {
    /// Class's constructor.
    init(interactor: BuyTicketPaymenInteractable,
         viewController: BuyTicketPaymentViewControllable,
         switchPaymentBuildable: SwitchPaymentBuildable,
         noteDeliveryBuildable: NoteDeliveryBuildable,
         resultBuyTicketBuildable: ResultBuyTicketBuildable,
         topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable,
         walletBuildable: WalletBuildable)
    {
        self.topUpByThirdPartyBuildable = topUpByThirdPartyBuildable
        self.resultBuyTicketBuildable = resultBuyTicketBuildable
        self.noteDeliveryBuildable = noteDeliveryBuildable
        self.switchPaymentBuildable = switchPaymentBuildable
        self.walletBuildable = walletBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private var switchPaymentBuildable: SwitchPaymentBuildable
    private var noteDeliveryBuildable: NoteDeliveryBuildable
    private var resultBuyTicketBuildable: ResultBuyTicketBuildable
    private let topUpByThirdPartyBuildable: TopUpByThirdPartyBuildable
    private let walletBuildable: WalletBuildable
    private let disposeBag = DisposeBag()
}

// MARK: BuyTicketPaymenRouting's members
extension BuyTicketPaymentRouter: BuyTicketPaymenRouting {
    
    func routeToTopup() {
        let router = topUpByThirdPartyBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToTopupVATOPAY(use config: [TopupLinkConfigureProtocol]) {
        routeToTopup()
    }
    
    func routeToResultFailBuyTicket(state: BuyTicketPaymenState) {
        TicketPaymentErrorController.showFail(on: self.viewControllable.uiviewController,
                                              state: state)
        .bind(onNext: weakify({ (_, wSelf) in
            wSelf.interactor.moveBackBuyNewTicket()
        })).disposed(by: disposeBag)
    }
    
    func routeToResultBuyTicket(streamType: BuslineStreamType) {
        let router = resultBuyTicketBuildable.build(withListener: interactor,
                                                    streamType: streamType)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToPaymentMethod() {
        let router = switchPaymentBuildable.build(withListener: interactor, switchPaymentType: .service(service: .buyTicket))
        let segue = RibsRouting(use: router,
                                transitionType: .presentNavigation,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToDetailPrice() { }
    
    func routeToNote(note: NoteDeliveryModel?, noteTextConfig: NoteTextConfig) {
        let router = noteDeliveryBuildable.build(withListener: interactor,
                                                 noteDelivery: note,
                                                 noteTextConfig: noteTextConfig)
        let segue = RibsRouting(use: router, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func showTopupNapas(htmlString: String, redirectUrl: String?) {
        TopUpNapasWebVC.loadWeb(on: self.viewController.uiviewController, title: Text.confirmPayment.localizedText, type: .local(htmlString: htmlString, redirectUrl: redirectUrl))
            .observeOn(MainScheduler.asyncInstance).subscribe {[weak self] e in
                guard let wSelf = self else { return }
                switch e {
                case .next(let result):
                    guard result != nil else {
                        return
                    }
                    wSelf.interactor.processNapasPaymentSuccess()
                case .error(let r):
                    wSelf.interactor.processNapasPaymentFailure(status: -10001, message: r.localizedDescription)
                case .completed:
                    printDebug("Completed")
                }
                
        }.disposed(by: disposeBag)
    }
    
    func paymentEWallet(method: String,
                        amount: Int,
                        fee: Int,
                        name: String,
                        editParams: ((NSMutableDictionary) -> NSMutableDictionary)?) -> Observable<(JSON, Bool)> {
        let controller = viewControllable.uiviewController
        weak var object: BuyTicketPaymentRouter? = self
        return Observable.create { (s) -> Disposable in
            let topUpAction = TopUpAction(with: method, amount: amount, controller: self.viewControllable.uiviewController, topUpItem: nil)
            let items = [WithdrawConfirmItem(title: Text.pay.localizedText.uppercased(), message: amount.currency),
                         WithdrawConfirmItem(title: Text.amountOfMoney.localizedText, message: (amount - fee).currency),
                         WithdrawConfirmItem(title: Text.paymentMethod.localizedText, message: name),
                         WithdrawConfirmItem(title: Text.paymentFees.localizedText, message: fee.currency),
                         WithdrawConfirmItem(title: FwiLocale.localized("Tổng tiền thanh toán"), message: amount.currency)]
            let confirmVC = WithdrawConfirmVC({ items }, title: Text.buyTicket.localizedText, handler: topUpAction)
            topUpAction.topUpEditParams = editParams
            topUpAction.topUpHandlerResult = { (params, check) in
                var params = params
                params["appid"] = TopUpAction.Configs.appId
                let p: JSON = ["paymentInfo": params]
                s.onNext((p, check))
                s.onCompleted()
            }
            
            topUpAction.topUpBlockRequestZaloPayToken = object?.interactor.requestZaloPayToken
            controller.navigationController?.pushViewController(confirmVC, animated: true)
            return Disposables.create {
                controller.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func routeToAddCard() {
        let route = walletBuildable.build(withListener: interactor, source: .booking)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension BuyTicketPaymentRouter {
}

extension BuyTicketPaymentRouter: TopUpHandlerResultProtocol, Weakifiable {
    func topHandlerResult() {
        self.viewController.uiviewController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
