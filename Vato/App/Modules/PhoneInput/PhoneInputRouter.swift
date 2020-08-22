//  File name   : PhoneInputRouter.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka
import RxSwift
import FwiCoreRX

protocol PhoneInputInteractable: Interactable, FormHandlerProtocol {
    var router: PhoneInputRouting? { get set }
    var listener: PhoneInputListener? { get set }

    var error: Observable<Error> { get }
    var isLoading: Observable<(Bool, Double)> { get }
    var phoneNumber: Observable<String> { get }
}

protocol PhoneInputViewControllable: ViewControllable {
    func generatePhoneInputNextButton() -> UIButton
}

final class PhoneInputRouter: Router<PhoneInputInteractable>, LoadingAnimateProtocol, DisposableProtocol {
    struct Config {
        static let reachOutOfSmsServiceException = "ReachOutOfSmsServiceException"
        static let reachMaxAttemptVerifyAuthenticateException = "ReachMaxAttemptVerifyAuthenticateException"
        static let reachMaxRequestAuthenticateException = "ReachMaxRequestAuthenticateException"
        static let errorTooManyRequest = "ERROR_TOO_MANY_REQUESTS"
    }
    /// Class's constructor.
    init(interactor: PhoneInputInteractable,
         viewController: PhoneInputViewControllable,
         form: Form)
    {
        self.viewController = viewController
        self.form = form
        super.init(interactor: interactor)
        interactor.router = self
    }

    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        nextButton = viewController.generatePhoneInputNextButton()
        nextButton?.isEnabled = false

        nextButton?.rx.tap.bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.interactor.execute(form: wSelf.form, viewController: wSelf.viewController)
//            wSelf.interactor.execute(form: wSelf.form, viewController: wSelf.viewController)
        }
        .disposed(by: disposeBag)

        interactor.phoneNumber
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (phoneNumber) in
                guard var form = self?.form else {
                    return
                }

                // Enable next button if phone number is available
                if phoneNumber.count > 0 {
                    self?.nextButton?.isEnabled = true
                }

                // Generate form
                let section = Section() { (section) in
                    var header = HeaderFooterView<PhoneInputHeaderView>(.nibFile(name: "PhoneInputHeaderView", bundle: Bundle.main))
                    header.height = { 105 }
                    section.header = header
                }
                <<< PhoneRow(Text.phoneNumber.text) { row in
                    row.placeholder = Text.phoneNumber.localizedText
                    row.value = phoneNumber

                    row.add(ruleSet: RulesPhoneNumber.rules())
                    row.callBackText = { text in
                        self?.nextButton?.isEnabled = row.isValid
                    }
//                    $0.validationChanged = {
//                        self?.nextButton?.isEnabled = $0.isValid
//                    }
                }

                UIView.performWithoutAnimation {
                    form += [section]
                }
            }
            .disposed(by: disposeBag)

        // Focus on phone input field
        viewController.uiviewController.rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
            .take(1)
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (_) in
                if let row = self?.form.rowBy(tag: Text.phoneNumber.text) as? PhoneRow {
                    row.cell.textField.becomeFirstResponder()
                }
            }
            .disposed(by: disposeBag)

        // Register activity indicator
        showLoading(use: interactor.isLoading)
        
        interactor.error
            .map { $0 as NSError }
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak self] (error) in
                let cancelAction = AlertAction.init(style: .default, title: Text.cancel.localizedText) {}
//                var text = Text.thereWasAnError.localizedText
//                if self?.isReachLimitSMS(error: error) == true {
//                    text = Text.exceededTheNumberTries.localizedText
//                }
                let text = error.localizedDescription
                AlertVC.show(on: self?.viewController.uiviewController,
                             title: Text.notification.localizedText,
                             message: text,
                             from: [cancelAction],
                             orderType: .horizontal)
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
    
    /// Class's private properties
    private let viewController: PhoneInputViewControllable
    private let form: Form

    private weak var nextButton: UIButton?
    internal var disposeBag = DisposeBag()
}

// MARK: PhoneInputRouting's members
extension PhoneInputRouter: PhoneInputRouting {
    func cleanupViews() {
        form.removeAll()
    }
}

// MARK: Class's private methods
private extension PhoneInputRouter {
}
