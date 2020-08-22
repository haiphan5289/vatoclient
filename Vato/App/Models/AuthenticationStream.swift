//  File name   : AuthenticationStream.swift
//
//  Author      : Vato
//  Created date: 10/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import Firebase

enum AuthenticationState: Int {
    case initial
    case none
//    case socialNetwork
    case phoneAuthentication
}

enum PhoneInputState: UInt8 {
    case input = 0
    case verify = 1
    case register = 2
}

struct PhoneInput {
    var dialCode = "+84"
    var phoneNumber = ""
    var verificationID = ""
}

// MARK: Immutable stream
protocol AuthenticationStream: class {
    var authenticationState: Observable<AuthenticationState> { get }
    var phoneInputState: Observable<PhoneInputState> { get }

    var socialCredential: Observable<AuthCredential?> { get }
    var socialUser: Observable<User?> { get }

    var phoneInput: Observable<PhoneInput> { get }
    var user: Observable<User?> { get }

    var firebaseToken: Observable<(User, String)> { get }
    var vatoUser: Observable<Vato.User?> { get }
}

// MARK: Mutable stream
protocol MutableAuthenticationStateStream: AuthenticationStream {
    func change(state: AuthenticationState)
}

protocol MutableAuthenticationPhoneInputStateStream: AuthenticationStream {
    func change(phoneInputState: PhoneInputState)
}

protocol MutableAuthenticationSocialCredentialStream: AuthenticationStream {
    func update(credential: AuthCredential, user: User)
    func clearSocialData()
}

protocol MutableAuthenticationPhoneStream: AuthenticationStream {
    func update(phoneNumber: String)
}

protocol MutableAuthenticationVerificationCodeStream: AuthenticationStream {
    func update(verificationID: String)
}

protocol MutableAuthenticationUserStream: AuthenticationStream {
    func update(user: User)
    func update(firebaseToken: String, for user: User)
}

protocol MutableAuthenticationVatoUserStream: AuthenticationStream {
    func update(user: Vato.User)
}

protocol MutableAuthenticationStream: MutableAuthenticationStateStream, MutableAuthenticationSocialCredentialStream, MutableAuthenticationPhoneInputStateStream, MutableAuthenticationPhoneStream, MutableAuthenticationVerificationCodeStream, MutableAuthenticationUserStream, MutableAuthenticationVatoUserStream {
}

// MARK: Default stream implementation
final class AuthenticationStreamImpl: MutableAuthenticationStream {
    /// Class's public properties.
    var authenticationState: Observable<AuthenticationState> {
        return authenticationStateSubject.asObservable()
    }
    var phoneInputState: Observable<PhoneInputState> {
        return phoneInputStateSubject.asObservable()
    }

    var socialCredential: Observable<AuthCredential?> {
        return socialCredentialSubject.asObservable()
    }
    var socialUser: Observable<User?> {
        return socialUserSubject.asObservable()
    }

    var phoneInput: Observable<PhoneInput> {
        return phoneInputSubject.asObservable()
    }
    var user: Observable<User?> {
        return userSubject.asObservable()
    }

    var firebaseToken: Observable<(User, String)> {
        return firebaseTokenSubject.asObservable()
    }
    var vatoUser: Observable<Vato.User?> {
        return vatoUserSubject.asObservable()
    }

    /// Class's constructors.
    init() {
        authenticationStateSubject.onNext(.initial)
        phoneInputStateSubject.onNext(.input)

        socialCredentialSubject.onNext(nil)
        socialUserSubject.onNext(nil)

        phoneInputSubject.onNext(PhoneInput())
        userSubject.onNext(nil)

        vatoUserSubject.onNext(nil)
    }

    func change(state: AuthenticationState) {
        authenticationStateSubject.onNext(state)

//        switch state {
//        case .none:
//            phoneInputSubject.onNext(PhoneInput())
//        default:
//            break
//        }
    }
    func change(phoneInputState: PhoneInputState) {
        phoneInputStateSubject.onNext(phoneInputState)
    }

    func update(credential: AuthCredential, user: User) {
        socialCredentialSubject.onNext(credential)
        socialUserSubject.onNext(user)
    }
    func clearSocialData() {
        socialCredentialSubject.onNext(nil)
        socialUserSubject.onNext(nil)
    }

    func update(phoneNumber: String) {
        guard phoneNumber.count > 0 else {
            return
        }

        _ = phoneInputSubject.take(1).bind { [weak self] (phoneInput) in
            let newInput = PhoneInput(dialCode: phoneInput.dialCode,
                                      phoneNumber: phoneNumber,
                                      verificationID: phoneInput.verificationID)
            self?.phoneInputSubject.onNext(newInput)
        }
    }

    func update(verificationID: String) {
        guard verificationID.count > 0 else {
            return
        }

        _ = phoneInputSubject.take(1).bind { [weak self] (phoneInput) in
            let newInput = PhoneInput(dialCode: phoneInput.dialCode,
                                      phoneNumber: phoneInput.phoneNumber,
                                      verificationID: verificationID)
            self?.phoneInputSubject.onNext(newInput)
        }
    }

    func update(user: User) {
        userSubject.onNext(user)
    }
    func update(firebaseToken: String, for user: User) {
        firebaseTokenSubject.onNext((user, firebaseToken))
    }

    func update(user: Vato.User) {
        vatoUserSubject.onNext(user)
    }

    /// Class's private properties.
    private let authenticationStateSubject = ReplaySubject<AuthenticationState>.create(bufferSize: 1)
    private let phoneInputStateSubject = ReplaySubject<PhoneInputState>.create(bufferSize: 1)

    private let socialCredentialSubject = ReplaySubject<AuthCredential?>.create(bufferSize: 1)
    private let socialUserSubject = ReplaySubject<User?>.create(bufferSize: 1)

    private let phoneInputSubject = ReplaySubject<PhoneInput>.create(bufferSize: 1)
    private let userSubject = ReplaySubject<User?>.create(bufferSize: 1)

    private let firebaseTokenSubject = ReplaySubject<(User, String)>.create(bufferSize: 1)
    private let vatoUserSubject = ReplaySubject<Vato.User?>.create(bufferSize: 1)
}
