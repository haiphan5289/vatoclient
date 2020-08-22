//  File name   : PhoneAuthenticationBuilder.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka

// MARK: Dependency
protocol PhoneAuthenticationDependency: PhoneAuthenticationDependencyPhoneInput, PhoneAuthenticationDependencyPhoneVerification, PhoneAuthenticationDependencyRegister {
    var mutableAuthenticationPhoneInputState: MutableAuthenticationPhoneInputStateStream { get }
}

final class PhoneAuthenticationComponent: Component<PhoneAuthenticationDependency> {
    /// Class's public properties.
    var form: Form {
        return phoneAuthenticationVC.form
    }

    let phoneAuthenticationVC: PhoneAuthenticationVC

    /// Class's constructors.
    init(dependency: PhoneAuthenticationDependency, with phoneAuthenticationVC: PhoneAuthenticationVC) {
        self.phoneAuthenticationVC = phoneAuthenticationVC
        super.init(dependency: dependency)
    }

    /// Class's private properties.
    fileprivate var mutableAuthenticationPhoneInputState: MutableAuthenticationPhoneInputStateStream {
        return dependency.mutableAuthenticationPhoneInputState
    }
}

// MARK: Builder
protocol PhoneAuthenticationBuildable: Buildable {
    func build(withListener listener: PhoneAuthenticationListener) -> PhoneAuthenticationRouting
}

final class PhoneAuthenticationBuilder: Builder<PhoneAuthenticationDependency>, PhoneAuthenticationBuildable {
    override init(dependency: PhoneAuthenticationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PhoneAuthenticationListener) -> PhoneAuthenticationRouting {
        let viewController = PhoneAuthenticationVC()
        let component = PhoneAuthenticationComponent(dependency: dependency,
                                                     with: viewController)

        let interactor = PhoneAuthenticationInteractor(presenter: viewController,
                                                       mutableAuthenticationPhoneInputState: component.mutableAuthenticationPhoneInputState)
        interactor.listener = listener

        let phoneInputBuilder = PhoneInputBuilder(dependency: component)
        let phoneVerificationBuilder = PhoneVerificationBuilder(dependency: component)
        let registerBuilder = RegisterBuilder(dependency: component)

        return PhoneAuthenticationRouter(interactor: interactor,
                                         viewController: viewController,
                                         phoneInputBuilder: phoneInputBuilder,
                                         phoneVerificationBuilder: phoneVerificationBuilder,
                                         registerBuilder: registerBuilder)
    }
}
