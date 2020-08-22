//  File name   : PhoneVerificationInteractor.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Alamofire
import FirebaseAuth

import FwiCoreRX
import SMSVatoAuthen

protocol PhoneVerificationRouting: Routing {
    func cleanupViews()
}

protocol PhoneVerificationListener: class {
    func requestToChange(state: PhoneInputState)
}

final class PhoneVerificationInteractor: Interactor, ActivityTrackingProgressProtocol {
    /// Class's public properties.
    weak var router: PhoneVerificationRouting?
    weak var listener: PhoneVerificationListener?
    
    /// Class's constructor.
    init(mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream,
         mutableAuthenticationUser: MutableAuthenticationUserStream) {
        self.mutableAuthenticationSocialCredential = mutableAuthenticationSocialCredential
        self.mutableAuthenticationUser = mutableAuthenticationUser
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
    private let mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream
    private let mutableAuthenticationUser: MutableAuthenticationUserStream

    private let errorPublisher = PublishSubject<AuthenticationError>()
}

// MARK: PhoneVerificationInteractor's members
extension PhoneVerificationInteractor: PhoneVerificationInteractable {
    var error: Observable<AuthenticationError> {
        return errorPublisher.asObservable()
    }

    var isLoading: Observable<(Bool, Double)> {
        return indicator.asObservable()
    }

    var phoneNumber: Observable<String> {
        return mutableAuthenticationUser.phoneInput.map { $0.phoneNumber }
    }

    func cancelForm() {
    }

    func execute(input: [String : Any?]) {
        guard let verificationCode = input[Text.pincode.text] as? String, verificationCode.count > 0 else {
            return
        }

        mutableAuthenticationUser.phoneInput.take(1)
            .flatMap { [weak self] (phoneInput) -> Observable<FirebaseAuth.User> in
                return self?.authenticate(with: phoneInput, verificationCode: verificationCode) ?? Observable.empty()
            }
            .flatMap { [weak self] (newUser) -> Observable<(FirebaseAuth.User, AuthCredential?)> in
                return self?.checkSocialCredential(with: newUser) ?? Observable.empty()
            }
            .flatMap { [weak self] (newUser, credential) -> Observable<FirebaseAuth.User> in
                return self?.link(newUser: newUser, with: credential) ?? Observable.empty()
            }
            .trackProgressActivity(indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [weak self] (newUser) in
                    self?.mutableAuthenticationSocialCredential.clearSocialData()
                    self?.mutableAuthenticationUser.update(user: newUser)
                },
                onError: { [weak self] (err) in
                    printError(err: err)

                    guard let authenticationError = err as? AuthenticationError else {
                        return
                    }
                    self?.errorPublisher.onNext(authenticationError)
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    func handleResendOTPAction(completion: @escaping () -> Void) {
        resendOTP().take(1)
            .trackProgressActivity(indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(
                onNext: { _ in
                    completion()
                },
                onError: { [weak self] (err) in
                    self?.errorPublisher.onNext(.invalidVerificationCode(e: err))
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    func continueWithoutLinkSocialNetwork() {
        mutableAuthenticationSocialCredential.clearSocialData()
    }
}

// MARK: Class's private methods
private extension PhoneVerificationInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }

    private func resendOTP() -> Observable<Bool> {
        return Observable<Bool>.create { s in
            SMSVatoAuthenInterface.retrySendSMS(complete: { (_) in
                s.onNext(true)
                s.onCompleted()
            }) { (err) in
                printError(err: err)
                s.onError(err)
            }
            return Disposables.create()
        }
    }

    private func authenticate(with phoneInput: PhoneInput, verificationCode: String) -> Observable<FirebaseAuth.User> {
        return Observable<FirebaseAuth.User>.create { s in
            SMSVatoAuthenInterface.authenOTP(with: verificationCode, complete: { (user) in
                guard let firebaseUser = user as? FirebaseAuth.User else {
                    s.onError(AuthenticationError.invalidFirebaseAuthenticatedData)
                    return
                }
                s.onNext(firebaseUser)
                s.onCompleted()

            }, error: { (err) in
                s.onError(AuthenticationError.invalidVerificationCode(e: err))
            })
            return Disposables.create()
        }
    }

    private func checkSocialCredential(with newUser: FirebaseAuth.User) -> Observable<(FirebaseAuth.User, AuthCredential?)> {
        let o1 = mutableAuthenticationSocialCredential.socialCredential
        let o2 = mutableAuthenticationSocialCredential.socialUser

        return Observable<(AuthCredential?, FirebaseAuth.User?)>.combineLatest(o1, o2, resultSelector: { (socialCredential, socialUser) -> (AuthCredential?, FirebaseAuth.User?) in
            if let provider = newUser.providerData.first(where: { $0.providerID == socialCredential?.provider }) {
                let account = provider.email ?? provider.displayName ?? ""
                throw AuthenticationError.invalidSocialAccount(accountName: account)
            }
            return (socialCredential, socialUser)
        })
        .take(1)
        .flatMap { (socialCredential, socialUser) -> Observable<(FirebaseAuth.User, AuthCredential?)> in
            guard let socialUser = socialUser else {
                return Observable.just((newUser, nil))
            }

            return Observable<(FirebaseAuth.User, AuthCredential?)>.create { s in
                socialUser.delete(completion: { (err) in
                    if let err = err {
                        s.onError(err)
                        return
                    }
                    s.onNext((newUser, socialCredential))
                    s.onCompleted()
                })
                return Disposables.create()
            }
        }
    }

    private func link(newUser: FirebaseAuth.User, with credential: AuthCredential?) -> Observable<FirebaseAuth.User> {
        guard let credential = credential else {
            return Observable<FirebaseAuth.User>.just(newUser)
        }

        return Observable<FirebaseAuth.User>.create { (s) in
            newUser.linkAndRetrieveData(with: credential, completion: { (_, err) in
                if let err = err {
                    s.onError(AuthenticationError.socialLinkFail(e: err))
                    return
                }

                s.onNext(newUser)
                s.onCompleted()
            })
            return Disposables.create()
        }
    }
}
