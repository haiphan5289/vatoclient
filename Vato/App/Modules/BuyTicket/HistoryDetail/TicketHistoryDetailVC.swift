//  File name   : TicketHistoryDetailVC.swift
//
//  Author      : vato.
//  Created date: 10/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCoreRX
import RxSwift


protocol TicketHistoryDetailPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var eLoadingObser: Observable<(Bool,Double)> { get }
    var ticketHistoryTypeObser: Observable<TicketHistoryType?> { get }
    var stateResult: Observable<BuyTicketPaymenState> { get }
    func processAction(type: ActionSelectTicket, ticketHistoryType: TicketHistoryType)
    func didSeletctPayment()
    func paymentSuccess()
    func ticketHistoryDetailMoveBack()
}

final class TicketHistoryDetailVC: UIViewController, TicketHistoryDetailPresentable, TicketHistoryDetailViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: TicketHistoryDetailPresentableListener?

    lazy var disposeBag = DisposeBag()
    private var ticketHistoryType: TicketHistoryType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        title = Text.informationTicket.localizedText
        controllerDetail?.updateUIFromHistory(ticketModel: ticketHistoryType)
        controllerDetail?.listener = self
        setupRX()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    
    var controllerDetail: ResultBuyTicketDetailVC? {
        return children.compactMap { $0 as? ResultBuyTicketDetailVC }.first
    }
    
    func setupRX() {
        listener?.ticketHistoryTypeObser.bind(onNext: {[weak self] (model) in
            self?.ticketHistoryType = model
            self?.controllerDetail?.updateUIFromHistory(ticketModel: model)
        }).disposed(by: disposeBag)
        
        showLoading(use: self.listener?.eLoadingObser)
        
        listener?.stateResult.bind(onNext: { (state) in
            switch state {
            case .success:
                AlertVC.showMessageAlert(for: self, title: "", message: state.getMsg(), actionButton1: Text.dismiss.localizedText, actionButton2: nil)
            default:
                AlertVC.showError(for: self, message: state.getMsg())
            }
        }).disposed(by: disposeBag)
    }
    
}

// MARK: View's event handlers
extension TicketHistoryDetailVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let actionVC = segue.destination as? TicketHistoryActionVC,
            let item = sender as? TicketHistoryType {
            actionVC.actionSelectDisplay = item
            actionVC.listener = self
            return
        }
    }
}

// MARK: Class's public methods
extension TicketHistoryDetailVC {
    func showPopupPaymentSucces() {
        AlertVC.showMessageAlert(for: self, title: "", message: Text.buyTicketSuccess.localizedText, actionButton1: Text.dismiss.localizedText, actionButton2: nil, handler1: { [weak self] in
            self?.listener?.paymentSuccess()
        })
    }
    
    private func showPopupConfirmPayment() {
        let code = ticketHistoryType?.code ?? ""
        let price = ticketHistoryType?.priceStr ?? ""
        let message = String(format: Text.payWithVATOPayMessage.localizedText, code, price)
        AlertVC.showMessageAlert(for: self,
                                 title: Text.payByVATOPay.localizedText,
                                 message: message,
                                 actionButton1: Text.ignore.localizedText,
                                 actionButton2: Text.confirm.localizedText,
                                 handler2: { [weak self] in
                                    self?.listener?.didSeletctPayment()
        })
    }
    
    func setupModel(ticketHistoryType: TicketHistoryType?) {
        self.ticketHistoryType = ticketHistoryType
        controllerDetail?.updateUIFromHistory(ticketModel: ticketHistoryType)
    }

}

// MARK: Class's private methods
private extension TicketHistoryDetailVC {
    private func localize() {
        // todo: Localize view's here.
        setupNavigation()
    }
    private func visualize() {
        // todo: Visualize view's here.
    }
    
    private func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // left button
        let image = UIImage(named: "ic_arrow_back")
        let button = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.hidesBackButton = true
        button.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.ticketHistoryDetailMoveBack()
        }).disposed(by: disposeBag)
        
        // right button
        let righImage = UIImage(named: "ic_more")
        let righButton = UIButton(frame: CGRect(origin: .zero, size: righImage?.size ?? .zero))
        righButton.setImage(righImage, for: .normal)
        righButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -30)
        let rightBarButton = UIBarButtonItem(customView: righButton)
        navigationItem.rightBarButtonItem = rightBarButton
        
        righButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.showActionsheet()
        }).disposed(by: disposeBag)
    }
    
    private func showActionsheet() {
        guard let item = self.ticketHistoryType else { return }
        self.performSegue(withIdentifier: "showAction", sender: item)
    }
}

extension TicketHistoryDetailVC: TicketHistoryActionHandlerProtocol {
    func excuteAction(type: ActionSelectTicket) {
        guard let item = self.ticketHistoryType else { return }
        listener?.processAction(type: type, ticketHistoryType: item)
    }
}


extension TicketHistoryDetailVC :ResultBuyTicketDetailListener {
    func didSeletctPayment() {
        showPopupConfirmPayment()
    }
}
