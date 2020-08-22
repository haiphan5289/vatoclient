//  File name   : CancelTicketVC.swift
//
//  Author      : vato.
//  Created date: 10/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCoreRX


protocol CancelTicketPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func moveBack()
    func cancelTicket()
    func cancelTicketSuccess()
    var loading: Observable<(Bool, Double)> { get }
    var item: TicketHistoryType { get }
    var _error: Observable<BuyTicketPaymenState> { get }
}

final class CancelTicketVC: UIViewController, CancelTicketPresentable, CancelTicketViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    @IBOutlet weak var paymentCancelFeeLabel: UILabel!
    @IBOutlet weak var priceFareCancelLabel: UILabel!
    @IBOutlet weak var cancelTicketBtn: UIButton!
    private struct Config {
        static let percentDiscountCancelTicket = 10.0
    }
    
    private var loading: Bool = false
    /// Class's public properties.
    weak var listener: CancelTicketPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        let item = listener?.item
        controllerDetail?.setupUI(item: listener?.item)
        
        let price = item?.price ?? 0
        let feeCancel = (item?.feeCancel ?? 0)/100
        let moneyFee = Float(price) * feeCancel
        let mFee = moneyFee / 1000
        
        self.priceFareCancelLabel.text = "\(Int64(mFee * 1000).currency)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    /// Class's private properties.
    internal lazy var disposeBag = DisposeBag()
    @IBOutlet weak var paymentView: UIView!
    var controllerDetail: CancellationTicketInfo? {
        return children.compactMap { $0 as? CancellationTicketInfo }.first
    }
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 14)
        v.containerColor = .white
        return v
    }()
}

//CancellationTicketInfo

// MARK: View's event handlers
extension CancelTicketVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension CancelTicketVC {
}

// MARK: Class's private methods
private extension CancelTicketVC {
    private func localize() {
        paymentCancelFeeLabel.text = Text.cancellationPaymentFee.localizedText
        cancelTicketBtn.setTitle(Text.cancellationCofirm.localizedText, for: .normal)
    }
    private func visualize() {
        // todo: Visualize view's here.
        title = Text.cancelTicket.localizedText
        setupNavigation()
        paymentView.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    }
    
    private func setupNavigation() {
        let navigationBar = navigationController?.navigationBar
        let bgImage = UIImage(named:"bg_navigationbar")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationBar?.setBackgroundImage(bgImage, for: .default)
        navigationBar?.barTintColor = Color.orange
        navigationBar?.isTranslucent = false
        navigationBar?.tintColor = .white
        navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let image = UIImage(named: "ic_close_white")
        let leftButton = UIButton(frame: CGRect(origin: .zero, size: image?.size ?? .zero))
        leftButton.setImage(image, for: .normal)
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = leftBarButton
        leftButton.rx.tap.bind(onNext: weakify { wSelf in
            wSelf.listener?.moveBack()
        }).disposed(by: disposeBag)
    }
    
    private func setupRX() {
        cancelTicketBtn.rx.tap.bind {[weak self] _ in
            guard self?.loading == false else { return }
            self?.listener?.cancelTicket()
        }.disposed(by: disposeBag)
        
        listener?.loading.bind(onNext: {[weak self] (loading, progress) in
            self?.loading = loading
        }).disposed(by: disposeBag)
        
        showLoading(use: listener?.loading)

        listener?._error.bind(onNext: {[weak self] err in
            let message = Text.cancellationTicketSuccessContent.localizedText
            switch err {
            case .success:
                AlertVC.showMessageAlert(for: self,
                                         title: Text.cancellationTickerSuccess.localizedText,
                                         message: message,
                                         actionButton1: Text.dismiss.localizedText,
                                         actionButton2: nil,
                                         handler1: { [weak self] in
                                            self?.listener?.cancelTicketSuccess()
                })
            default:
                AlertVC.showError(for: self, message: err.getMsg())
            }
        }).disposed(by: disposeBag)
        
    }
}
