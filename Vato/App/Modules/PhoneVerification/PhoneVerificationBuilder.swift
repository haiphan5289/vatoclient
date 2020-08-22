//  File name   : PhoneVerificationBuilder.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka
import FirebaseDatabase

// MARK: Dependency tree
protocol PhoneVerificationDependency: Dependency {
    var phoneVerificationVC: PhoneVerificationViewControllable { get }
    var form: Form { get }

    var mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream { get }
    var mutableAuthenticationUser: MutableAuthenticationUserStream { get }
}

final class PhoneVerificationComponent: Component<PhoneVerificationDependency> {
    /// Class's private properties.
    fileprivate var phoneVerificationVC: PhoneVerificationViewControllable {
        return dependency.phoneVerificationVC
    }
    fileprivate var form: Form {
        return dependency.form
    }

    fileprivate var mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream {
        return dependency.mutableAuthenticationSocialCredential
    }
    fileprivate var mutableAuthenticationUser: MutableAuthenticationUserStream {
        return dependency.mutableAuthenticationUser
    }
}

// MARK: Builder
protocol PhoneVerificationBuildable: Buildable {
    func build(withListener listener: PhoneVerificationListener) -> PhoneVerificationRouting
}

final class PhoneVerificationBuilder: Builder<PhoneVerificationDependency>, PhoneVerificationBuildable {
    /// Class's constructor.
    override init(dependency: PhoneVerificationDependency) {
        super.init(dependency: dependency)
    }

    // MARK: RootBuildable's members
    func build(withListener listener: PhoneVerificationListener) -> PhoneVerificationRouting {
        let component = PhoneVerificationComponent(dependency: dependency)
        
        let interactor = PhoneVerificationInteractor(mutableAuthenticationSocialCredential: component.mutableAuthenticationSocialCredential,
                                                     mutableAuthenticationUser: component.mutableAuthenticationUser)

        interactor.listener = listener
        
        // todo: Create builder modules builders and inject into router here.
        
        return PhoneVerificationRouter(interactor: interactor,
                                       viewController: component.phoneVerificationVC,
                                       form: component.form)
    }
}
