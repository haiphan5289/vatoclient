//  File name   : BookingConfirmPromotionVC.swift
//
//  Author      : Dung Vu
//  Created date: 10/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import FwiCoreRX

protocol BookingConfirmPromotionPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var priceStream: PriceStream { get }
    var promotionStream: MutablePromotion { get }
    func closeInputPromotion()
    func checkPromotion(from code: String?) -> Observable<PromotionModel>
    func update(model: PromotionModel?)
}

final class BookingConfirmPromotionVC: UIViewController, BookingConfirmPromotionPresentable, BookingConfirmPromotionViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    /// Class's public properties.
    weak var listener: BookingConfirmPromotionPresentableListener?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var btnConfirm: UIButton?
    @IBOutlet weak var textField: UITextField?
    @IBOutlet weak var lblError: UILabel?
    private(set) lazy var disposeBag = DisposeBag()
    private lazy var borderN: UIColor = #colorLiteral(red: 0.8745098039, green: 0.8823529412, blue: 0.9019607843, alpha: 1)
    private lazy var borderH: UIColor = Color.orange

    private lazy var eError: PublishSubject<Error?> = PublishSubject()
    private lazy var indicator: ActivityIndicator = ActivityIndicator()
    private var canEdit: Bool = true

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        self.listener?.promotionStream.ePromotion.filterNil().take(1).observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [weak self] model in
            self?.textField?.text = model.code
            self?.textField?.sendActions(for: .valueChanged)
        }).disposed(by: disposeBag)
        textField?.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField?.resignFirstResponder()
    }

    /// Class's private properties.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }

        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.listener?.closeInputPromotion()
    }
}

// MARK: Class's public methods
extension BookingConfirmPromotionVC: KeyboardAnimationProtocol {}
extension BookingConfirmPromotionVC: CancelableProtocol {
    var cancelButton: UIButton? {
        return btnCancel
    }

    func dismiss() {
        self.listener?.closeInputPromotion()
    }
}

// MARK: Class's private methods
private extension BookingConfirmPromotionVC {
    private func localize() {
        // todo: Localize view's here.
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        lblError?.textColor = Color.orange
        btnClose?.applyButton(style: .cancel)
        btnConfirm?.applyButtonWithoutBackground(style: .default)
        btnConfirm?.clipsToBounds = true
        btnConfirm?.setBackground(using: Color.orange, state: .normal)
        btnConfirm?.setBackground(using: #colorLiteral(red: 0.6588235294, green: 0.6588235294, blue: 0.6588235294, alpha: 1), state: .disabled)
        self.textField?.tintColor = Color.reddishOrange60
        let vLeft = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 16, height: 48))) >>> { $0.backgroundColor = .clear }
        let vRight = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 16, height: 48))) >>> { $0.backgroundColor = .clear }

        self.textField?.leftViewMode = .always
        self.textField?.rightViewMode = .unlessEditing
        self.textField?.leftView = vLeft
        self.textField?.rightView = vRight
    }

    private func setupRX() {
        // todo: Bind data to UI here.
        setupKeyboardAnimation()
        setupCancelButton(append: self.btnClose?.rx.tap.asObservable())
        self.textField?.delegate = self
        self.indicator.asObservable().observeOn(MainScheduler.instance).bind { [weak self] in
            self?.canEdit = !$0
            $0 ? LoadingManager.showProgress() : LoadingManager.dismissProgress()
        }.disposed(by: disposeBag)

        eError.bind { [weak self] e in
            guard let wSelf = self else {
                return
            }
            let isHaveError = e != nil
            wSelf.lblError?.isHidden = !isHaveError
            wSelf.lblError?.text = e?.localizedDescription
            wSelf.textField?.layer.borderColor = (isHaveError ? wSelf.borderH : wSelf.borderN).cgColor
        }.disposed(by: disposeBag)

        self.textField?.rx.text.map { $0 }.distinctUntilChanged().subscribe(onNext: { [weak self] _ in
            self?.eError.onNext(nil)
        }).disposed(by: disposeBag)

        guard let btnConfirm = self.btnConfirm else {
            return
        }

        self.textField?.rx.text.map { !($0?.count == 0) }.bind(to: btnConfirm.rx.isEnabled).disposed(by: disposeBag)

        btnConfirm.rx.tap.bind { [weak self] in
            self?.request(code: self?.textField?.text)
        }.disposed(by: disposeBag)
    }

    private func request(code: String?) {
        self.eError.onNext(nil)
        self.listener?.checkPromotion(from: code).trackActivity(self.indicator).observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] d in
            self?.listener?.update(model: d)
        }, onError: { [weak self] e in
            self?.eError.onNext(e)
        }).disposed(by: disposeBag)
    }
}

extension BookingConfirmPromotionVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return canEdit
    }
}
