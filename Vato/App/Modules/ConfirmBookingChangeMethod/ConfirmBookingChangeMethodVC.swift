//  File name   : ConfirmBookingChangeMethodVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit

enum ChangeMethod {
    case inputMoney
    case cash
}

protocol ConfirmBookingChangeMethodPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.

    var topupToWalletConfigure: Observable<AppLink?> { get }
    func change(method: ChangeMethod)
    func closeChangeMethod()
}

final class ConfirmBookingChangeMethodVC: UIViewController, ConfirmBookingChangeMethodPresentable, ConfirmBookingChangeMethodViewControllable {
    /// Class's public properties.
    weak var listener: ConfirmBookingChangeMethodPresentableListener?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var btnInputMoney: UIButton?
    @IBOutlet weak var btnCash: UIButton?
    @IBOutlet weak var stackView: UIStackView?

    private lazy var disposeBag = DisposeBag()

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()

        UIView.animate(withDuration: 0.3) {
            self.containerView?.transform = CGAffineTransform.identity
        }
    }

    /// Class's private properties.
}

// MARK: Class's public methods
extension ConfirmBookingChangeMethodVC {}

// MARK: Class's private methods
private extension ConfirmBookingChangeMethodVC {
    private func localize() {
        titleLabel?.text = Text.notEnoughVATOPay.localizedText
        descriptionLabel?.text = Text.notEnoughVATOPayDescription.localizedText
        btnInputMoney?.setTitle("\(Text.topUp.localizedText) VATOPay", for: .normal)
        btnCash?.setTitle(Text.payWithCash.localizedText, for: .normal)
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        self.btnInputMoney?.apply(style: .default)
        self.containerView?.transform = CGAffineTransform(translationX: 0, y: 1000)
    }

    private func setupRX() {
        // todo: Bind data to UI here.
        let eInputMoney = self.btnInputMoney?.rx.tap.map { ChangeMethod.inputMoney }
        let eCash = self.btnCash?.rx.tap.map { ChangeMethod.cash }

        Observable.merge([eInputMoney, eCash].compactMap { $0 }).bind { [weak self] in
            self?.listener?.change(method: $0)
        }.disposed(by: disposeBag)

        self.btnClose?.rx.tap.bind { [weak self] in
            self?.listener?.closeChangeMethod()
        }.disposed(by: disposeBag)

        // check show topup view
        self.listener?.topupToWalletConfigure.subscribe(onNext: { [weak self] configure in
            if configure == nil, let v = self?.btnInputMoney {
                self?.stackView?.removeArrangedSubview(v)
                v.removeFromSuperview()
                self?.containerView?.layoutSubviews()
            }
        }, onError: { [weak self] error in
            let e = error as NSError
            printDebug("check topup money: \(e)")
            guard let v = self?.btnInputMoney else { return }
            self?.stackView?.removeArrangedSubview(v)
            v.removeFromSuperview()
        }).disposed(by: disposeBag)
    }
}
