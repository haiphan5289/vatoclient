//  File name   : PhoneAuthenticationComponent+PhoneVerification.swift
//
//  Author      : Vato
//  Created date: 9/7/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FirebaseDatabase

/// The dependencies needed from the parent scope of PhoneAuthentication to provide for the PhoneVerification scope.
// todo: Update PhoneAuthenticationDependency protocol to inherit this protocol.
protocol PhoneAuthenticationDependencyPhoneVerification: Dependency {
    var mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream { get }
    var mutableAuthenticationUser: MutableAuthenticationUserStream { get }
}

extension PhoneAuthenticationComponent: PhoneVerificationDependency {
    var phoneVerificationVC: PhoneVerificationViewControllable {
        return phoneAuthenticationVC
    }

    var mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream {
        return dependency.mutableAuthenticationSocialCredential
    }

    var mutableAuthenticationUser: MutableAuthenticationUserStream {
        return dependency.mutableAuthenticationUser
    }
}
