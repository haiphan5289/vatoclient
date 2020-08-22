//  File name   : PhoneAuthenticationComponent+Register.swift
//
//  Author      : Vato
//  Created date: 11/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

/// The dependencies needed from the parent scope of PhoneAuthentication to provide for the Register scope.
// todo: Update PhoneAuthenticationDependency protocol to inherit this protocol.
protocol PhoneAuthenticationDependencyRegister: Dependency {
    var referralCode: Observable<URLComponents> { get }
    var mutableAuthenticationVatoUser: MutableAuthenticationVatoUserStream { get }
}

extension PhoneAuthenticationComponent: RegisterDependency {
    var registerVC: RegisterViewControllable {
        return phoneAuthenticationVC
    }

    var referralCode: Observable<URLComponents> {
        return dependency.referralCode
    }

    var mutableAuthenticationVatoUser: MutableAuthenticationVatoUserStream {
        return dependency.mutableAuthenticationVatoUser
    }
}
