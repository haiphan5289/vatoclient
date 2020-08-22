//  File name   : StoreDetailPriceVC.swift
//
//  Author      : khoi tran
//  Created date: 12/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX


protocol StoreDetailPricePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var quoteCard: Observable<QuoteCart?> { get }
    func checkOut()
    func dismiss()
}

final class StoreDetailPriceVC: UIViewController, StoreDetailPricePresentable, StoreDetailPriceViewControllable, DisposableProtocol {
    internal var disposeBag: DisposeBag = DisposeBag()
    
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: StoreDetailPricePresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    /// Class's private properties.
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var baseGrandTotalLabel: UILabel!
    @IBOutlet weak var shippingFeeLabel: UILabel!
    @IBOutlet weak var discountFeeLabel: UILabel!
    @IBOutlet weak var grandTotalLabel: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    
    private lazy var tapGesture = UITapGestureRecognizer.init()
    
}

// MARK: View's event handlers
extension StoreDetailPriceVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension StoreDetailPriceVC {
}

// MARK: Class's private methods
private extension StoreDetailPriceVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        bgView.addGestureRecognizer(tapGesture)
    }
    
    func setupRX() {
        self.listener?.quoteCard.bind(onNext: weakify({ (quoteCard, wSelf) in
            guard let q = quoteCard else { return }
            wSelf.baseGrandTotalLabel.text = (q.baseGrandTotal ?? 0).currency
            wSelf.shippingFeeLabel.text = (q.quoteShipments?.first?.price ?? 0).currency
            wSelf.discountFeeLabel.text = (q.discountAmount ?? 0).currency
            wSelf.grandTotalLabel.text = (q.grandTotal ?? 0).currency
        })).disposed(by: disposeBag)
        
        checkOutButton.rx.tap.bind(onNext: weakify({ (wSelf) in
            wSelf.listener?.checkOut()
            })).disposed(by: disposeBag)
        
        tapGesture.rx.event.bind(onNext: weakify({ (t, wSelf) in
            wSelf.listener?.dismiss()
            })).disposed(by: disposeBag)
    }
}
