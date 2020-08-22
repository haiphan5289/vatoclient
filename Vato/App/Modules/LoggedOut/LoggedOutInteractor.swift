//  File name   : LoggedOutInteractor.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FirebaseAuth
import Alamofire
import VatoNetwork
import FwiCoreRX

private enum CreateProfileAction {
    case auto(vatoUser: Vato.User)
    case manual
}

protocol LoggedOutRouting: ViewableRouting, RibsAccessControllableProtocol {
    /// Route to phone authentication module.
    func routeToPhoneAuthentication()

    /// Route to social network module.
    func routeToSocialNetwork()
    
    func detachCurrentChild()
}

protocol LoggedOutPresentable: Presentable {
    var listener: LoggedOutPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol LoggedOutListener: class {
    func authenticatedWith(client: ClientProtocol, user: UserProtocol)
}

final class LoggedOutInteractor: PresentableInteractor<LoggedOutPresentable> {
    weak var router: LoggedOutRouting?
    weak var listener: LoggedOutListener?
    let component: LoggedOutComponent

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: LoggedOutPresentable,
         component: LoggedOutComponent) {
        self.mutableAuthentication = component.mutableAuthentication
        self.component = component
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
    }

    override func willResignActive() {
        super.willResignActive()
        router?.dismissCurrentRoute(completion: {
            printDebug("abc")
        })
    }
    deinit {
        printDebug("\(#function)")
    }

    /// Class's private properties.
    private let mutableAuthentication: MutableAuthenticationStream
//    private let hasNoProfilePublisher = PublishSubject<Void>()
    private let hasPhonePublisher = PublishSubject<Void>()
}

// MARK: LoggedOutInteractable's members
private extension LoggedOutInteractor {
    private func setupRX() {
        mutableAuthentication.authenticationState
            .distinctUntilChanged { $0 == $1 }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [weak self] (state) in
                    guard let wSelf = self else {
                        return
                    }

                    switch state {
                    case .initial:
//                        wSelf.router?.routeToSocialNetwork()
                        printDebug("Ignore this state.")
                        
                    case .none:
                        wSelf.router?.dismissCurrentRoute(completion: nil)

                    case .phoneAuthentication:
                        wSelf.router?.routeToPhoneAuthentication()
                    }
                },
                onError: { (err) in
                    printError(err: err)
                }
            )
            .disposeOnDeactivate(interactor: self)

        // Obtain user's firebase token whether user logged in using social account or logged in using
        // phone number
        Observable<User?>.combineLatest(mutableAuthentication.socialUser, mutableAuthentication.user) { (socialUser, user) -> User? in
            return user ?? socialUser
        }
        .filterNil()
        .debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.asyncInstance)
        .flatMap { [weak self] (user) -> Observable<(User, String)> in
            return self?.getToken(from: user) ?? Observable.empty()
        }
        .bind { [weak self] (user, token) in
            self?.mutableAuthentication.update(firebaseToken: token, for: user)
        }
        .disposeOnDeactivate(interactor: self)

        // Other process
        checkSocialAccountIfAssociateWithPhoneNumber()
        checkUserProfile()
//        createUserProfileIfNeeded()
    }

    /// Waiting for social user event to trigger checking event if user has phone number associated
    /// with or not.
    private func checkSocialAccountIfAssociateWithPhoneNumber() {
        let o1 = mutableAuthentication.socialUser.filterNil()
        let o2 = mutableAuthentication.firebaseToken
        Observable<(User, String)?>.combineLatest(o1, o2) { (user, firebaseToken) -> (User, String)? in
            guard user.uid == firebaseToken.0.uid else {
                return nil
            }
            return (user, firebaseToken.1)
        }
        .filterNil()
        .distinctUntilChanged { $0.0.uid == $1.0.uid }
        .flatMap { [weak self] (user, firebaseToken) -> Observable<(User, Bool)> in
            return self?.checkPhoneWithBackend(for: user, firebaseToken: firebaseToken) ?? Observable.empty()
        }
        .trackActivity(self.indicator)
        .subscribe(
            onNext: { [weak self] (newUser, hasPhone) in
                guard let wSelf = self else {
                    return
                }

                if hasPhone {
                    wSelf.mutableAuthentication.clearSocialData()
                    wSelf.mutableAuthentication.update(user: newUser)
                } else {
                    wSelf.mutableAuthentication.change(phoneInputState: PhoneInputState.input)
                    wSelf.mutableAuthentication.change(state: AuthenticationState.phoneAuthentication)
                }
            },
            onError: { (err) in
                printError(err: err)
            }
        )
        .disposeOnDeactivate(interactor: self)

        // If user logged in using phone number, we can skip the checking phone number with backend
        // step and move to check profile step
        mutableAuthentication.user
            .filterNil()
            .distinctUntilChanged { $0.uid == $1.uid }
            .bind { [weak self] (_) in
                self?.hasPhonePublisher.onNext(())
            }
            .disposeOnDeactivate(interactor: self)
    }

    /// Check new user if has profile or not regarding whether user had logged in with social network
    /// or logged in with phone number.
    private func checkUserProfile() {
        let o1 = hasPhonePublisher
        let o2 = mutableAuthentication.user.filterNil()
        let o3 = mutableAuthentication.firebaseToken

        Observable<(User, String)?>.combineLatest(o1, o2, o3) { (_, user, firebaseToken) -> (User, String)? in
            guard user.uid == firebaseToken.0.uid else {
                return nil
            }
            return (user, firebaseToken.1)
        }
        .filterNil()
        .flatMap { [weak self] (user, firebaseToken) -> Observable<OptionalMessageDTO<Vato>> in
            return self?.checkProfileWithBackend(for: user, firebaseToken: firebaseToken) ?? Observable.empty()
        }
        .trackActivity(self.indicator)
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(
            onNext: { [weak self] (message) in
                guard message.status == 200, let vatoUser = message.data?.user else {
                    self?.mutableAuthentication.change(phoneInputState: PhoneInputState.register)
//                    self?.hasNoProfilePublisher.onNext(())
                    return
                }
                self?.mutableAuthentication.update(user: vatoUser)
                
                self?.component.firebaseDatabase.updateFirebaseClient(for: vatoUser, with: vatoUser.firebaseID)
                self?.component.firebaseDatabase.updateFirebaseUser(for: vatoUser)
                
                self?.completeAuthentication()
            },
            onError: { (err) in
                printError(err: err)
            }
        )
        .disposeOnDeactivate(interactor: self)
    }

//    /// Present register form / Create new profile if needed.
//    private func createUserProfileIfNeeded() {
//        Observable<(User, PhoneInput, String)?>.combineLatest(hasNoProfilePublisher, mutableAuthentication.user.filterNil(), mutableAuthentication.phoneInput, mutableAuthentication.firebaseToken) { (_, user, phoneInput, firebaseToken) -> (User, PhoneInput, String)? in
//            guard user.uid == firebaseToken.0.uid else {
//                return nil
//            }
//            return (user, phoneInput, firebaseToken.1)
//        }
//        .filterNil()
//        .flatMap { [weak self] (user, phoneInput, firebaseToken) -> Observable<CreateProfileAction> in
//            if let providerData = user.providerData.first(where: { $0.providerID == FacebookAuthProviderID || $0.providerID == GoogleAuthProviderID }) {
//                return self?.autoCreateProfile(for: user, providerData: providerData, phoneInput: phoneInput, firebaseToken: firebaseToken) ?? Observable.empty()
//            } else {
//                return Observable.just(.manual)
//            }
//        }
//        .bind { [weak self] (action) in
//            switch action {
//            case .auto(let vatoUser):
//                self?.mutableAuthentication.update(user: vatoUser)
//                self?.completeAuthentication()
//
//            case .manual:
//                self?.mutableAuthentication.change(phoneInputState: PhoneInputState.register)
//            }
//        }
//        .disposeOnDeactivate(interactor: self)
//    }

    private func getToken(from newUser: User) -> Observable<(User, String)> {
        return Observable<(User, String)>.create { s in
            newUser.getIDToken { (token, err) in
                if let err = err {
                    s.onError(AuthenticationError.tokenFail(error: err))
                    return
                }

                guard let t = token, t.isEmpty == false else {
                    s.onError(AuthenticationError.tokenEmpty(s: token))
                    return
                }

                s.onNext((newUser, t))
                s.onCompleted()
            }
            return Disposables.create()
        }
    }

//    private func autoCreateProfile(for newUser: User, providerData: UserInfo, phoneInput: PhoneInput, firebaseToken: String) -> Observable<CreateProfileAction> {
//        let api = VatoAPIRouter.createAccount(authToken: firebaseToken,
//                                              firebaseID: newUser.uid,
//                                              phoneNumber: phoneInput.phoneNumber,
//                                              deviceToken: nil,
//                                              fullName: providerData.displayName,
//                                              nickname: providerData.displayName,
//                                              email: providerData.email,
//                                              birthday: nil,
//                                              zoneID: nil,
//                                              avatarURL: nil)
//
//        let o: Observable<(HTTPURLResponse, MessageDTO<Vato.User>)> = Requester.requestDTO(using: api,
//                                                                                           method: .post,
//                                                                                           encoding: JSONEncoding.default,
//                                                                                           block: { $0.dateDecodingStrategy = .customDateFireBase })
//        return o.map { $0.1.data }.map { CreateProfileAction.auto(vatoUser: $0) }
//    }

    private func checkPhoneWithBackend(for newUser: User, firebaseToken: String) -> Observable<(User, Bool)> {
        guard
            newUser.providerData.first(where: { $0.providerID == PhoneAuthProviderID }) != nil,
            var phoneNumber = newUser.phoneNumber, phoneNumber.count > 0
        else {
            return Observable.just((newUser, false))
        }

        // Convert from international format to local format
        if phoneNumber.hasPrefix("+84") {
            phoneNumber = phoneNumber.replacingOccurrences(of: "+84", with: "0")
        }

        let o: Observable<(HTTPURLResponse, OptionalMessageDTO<Vato>)> =  Requester.requestDTO(using: VatoAPIRouter.checkPhone(authToken: firebaseToken, firebaseID: newUser.uid, phoneNumber: phoneNumber),
                                                                                               method: .post,
                                                                                               encoding: JSONEncoding.default,
                                                                                               block: { $0.dateDecodingStrategy = .customDateFireBase })

        return o.map { $0.1 }.map { (newUser, $0.status == 200) }
    }

    private func checkProfileWithBackend(for newUser: User, firebaseToken: String) -> Observable<OptionalMessageDTO<Vato>> {
        let o: Observable<(HTTPURLResponse, OptionalMessageDTO<Vato>)> = Requester.requestDTO(using: VatoAPIRouter.checkAccount(authToken: firebaseToken, firebaseID: newUser.uid),
                                                                                              method: .post,
                                                                                              encoding: JSONEncoding.default,
                                                                                              block: { $0.dateDecodingStrategy = .customDateFireBase })
        return o.map { $0.1 }
    }
}

// MARK: LoggedOutInteractable's members
extension LoggedOutInteractor: LoggedOutInteractable {
    func completeAuthentication() {
        mutableAuthentication.vatoUser.take(1)
            .filterNil()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (vatoUser) in
                self?.router?.dismissCurrentRoute(completion: {
                    self?.listener?.authenticatedWith(client: vatoUser, user: vatoUser)
                })
                
//                self?.router?.detachCurrentChild()
//                self?.listener?.authenticatedWith(client: vatoUser, user: vatoUser)
            })
            .disposeOnDeactivate(interactor: self)
    }

    func dismissPhoneAuthentication() {
        mutableAuthentication.change(state: .none)
    }

    func requestToChange(state: AuthenticationState) {
        mutableAuthentication.change(state: state)
    }
}

// MARK: LoggedOutPresentableListener's members
extension LoggedOutInteractor: LoggedOutPresentableListener {
    func attachSocialNetworkAction() {
        router?.routeToSocialNetwork()
    }

    func handlePhoneAuthenticationAction() {
        mutableAuthentication.change(state: .phoneAuthentication)
    }
}

// MARK: ActivityTrackingProtocol's members
extension LoggedOutInteractor: ActivityTrackingProtocol {
}
