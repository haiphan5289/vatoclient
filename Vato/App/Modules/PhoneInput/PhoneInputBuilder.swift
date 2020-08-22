//  File name   : PhoneInputBuilder.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka

// MARK: Dependency tree
protocol PhoneInputDependency: Dependency {
    var phoneInputVC: PhoneInputViewControllable { get }
    var form: Form { get }

    var mutableAuthenticationPhone: MutableAuthenticationPhoneStream { get }
    var mutableAuthenticationVerificationCode: MutableAuthenticationVerificationCodeStream { get }
}

final class PhoneInputComponent: Component<PhoneInputDependency> {
    /// Class's private properties.
    fileprivate var phoneInputVC: PhoneInputViewControllable {
        return dependency.phoneInputVC
    }
    fileprivate var form: Form {
        return dependency.form
    }

    fileprivate var mutableAuthenticationPhone: MutableAuthenticationPhoneStream {
        return dependency.mutableAuthenticationPhone
    }

    fileprivate var mutableAuthenticationVerificationCode: MutableAuthenticationVerificationCodeStream {
        return dependency.mutableAuthenticationVerificationCode
    }
}

// MARK: Builder
protocol PhoneInputBuildable: Buildable {
    func build(withListener listener: PhoneInputListener) -> PhoneInputRouting
}

final class PhoneInputBuilder: Builder<PhoneInputDependency>, PhoneInputBuildable {
    /// Class's constructor.
    override init(dependency: PhoneInputDependency) {
        super.init(dependency: dependency)
    }

    // MARK: RootBuildable's members
    func build(withListener listener: PhoneInputListener) -> PhoneInputRouting {
        let component = PhoneInputComponent(dependency: dependency)
        
        let interactor = PhoneInputInteractor(mutableAuthenticationPhone: component.mutableAuthenticationPhone,
                                              mutableAuthenticationVerificationCode: component.mutableAuthenticationVerificationCode)
        interactor.listener = listener
        
        // todo: Create builder modules builders and inject into router here.
        
        return PhoneInputRouter(interactor: interactor,
                                viewController: component.phoneInputVC,
                                form: component.form)
    }
}
