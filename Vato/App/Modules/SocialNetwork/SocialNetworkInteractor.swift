//  File name   : SocialNetworkInteractor.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import Firebase
import FBSDKLoginKit
import Alamofire
import GoogleSignIn
import FwiCoreRX

private enum SocialSignIn {
    case authenticationCompleted(vatoUser: Vato.User)
    case update(credential: AuthCredential, user: User)
}

protocol SocialNetworkRouting: ViewableRouting {
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol SocialNetworkPresentable: Presentable {
    var listener: SocialNetworkPresentableListener? { get set }

    // todo: Declare methods the interactor can invoke the presenter to present data.
}

protocol SocialNetworkListener: class {
    func completeAuthentication()
    func requestToChange(state: AuthenticationState)
}

final class SocialNetworkInteractor: PresentableInteractor<SocialNetworkPresentable> {
    weak var router: SocialNetworkRouting?
    weak var listener: SocialNetworkListener?

    // todo: Add additional dependencies to constructor. Do not perform any logic in constructor.
    init(presenter: SocialNetworkPresentable,
         mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream) {
        self.mutableAuthenticationSocialCredential = mutableAuthenticationSocialCredential
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // todo: Implement business logic here.
        facebookManager.logOut()
        GIDSignIn.sharedInstance()?.signOut()

        proxy.credentialPublisher.bind { [weak self] (credential) in
            self?.signIn(with: credential)
        }
        .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
        // todo: Pause any business logic.
    }

    /// Class's private properties.
    private let mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream

    private lazy var facebookManager: LoginManager = {
        let login = LoginManager()
//        login.loginBehavior = .browser
        return login
    }()

    private lazy var proxy = Proxy()
}

// MARK: Class's private methods
private extension SocialNetworkInteractor {
    private func signIn(with credential: AuthCredential) {
        authenticate(with: credential)
            .take(1)
            .trackProgressActivity(self.indicator)
            .bind { [weak self] (newUser) in
                self?.mutableAuthenticationSocialCredential.update(credential: credential, user: newUser)
            }
            .disposeOnDeactivate(interactor: self)
    }

    private func authenticate(with credential: AuthCredential) -> Observable<User> {
        return Observable<User>.create { s in
            Auth.auth().signIn(with: credential) { (result, err) in
                if let err = err {
                    s.onError(AuthenticationError.invalidVerificationCode(e: err))
                    return
                }

                guard let authData = result else {
                    s.onError(AuthenticationError.invalidFirebaseAuthenticatedData)
                    return
                }

                s.onNext(authData.user)
                s.onCompleted()
            }
            return Disposables.create()
        }
    }
}

// MARK: ActivityTrackingProtocol's members
extension SocialNetworkInteractor: ActivityTrackingProgressProtocol {
}

// MARK: SocialNetworkInteractable's members
extension SocialNetworkInteractor: SocialNetworkInteractable {
}

// MARK: SocialNetworkPresentableListener's members
extension SocialNetworkInteractor: SocialNetworkPresentableListener {
    var isLoading: Observable<(Bool, Double)> {
        return indicator.asObservable()
    }

    func handleFacebookAction() {
        guard let viewController = presenter as? UIViewController else {
            return
        }
        
        facebookManager.logIn(permissions: ["email"], from: viewController) { [weak self] (result, err) in
            guard
                err == nil,
                let currentToken = AccessToken.current
            else {
                return
            }
            let accessToken = currentToken.tokenString

            // Send credential request
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
            self?.signIn(with: credential)
        }
    }

    func handleGoogleAction() {
        let client = GIDSignIn.sharedInstance()
        client?.delegate = proxy
        client?.signIn()
    }
}

// MARK: GIDSignInDelegate's proxy
fileprivate class Proxy: NSObject, GIDSignInDelegate {
    fileprivate let credentialPublisher = PublishSubject<AuthCredential>()

    fileprivate func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        guard error == nil, let auth = user?.authentication else {
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        credentialPublisher.onNext(credential)
    }
}
