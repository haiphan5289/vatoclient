//  File name   : RegisterInteractor.swift
//
//  Author      : Vato
//  Created date: 11/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Alamofire
import FirebaseAuth
import RxSwift
import VatoNetwork
import Firebase
import FwiCoreRX

protocol RegisterRouting: Routing {
    func cleanupViews()
    
    // todo: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol RegisterListener: class {
    func completeAuthentication()
    func requestToChange(state: PhoneInputState)
}

final class RegisterInteractor: Interactor {
    /// Class's public properties.
    weak var router: RegisterRouting?
    weak var listener: RegisterListener?

    var isLoading: Observable<Bool> {
        return indicator.asObservable()
    }

    /// Class's constructor.
    init(mutableAuthenticationVatoUser: MutableAuthenticationVatoUserStream) {
        self.mutableAuthenticationVatoUser = mutableAuthenticationVatoUser
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
    private let mutableAuthenticationVatoUser: MutableAuthenticationVatoUserStream
    private lazy var indicator = ActivityIndicator()

    private lazy var firebaseDatabase = Database.database().reference()                             // Going to be deleted.
}

// MARK: RegisterInteractor's members
extension RegisterInteractor: RegisterInteractable {
    func execute(input: [String : Any?]) {
        guard
            let fullname = input[Text.fullname.text] as? String,
            let email = input[Text.email.text] as? String,
            let newUser = Auth.auth().currentUser
        else {
            return
        }
        let nickname = input[Text.nickname.text] as? String ?? ""
        let referralCode = input[Text.referralCode.text] as? String

        // Merge events
        let o1 = mutableAuthenticationVatoUser.phoneInput.take(1)
        let o2 = mutableAuthenticationVatoUser.firebaseToken.take(1)

        // Send request
        Observable<(PhoneInput, String)>.combineLatest(o1, o2, resultSelector: { ($0, $1.1) })
            .flatMap { (phoneInput, token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<Vato.User>)> in
                let api = VatoAPIRouter.createAccount(authToken: token,
                                                      firebaseID: newUser.uid,
                                                      phoneNumber: phoneInput.phoneNumber,
                                                      deviceToken: nil,
                                                      fullName: fullname,
                                                      nickname: nickname,
                                                      email: email,
                                                      birthday: nil,
                                                      zoneID: nil,
                                                      avatarURL: nil,
                                                      referralCode: referralCode)

                return Requester.requestDTO(using: api, method: .post, encoding: JSONEncoding.default, block: { $0.dateDecodingStrategy = .customDateFireBase })
            }
            .take(1)
            .map { $0.1 }
            .trackActivity(indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (message) in
                printDebug(message.errorCode ?? "")
                if let vatoUser = message.data {
                    self?.mutableAuthenticationVatoUser.update(user: vatoUser)

                    // Save firebase
                    self?.updateFirebaseClient(for: vatoUser, with: vatoUser.firebaseID)
                    self?.updateFirebaseUser(for: vatoUser)
                    
                    self?.listener?.completeAuthentication()
                }
            })
            .disposeOnDeactivate(interactor: self)
    }
    
    func cancelForm() {
    }

    func validate(referralCode: String, completion: @escaping (Bool, Error?) -> Void) {
        guard referralCode.count > 0 else {
            return
        }

        mutableAuthenticationVatoUser.firebaseToken.map { $0.1 }.take(1)
            .flatMap { (token) -> Observable<(HTTPURLResponse, OptionalMessageDTO<[String:Bool]>)> in
                let api = VatoAPIRouter.checkReferralCode(authToken: token, referralCode: referralCode)
                return Requester.requestDTO(using: api, method: .post, encoding: JSONEncoding.default, block: nil)
            }
            .take(1)
            .map { $0.1.data }
            .trackActivity(indicator)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(
                onNext: { (message) in
                    if let valid = message?["valid"], valid {
                        completion(valid, nil)
                    } else {
                        let err = NSError(domain: "vn.vato.client", code: -1, userInfo: [NSLocalizedDescriptionKey:Text.invalidReferralCode.localizedText])
                        completion(false, err)
                    }
                },
                onError: { (err) in
                    completion(false, err)
                }
            )
            .disposeOnDeactivate(interactor: self)
    }
}

// MARK: Class's private methods
private extension RegisterInteractor {
    private func setupRX() {
        // todo: Bind data stream here.
    }

    private func updateFirebaseClient(for client: ClientProtocol, with firebaseID: String) {        // Going to be deleted
        let node = FireBaseTable.client >>> .custom(identify: firebaseID)
        firebaseDatabase.child(node.path).updateChildValues(client.updateFirebaseClient) { (err, _) in
            guard let err = err else {
                return
            }
            printError(err: err)
        }
    }

    private func updateFirebaseUser(for user: UserProtocol) {                                       // Going to be deleted
        let node = FireBaseTable.user >>> .custom(identify: user.firebaseID)
        firebaseDatabase.child(node.path).updateChildValues(user.updateFirebaseUser) { (err, _) in
            guard let err = err else {
                return
            }
            printError(err: err)
        }
    }
}
