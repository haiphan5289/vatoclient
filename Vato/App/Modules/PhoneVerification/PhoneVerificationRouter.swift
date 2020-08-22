//  File name   : PhoneVerificationRouter.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka
import FwiCoreRX
import RxSwift
import SMSVatoAuthen

protocol PhoneVerificationInteractable: Interactable, FormHandlerProtocol {
    var router: PhoneVerificationRouting? { get set }
    var listener: PhoneVerificationListener? { get set }

    var error: Observable<AuthenticationError> { get }
    var isLoading: Observable<(Bool, Double)> { get }
    var phoneNumber: Observable<String> { get }

    func handleResendOTPAction(completion: @escaping () -> Void)
    func continueWithoutLinkSocialNetwork()
}

protocol PhoneVerificationViewControllable: ViewControllable {
    func generatePhoneVerificationNextButton() -> UIButton
}

final class PhoneVerificationRouter: Router<PhoneVerificationInteractable>, LoadingAnimateProtocol, DisposableProtocol {
    struct Config {
        static let reachOutOfSmsServiceException = "ReachOutOfSmsServiceException"
        static let reachMaxAttemptVerifyAuthenticateException = "ReachMaxAttemptVerifyAuthenticateException"
        static let reachMaxRequestAuthenticateException = "ReachMaxRequestAuthenticateException"
        static let errorTooManyRequest = "ERROR_TOO_MANY_REQUESTS"
    }
    
    /// Class's constructor.
    init(interactor: PhoneVerificationInteractable,
         viewController: PhoneVerificationViewControllable,
         form: Form)
    {
        self.viewController = viewController
        self.form = form
        super.init(interactor: interactor)
        interactor.router = self
    }

    private lazy var timerButton: ButtonTimer = {
        let timerButton = ButtonTimer(scheduleTimeInterval: SMSVatoAuthenInterface.retry)
        return timerButton
    }()

    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()

        nextButton = viewController.generatePhoneVerificationNextButton()
        nextButton?.isEnabled = false

        nextButton?.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.viewController.uiviewController.view.findAndResignFirstResponder()
            wSelf.interactor.execute(form: wSelf.form, viewController: wSelf.viewController)
        }
        .disposed(by: disposeBag)

        timerButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let wSelf = self else {
                return
            }

            wSelf.interactor.handleResendOTPAction(completion: {
                wSelf.timerButton.isEnabled = false

                if let pincodeRow = wSelf.form.allRows.last as? MasterPincodeRow {
                    pincodeRow.title = nil
                    pincodeRow.value = nil
                    pincodeRow.updateCell()
                }
            })
        })
        .disposed(by: disposeBag)

        interactor.phoneNumber
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (phoneNumber) in
                guard let wSelf = self else {
                    return
                }

                wSelf.form +++ Section() { (section) in
                    var header = HeaderFooterView<PhoneVerificationHeaderView>(.nibFile(name: "PhoneVerificationHeaderView", bundle: Bundle.main))
                    header.onSetupView = { (view, _) in
                        view.descriptionLabel.text = Text.inputVerificationCode.localizedText
                        view.phoneLabel.text = phoneNumber
                    }

                    let width = UIScreen.main.bounds.width
                    switch width {
                    case 320:
                        header.height = { 60.0 }
                    default:
                        header.height = { 112.0 }
                    }
                    section.header = header

                    var footer = HeaderFooterView<UIView>(.callback({ UIView() }))
                    footer.onSetupView = { (view, _) in
                        wSelf.timerButton >>> view >>> {
                            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
                            $0.setTitleColor(EurekaConfig.detailColor, for: .disabled)
                            $0.setTitleColor(EurekaConfig.primaryColor, for: .normal)
                            $0.setTitle(Text.resendOTP.localizedText, for: .normal)
                            $0.isEnabled = false

                            $0.snp.makeConstraints {
                                $0.edges.equalToSuperview()
                            }
                        }
                    }
                    footer.height = { 80.0 }
                    section.footer = footer
                }
                <<< MasterPincodeRow(Text.pincode.text) {
                    if #available(iOS 12, *) {
                        $0.cell.textField.textContentType = .oneTimeCode
                    }
                    $0.cell.textField.becomeFirstResponder()
                    
                    $0.onFinished = { (isFinished) in
                        self?.nextButton?.isEnabled = isFinished
                    }
                }
            }
            .disposed(by: disposeBag)

        // Focus on phone input field
        viewController.uiviewController.rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
            .take(1)
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (_) in
                if let row = self?.form.rowBy(tag: Text.pincode.text) as? MasterPincodeRow {
                    row.cell.textField.becomeFirstResponder()
                }
            }
            .disposed(by: disposeBag)

        // Register activity indicator
        
        showLoading(use: interactor.isLoading)

        // Register error handler
        handleError()
    }
    
    /// Class's private properties
    private let viewController: PhoneVerificationViewControllable
    private let form: Form

    private weak var nextButton: UIButton?
    var disposeBag = DisposeBag()
}

// MARK: PhoneVerificationRouting's members
extension PhoneVerificationRouter: PhoneVerificationRouting {
    func cleanupViews() {
        form.removeAll()
    }
}

// MARK: Class's private methods
private extension PhoneVerificationRouter {
    private func handleError() {
        interactor.error
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (err) in
                guard let wSelf = self else {
                    return
                }

                switch err {
                case .invalidVerificationCode(let error):
                    if let pincodeRow = wSelf.form.allRows.last as? MasterPincodeRow {
//                        let errorReturn = error as NSError
//
//                        switch errorReturn.code {
//                        case AuthErrorCode.sessionExpired.rawValue:
//                            pincodeRow.title = Text.authenticationCodeExpired.localizedText
//
//                        case AuthErrorCode.invalidVerificationCode.rawValue:
//                            pincodeRow.title = Text.invalidAuthenticationCode.localizedText
//
//                        case AuthErrorCode.credentialAlreadyInUse.rawValue:
//                            pincodeRow.title = Text.phoneNumberIsAssociatedWithAnotherAccount.localizedText
//
//                        case 70000: // FCLoginResultCodeBackendVerifyFailed
//                            pincodeRow.title = Text.accountError.localizedText
//                            break
//
//                        default:
//                            if errorReturn.localizedDescription.contains("InvalidVerifyCodeToVerifyAuthenticateException") {
//                                pincodeRow.title = Text.invalidAuthenticationCode.localizedText
//                            } else if errorReturn.localizedDescription.contains("VerifyCodeTimeOutException") {
//                                pincodeRow.title = Text.authenticationCodeExpired.localizedText
//                            } else {
//                                var text = Text.thereWasAnError.localizedText
//                                if self?.isReachLimitSMS(error: error) == true {
//                                    text = Text.exceededTheNumberTries.localizedText
//                                }
//                                pincodeRow.title = text
//                            }
//                        }
                        pincodeRow.title = error.localizedDescription
                        pincodeRow.updateCell()
                    }

                case .invalidFirebaseAuthenticatedData:
                    if let pincodeRow = wSelf.form.allRows.last as? MasterPincodeRow {
                        pincodeRow.title = "\(Text.invalidAuthenticationCode.localizedText)."
                        pincodeRow.updateCell()
                    }

                case .invalidSocialAccount:
                    let continueAction = AlertAction(style: StyleButton.default, title: Text.continue.localizedText, handler: { [weak self] in
                        guard
                            let wSelf = self
                            else {
                                return
                        }
                        wSelf.interactor.continueWithoutLinkSocialNetwork()
                        wSelf.interactor.execute(form: wSelf.form, viewController: wSelf.viewController)
                    })

                    let cancelAction = AlertAction(style: StyleButton.cancel, title: Text.cancel.localizedText, handler: {})
                    AlertVC.show(on: wSelf.viewController.uiviewController,
                                 title: Text.error.localizedText.capitalized,
                                 message: Text.invalidSocialAccount.localizedText,
                                 from: [cancelAction, continueAction],
                                 orderType: .horizontal)

                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
   private func isReachLimitSMS(error: Error?) -> Bool {
        guard let error = error else { return false }
        let errorMsg = error.localizedDescription.uppercased()
        var errorName =  ""
        let _error = error as NSError
        if let _errorName = _error.userInfo["error_name"] as? String {
            errorName = _errorName
        }
        if errorMsg.contains(Config.reachOutOfSmsServiceException.uppercased())
            || errorMsg.contains(Config.reachMaxAttemptVerifyAuthenticateException.uppercased())
            || errorMsg.contains(Config.reachMaxRequestAuthenticateException.uppercased())
            || errorName.contains(Config.errorTooManyRequest.uppercased()){
            return true
        }
        return false
    }
}
