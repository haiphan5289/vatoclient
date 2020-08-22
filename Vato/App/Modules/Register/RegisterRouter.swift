//  File name   : RegisterRouter.swift
//
//  Author      : Vato
//  Created date: 11/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka
import RxSwift

import Kingfisher

protocol RegisterInteractable: Interactable, FormHandlerProtocol {
    var router: RegisterRouting? { get set }
    var listener: RegisterListener? { get set }

    var isLoading: Observable<Bool> { get }

    func validate(referralCode: String, completion: @escaping (Bool, Error?) -> Void)

}

protocol RegisterViewControllable: ViewControllable {
    func generateRegisterNextButton() -> UIButton
}

final class RegisterRouter: Router<RegisterInteractable> {
    /// Class's constructor.
    init(interactor: RegisterInteractable,
         viewController: RegisterViewControllable,
         form: Form,
         referralCode: Observable<URLComponents>)
    {
        self.viewController = viewController
        self.form = form
        self.referralCode = referralCode
        super.init(interactor: interactor)
        interactor.router = self
    }

    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        let newUser = Auth.auth().currentUser

        nextButton = viewController.generateRegisterNextButton()
        nextButton?.isEnabled = false
        nextButton?.addTarget(self, action: #selector(RegisterRouter.handleNextButtonOnPressed(_:)), for: .touchUpInside)

        form +++ Section() { (section) in
            var header = HeaderFooterView<RegisterHeaderView>(.nibFile(name: "RegisterHeaderView", bundle: Bundle.main))
            header.onSetupView = { (view, _) in
                if let url = newUser?.providerData.first(where: { $0.photoURL != nil })?.photoURL {
                    view.avatarImageView.kf.setImage(with: url)
                }
            }
            header.height = { 100.0 }
            section.header = header
        }
        <<< MasterNameFieldRow(Text.fullname.text) {
            $0.title = Text.fullname.localizedText
            $0.placeholder = Text.fullname.localizedText

            $0.value = newUser?.providerData.first(where: { $0.displayName != nil })?.displayName

            $0.add(rule: RuleRequired(msg: Text.requiredFullname.localizedText))
            $0.add(rule: RuleMinLength(minLength: 5, msg: Text.minLengthFullname.localizedText, id: "fullnameMinLength"))
            $0.add(rule: RuleRegExp(regExpr: Regex.fullname, allowsEmpty: false, msg: Text.invalidFullname.localizedText))

            $0.onChange({ [weak self] _ in
                self?.enableContinueButton()
            })
        }
        <<< MasterEmailFieldRow(Text.email.text) {
            $0.title = Text.email.localizedText
            $0.placeholder = Text.email.localizedText

            $0.value = newUser?.providerData.first(where: { $0.email != nil })?.email

            $0.add(rule: RuleRequired(msg: Text.requiredEmail.localizedText))
            $0.add(rule: RuleRegExp(regExpr: Regex.email, allowsEmpty: false, msg: Text.invalidEmail.localizedText))

            $0.onChange({ [weak self] _ in
                self?.enableContinueButton()
            })
        }
        <<< MasterNameFieldRow(Text.nickname.text) {
            $0.title = Text.nickname.localizedText
            $0.placeholder = Text.nickname.localizedText

            $0.value = newUser?.providerData.first(where: { $0.displayName != nil })?.displayName

            $0.add(rule: RuleMaxLength(maxLength: 40, msg: Text.maxLengthNickname.localizedText, id: "nicknameMaxLength"))
        }
        <<< MasterTextFieldRow(Text.referralCode.text) {
            $0.title = Text.referralCode.localizedText
            $0.placeholder = Text.referralCodeIfNeccessary.localizedText
            $0.add(rule: RuleClosure(closure: { [weak self] (value) -> ValidationError? in
                if self?.error != nil {
                    return ValidationError(msg: Text.invalidReferralCode.localizedText)
                } else {
                    return nil
                }
            }))
        }

        if let row = form.rowBy(tag: Text.referralCode.text) as? MasterTextFieldRow {
            row.cell.textField.rx.controlEvent(.editingDidBegin)
                .bind { [weak self] (_) in
                    self?.nextButton?.isEnabled = false
                }
                .disposed(by: disposeBag)

            row.cell.textField.rx.controlEvent(.editingDidEnd)
                .bind { [weak self] (_) in
                    self?.error = nil
                    self?.requestValidate(referralCode: row.cell.textField.text ?? "")
                }
                .disposed(by: disposeBag)

            referralCode.map { $0.queryItems?.first(where: { $0.name == "code" }) }
                .filterNil()
                .take(1)
                .observeOn(MainScheduler.asyncInstance)
                .bind { [unowned row] (item) in
                    row.value = item.value
                    row.updateCell()
                }
                .disposed(by: disposeBag)
        }

        interactor.isLoading
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (isLoading) in
                if isLoading {
                    LoadingManager.showProgress()
                    self?.nextButton?.isEnabled = false
                } else {
                    LoadingManager.dismissProgress()
                }
            }
            .disposed(by: disposeBag)

        if newUser != nil {
            enableContinueButton()
        }
    }

    @objc func handleNextButtonOnPressed(_ sender: Any) {
        guard form.validate().count == 0 else {
            return
        }
        interactor.execute(form: form, viewController: viewController)
    }
    
    /// Class's private properties.
    private let viewController: RegisterViewControllable
    private let form: Form
    private let referralCode: Observable<URLComponents>

    private let disposeBag = DisposeBag()

    private weak var nextButton: UIButton?
    private var error: Error?
}

// MARK: RegisterRouting's members
extension RegisterRouter: RegisterRouting {
    func cleanupViews() {
        // todo: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
    }
}

// MARK: Class's private methods
private extension RegisterRouter {
    private func requestValidate(referralCode: String) {
        if referralCode.count > 0 {
            interactor.validate(referralCode: referralCode, completion: { [weak self] (isValid, err) in
                if isValid {
                    self?.nextButton?.isEnabled = true
                } else {
                    self?.error = err
                    _ = self?.form.rowBy(tag: Text.referralCode.text)?.validate()
                }
            })
        } else {
            enableContinueButton()
        }
    }

    private func enableContinueButton() {
        guard form.validate().count == 0 else {
            nextButton?.isEnabled = false
            return
        }
        nextButton?.isEnabled = true
    }
}
