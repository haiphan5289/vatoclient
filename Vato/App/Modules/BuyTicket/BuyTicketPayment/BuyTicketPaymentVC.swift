//  File name   : BuyTicketPaymentVC.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCoreRX

protocol BuyTicketPaymentPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var ticketInformationObser: Observable<TicketInformation> { get }
    var returnTicketInformationObser: Observable<TicketInformation> { get }
    var eMethod: Observable<PaymentCardDetail> { get }
    var stateResult: Observable<BuyTicketPaymenState> { get }
    var noteDeliveryObser: Observable<NoteDeliveryModel?> { get }
    var streamType: BuslineStreamType {get}
    var mError: Observable<BuyTicketPaymenState> { get }
    var isRoundTrip: Bool { get }
    var buyTicketStream: BuyTicketStreamImpl { get }
    var paymentStream: PaymentStream { get }
    
    func moveBack()
    func routToPaymentMethod()
    func routToDetailPrice()
    func requestPaymentTicket()
    func routToNote()
    func routeToTopupVATOPAY()
    func updateCardPayment(card: PaymentCardDetail)
    func routeToAddCard()
}

final class BuyTicketPaymentVC: UIViewController, BuyTicketPaymentPresentable, BuyTicketPaymentViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
    }
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var promotionBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var listPaymentBtn: UIButton!
    @IBOutlet weak var viewDetailPriceBtn: UIButton!
    @IBOutlet weak var paymentMethodLabel: UIButton!
    @IBOutlet weak var noteBtn: UIButton!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var lblPromotion: UILabel?
    @IBOutlet weak var lblNote: UILabel?
    @IBOutlet weak var containerPayment: UIView?
    @IBOutlet weak var hContainerPayment: NSLayoutConstraint?
    private var vPaymentView: VatoPaymentSelectView?
    
    private var loading: Bool = false
    /// Class's public properties.
    weak var listener: BuyTicketPaymentPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        //        viewPayment.dropShadow()
    }
    @IBOutlet weak var viewPayment: UIView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    lazy var disposeBag = DisposeBag()
    var controllerDetail: TicketInfoVC? {
        return children.compactMap { $0 as? TicketInfoVC }.first
    }
    
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 7)
        v.containerColor = .white
        return v
    }()
    
}

// MARK: View's event handlers
extension BuyTicketPaymentVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension BuyTicketPaymentVC {
    func showPopupBalanceInvalid() {
        AlertVC.showMessageAlert(for: self,
                                 title: Text.walletVATOPayNotEnoughBalance.localizedText,
                                 message: Text.walletVATOPayNotEnoughBalanceMessage.localizedText,
                                 actionButton1: Text.cancel.localizedText,
                                 actionButton2: Text.depositVATOPay.localizedText,
                                 handler1: nil,
                                 handler2: { [weak self] in
                                    self?.listener?.routeToTopupVATOPAY() })
    }
    
    func resetListenAddCard() {
        vPaymentView?.resetListenAddCard()
    }
}

// MARK: Class's private methods
private extension BuyTicketPaymentVC {
    private func localize() {
        // todo: Localize view's here.
        paymentLabel.text = Text.selectPaymentMethod.localizedText
        continueBtn.setTitle(Text.pay.localizedText, for: .normal)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        title = Text.informationTicket.localizedText
        setupNavigation()
        
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        viewPayment.backgroundColor = .clear
        viewPayment.insertSubview(mContainer, at: 0)
        lblPromotion?.text = Text.promotion.localizedText
        lblNote?.text = Text.note.localizedText
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
                
        guard let listener = self.listener else { return }
        let vPayment = VatoPaymentSelectView.createPaymentView(use: listener.paymentStream, service: .service(service: .buyTicket))
        vPayment >>> containerPayment >>> {
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        vPayment.controller = self
        self.vPaymentView = vPayment
        vPayment.updateLayout.bind { [weak self](constant) in
            let edges = UIEdgeInsets(top: 0, left: 0, bottom: 100 + constant, right: 0)
            self?.controllerDetail?.tableView.contentInset = edges
            UIView.animate(withDuration: 0.3) {
                self?.hContainerPayment?.constant = constant
                self?.view.layoutIfNeeded()
            }
        }.disposed(by: disposeBag)
        vPayment.selected.distinctUntilChanged().bind(onNext: weakify({ (card, wSelf) in
            if card.addCard {
                wSelf.listener?.routeToAddCard()
            } else {
                wSelf.listener?.updateCardPayment(card: card)
            }
        })).disposed(by: disposeBag)
    }
    
    private func bindingData(ticketInformation: TicketInformation, returnTicketInformation: TicketInformation?) {
        guard let isRoundTrip = self.listener?.isRoundTrip else {
            return
        }
        let type = self.listener?.streamType ?? .buyNewticket
        let totalPromotion: Double? = ticketInformation.seats?.reduce(0, { (x, y) -> Double in
            return x + (y.discount ?? 0)
        })
        if !isRoundTrip {
            switch type {
            case .changeTicket(let model):
                let totalPriceNew = Int64(ticketInformation.totalPrice ?? 0)
                let moneyReturn = model.totalPrice(newRoute: ticketInformation.routeId ?? 0)
                let feeChange = model.feeMoney(newRoute: ticketInformation.routeId ?? 0)
                let totalPrice = max(((totalPriceNew - moneyReturn) + feeChange), 0)
                priceLabel.text = totalPrice.currency
            default:
                let defaultPrice = ticketInformation.totalPrice.orNil(0)
//                totalPromotion
                
                let totalAmount = listener?.buyTicketStream.ticketPrice?.total_amount.orNil(defaultPrice)
//                priceLabel.text =  listener?.buyTicketStream.ticketPrice?.total_amount.orNil(defaultPrice).currency
                priceLabel.text = ((totalAmount ?? 0) - (totalPromotion ?? 0)).currency
                //ticketInformation.totalPriceTicket.currency
            }
            controllerDetail?.updateUI(model: ticketInformation, streamType: listener?.streamType ?? .buyNewticket)
        } else {
            switch type {
            case .changeTicket(_):
                break
            default:
                let returnDiscount: Double?
                let defaultPrice = ticketInformation.totalPrice.orNil(0) + (returnTicketInformation?.totalPrice).orNil(0)
                let lastPrice = listener?.buyTicketStream.ticketPrice?.total_amount.orNil(defaultPrice)
                returnDiscount = returnTicketInformation?.seats?.reduce(0, { (x, y) -> Double in
                    return x + (y.discount ?? 0)
                })
                priceLabel.text = ((lastPrice ?? 0) - (totalPromotion ?? 0) - (returnDiscount ?? 0)).currency
            }
            
            controllerDetail?.updateUI(model: ticketInformation, streamType: listener?.streamType ?? .buyNewticket)
            controllerDetail?.updateReturnUI(model: returnTicketInformation)
        }
    }
    
    private func setupRX() {
        if let listener = listener {
            if !listener.isRoundTrip {
                listener.ticketInformationObser.bind(onNext: weakify({ (ticket, wSelf) in
                    wSelf.bindingData(ticketInformation: ticket, returnTicketInformation: nil)
                })).disposed(by: disposeBag)
            } else {
                Observable.zip(listener.ticketInformationObser, listener.returnTicketInformationObser).bind(onNext: weakify({ (i, wSelf) in
                    wSelf.bindingData(ticketInformation: i.0, returnTicketInformation: i.1)
                })).disposed(by: disposeBag)
            }
        }
        
        viewDetailPriceBtn.rx.tap.bind {[weak self] (_) in
            self?.listener?.routToDetailPrice()
        }.disposed(by: disposeBag)
        
        listPaymentBtn.rx.tap.bind {[weak self] (_) in
            self?.listener?.routToPaymentMethod()
        }.disposed(by: disposeBag)
        
        listener?.eMethod.bind(onNext: {[weak self] (paymentMethod) in
            self?.paymentMethodLabel.setTitle(paymentMethod.nameDisplay, for: .normal)
            self?.paymentMethodLabel.backgroundColor = paymentMethod.bgColor
        }).disposed(by: disposeBag)
        
        continueBtn.rx.tap.bind {[weak self] (_) in
            guard self?.loading == false else { return }
            self?.listener?.requestPaymentTicket()
        }.disposed(by: disposeBag)
        
        listener?.stateResult.bind(onNext: {[weak self] (state) in
            switch state {
            case .success:
                AlertVC.showMessageAlert(for: self, title: "", message: state.getMsg(), actionButton1: Text.dismiss.localizedText, actionButton2: nil)
            case .checkoutUseBalanceInvalid:
                self?.showPopupBalanceInvalid()
            default:
                AlertVC.showError(for: self, message: state.getMsg())
            }
        }).disposed(by: disposeBag)
        
        promotionBtn.rx.tap.bind {[weak self] (_) in
            AlertVC.showMessageAlert(for: self, title: "", message: Text.thereAreNoPromotions.localizedText, actionButton1: Text.dismiss.localizedText, actionButton2: nil)
        }.disposed(by: disposeBag)
        
        noteBtn.rx.tap.bind {[weak self] (_) in
            self?.listener?.routToNote()
        }.disposed(by: disposeBag)
        
        listener?.noteDeliveryObser.bind(onNext: {[weak self] (note) in
            self?.noteIcon.image = (note?.note?.isEmpty ?? true) ? UIImage(named: "ic_note_style1_off") : UIImage(named: "ic_note_style1_on")
        }).disposed(by: disposeBag)
        
        listener?.mError.bind(onNext: {[weak self] (errorType) in
            AlertVC.showError(for: self, message: errorType.getMsg())
        }).disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_arrow_back")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.showPopupConfirmBack()
        }).disposed(by: disposeBag)
    }
    
    private func showPopupConfirmBack() {
        AlertVC.showMessageAlert(for: self, title: Text.confirm.localizedText,
                                 message: Text.youSureTocancelThisOperation.localizedText,
                                 actionButton1: Text.dismiss.localizedText,
                                 actionButton2: Text.agree.localizedText,
                                 handler2: { [weak self] in
                                    self?.listener?.moveBack()
        })
    }
}
