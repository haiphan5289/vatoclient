//  File name   : PhoneInputInteractor.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FirebaseAuth
import FwiCoreRX
import RxSwift
import SMSVatoAuthen

protocol PhoneInputRouting: Routing {
    func cleanupViews()
    
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol PhoneInputListener: class {
    func requestToChange(state: PhoneInputState)
}

final class PhoneInputInteractor: Interactor, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: PhoneInputRouting?
    weak var listener: PhoneInputListener?

    /// Class's constructor.
    init(mutableAuthenticationPhone: MutableAuthenticationPhoneStream,
         mutableAuthenticationVerificationCode: MutableAuthenticationVerificationCodeStream) {
        self.mutableAuthenticationPhone = mutableAuthenticationPhone
        self.mutableAuthenticationVerificationCode = mutableAuthenticationVerificationCode
        super.init()
    }

    // MARK: Class's public methods
    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
        
        // todo: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()
        
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private let mutableAuthenticationPhone: MutableAuthenticationPhoneStream
    private let mutableAuthenticationVerificationCode: MutableAuthenticationVerificationCodeStream

    private let errorPublisher = PublishSubject<Error>()
}

// MARK: Class's private methods
private extension PhoneInputInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }

    private func generateVerificationCode(phoneInput: PhoneInput, internationalFormat: String, localFormat: String) -> Observable<(String, String)> {
//        /* Condition validation: if we come back from phone verification, we can alway go forward without re-request sms. */
//        if phoneInput.phoneNumber == localFormat && phoneInput.verificationID.count > 0 {
//            return Observable.just((phoneInput.verificationID, localFormat))
//        }

        let proxy = PhoneInputBridgeImpl(prefix: phoneInput.dialCode, originalPhone: localFormat, internationalPhone: internationalFormat)
        return Observable.create { s in
            SMSVatoAuthenInterface.authenPhone(with: proxy, complete: { (verificationID) in
                s.onNext((verificationID, localFormat))
                s.onCompleted()
            }, error: { (err) in
                s.onError(err)
            })
            return Disposables.create()
        }
    }
}

// MARK: PhoneInputInteractor's members
extension PhoneInputInteractor: PhoneInputInteractable {
    var error: Observable<Error> {
        return errorPublisher.asObservable()
    }
    
    var isLoading: Observable<(Bool, Double)> {
        return indicator.asObservable()
    }

    var phoneNumber: Observable<String> {
        return mutableAuthenticationPhone.phoneInput.map { $0.phoneNumber }
    }

    func execute(input: [String : Any?]) {
        guard var phoneNumber = input[Text.phoneNumber.text] as? String else {
            return
        }
        phoneNumber = phoneNumber.trim()

        // Update phone number
        mutableAuthenticationPhone.phoneInput
            .take(1)
            .map { (phoneInput) -> (PhoneInput, String, String) in
                let phoneCode = phoneInput.dialCode

                // Format phone number
                phoneNumber = phoneNumber.replacingOccurrences(of: phoneCode, with: "").replacingOccurrences(of: " ", with: "")
                if phoneNumber[phoneNumber.startIndex] == "0" {
                    phoneNumber = String(phoneNumber.substring(fromIndex: 1))
                }
                return (phoneInput, "\(phoneCode)\(phoneNumber)", "0\(phoneNumber)")
            }
            .flatMap { [weak self] (phoneInput, internationalFormat, localFormat) in
                return self?.generateVerificationCode(phoneInput: phoneInput, internationalFormat: internationalFormat, localFormat: localFormat) ?? Observable.empty()
            }
            .observeOn(MainScheduler.instance)
            .trackProgressActivity(indicator)
            .subscribe(
                onNext: { [weak self] (verificationID, localFormat) in
                    self?.mutableAuthenticationVerificationCode.update(verificationID: verificationID)
                    self?.mutableAuthenticationPhone.update(phoneNumber: localFormat)
                    self?.listener?.requestToChange(state: .verify)
                },
                onError: { [weak self] (err) in
                    printError(err: err)
                    self?.errorPublisher.onNext(err)
                }
            )
            .disposeOnDeactivate(interactor: self)
    }
    func cancelForm() {
    }
}

// MARK: PhoneFormatProtocol proxy
private class PhoneInputBridgeImpl: NSObject, PhoneFormatProtocol {
    var prefix: String = ""
    var originalPhone: String = ""
    var internationalPhone: String = ""

    init(prefix: String, originalPhone: String, internationalPhone: String) {
        super.init()
        self.prefix = prefix
        self.originalPhone = originalPhone
        self.internationalPhone = internationalPhone
    }
}
