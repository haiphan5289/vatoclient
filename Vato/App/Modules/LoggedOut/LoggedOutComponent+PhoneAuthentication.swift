//  File name   : LoggedOutComponent+PhoneAuthentication.swift
//
//  Author      : Vato
//  Created date: 9/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import FirebaseDatabase

protocol LoggedOutDependencyPhoneAuthentication: Dependency {
    var referralCode: Observable<URLComponents> { get }
    var firebaseDatabase: DatabaseReference { get }
}

extension LoggedOutComponent: PhoneAuthenticationDependency {
    var referralCode: Observable<URLComponents> {
        return dependency.referralCode
    }

    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }

    var mutableAuthenticationPhoneInputState: MutableAuthenticationPhoneInputStateStream {
        return mutableAuthentication
    }

    var mutableAuthenticationPhone: MutableAuthenticationPhoneStream {
        return mutableAuthentication
    }

    var mutableAuthenticationVerificationCode: MutableAuthenticationVerificationCodeStream {
        return mutableAuthentication
    }

    var mutableAuthenticationUser: MutableAuthenticationUserStream {
        return mutableAuthentication
    }

    var mutableAuthenticationVatoUser: MutableAuthenticationVatoUserStream {
        return mutableAuthentication
    }
}
