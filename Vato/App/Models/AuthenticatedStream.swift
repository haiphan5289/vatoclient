//  File name   : AuthenticatedStream.swift
//
//  Author      : Vato
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

// MARK: Immutable stream
protocol AuthenticatedStream: class {
    var googleAPI: Observable<String> { get }
    var firebaseAuthToken: Observable<String> { get }
}

// MARK: Mutable stream
protocol MutableAuthenticatedStream: AuthenticatedStream {
    func update(googleAPI key: String)
    func update(firebaseAuthToken token: String)
}

// MARK: Default stream implementation
final class AuthenticatedStreamImpl: MutableAuthenticatedStream {
    /// Class's public properties.
    var googleAPI: Observable<String> {
        return googleAPISubject.asObservable()
    }

    var firebaseAuthToken: Observable<String> {
        return firebaseAuthTokenSubject
            .asObservable()
            .distinctUntilChanged { $0 == $1 }
    }

    func update(googleAPI key: String) {
        guard key.count > 0 else {
            return
        }
        googleAPISubject.on(.next(key))
    }

    func update(firebaseAuthToken token: String) {
        guard token.count > 0 else {
            return
        }

        firebaseAuthTokenSubject.on(.next(token))
    }

    /// Class's private properties.
    private let googleAPISubject = ReplaySubject<String>.create(bufferSize: 1)
    private let firebaseAuthTokenSubject = ReplaySubject<String>.create(bufferSize: 1)
}
