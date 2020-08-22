//
//  ProfileStream.swift
//  FaceCar
//
//  Created by tony on 10/1/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Firebase
import Foundation
import RxSwift
import FirebaseAuth

// MARK: Immutable stream
protocol ProfileStream: class {
    var client: Observable<Client> { get }
    var user: Observable<UserInfo> { get }
    func updateClient(client: Client)
}

// MARK: Mutable stream
protocol MutableProfileStream: ProfileStream {
    func updateUserInfo(user: UserInfo?)
}

// MARK: Default stream implementation
final class ProfileStreamImpl: MutableProfileStream {
    /// Class's public properties.
    var client: Observable<Client> {
        return clientSubject.asObservable()
    }

    var user: Observable<UserInfo> {
        return userSubject.asObserver()
    }

    func updateClient(client: Client) {
        assert(client.user?.id != nil)
        clientSubject.on(.next(client))
    }

    func updateUserInfo(user: UserInfo?) {
        guard var user = user, user.id != 0 else {
            return
        }
        defer {
             // Cache
            UserManager.instance.cache(info: user)
        }
        if (user.email == nil) || (user.email?.isEmpty == true) {
            user.update(email: Auth.auth().currentUser?.email)
        }

        userSubject.on(.next(user))
    }

    /// Class's private properties.
    private let clientSubject = ReplaySubject<Client>.create(bufferSize: 1)
    private let userSubject = ReplaySubject<UserInfo>.create(bufferSize: 1)
}
