//  File name   : PhoneAuthenticationComponent+PhoneInput.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of PhoneAuthentication to provide for the PhoneInput scope.
// todo: Update PhoneAuthenticationDependency protocol to inherit this protocol.
protocol PhoneAuthenticationDependencyPhoneInput: Dependency {
    var mutableAuthenticationPhone: MutableAuthenticationPhoneStream { get }
    var mutableAuthenticationVerificationCode: MutableAuthenticationVerificationCodeStream { get }
}

extension PhoneAuthenticationComponent: PhoneInputDependency {
    var phoneInputVC: PhoneInputViewControllable {
        return phoneAuthenticationVC
    }

    var mutableAuthenticationPhone: MutableAuthenticationPhoneStream {
        return dependency.mutableAuthenticationPhone
    }
    
    var mutableAuthenticationVerificationCode: MutableAuthenticationVerificationCodeStream {
        return dependency.mutableAuthenticationVerificationCode
    }
}
