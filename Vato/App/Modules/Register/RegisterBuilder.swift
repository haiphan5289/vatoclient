//  File name   : RegisterBuilder.swift
//
//  Author      : Vato
//  Created date: 11/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Eureka
import RxSwift

// MARK: Dependency tree
protocol RegisterDependency: Dependency {
    var registerVC: RegisterViewControllable { get }
    var form: Form { get }

    var referralCode: Observable<URLComponents> { get }
    var mutableAuthenticationVatoUser: MutableAuthenticationVatoUserStream { get }
}

final class RegisterComponent: Component<RegisterDependency> {
    /// Class's private properties.
    fileprivate var registerVC: RegisterViewControllable {
        return dependency.registerVC
    }
    fileprivate var form: Form {
        return dependency.form
    }

    fileprivate var referralCode: Observable<URLComponents> {
        return dependency.referralCode
    }
    fileprivate var mutableAuthenticationVatoUser: MutableAuthenticationVatoUserStream {
        return dependency.mutableAuthenticationVatoUser
    }
}

// MARK: Builder
protocol RegisterBuildable: Buildable {
    func build(withListener listener: RegisterListener) -> RegisterRouting
}

final class RegisterBuilder: Builder<RegisterDependency>, RegisterBuildable {
    /// Class's constructor.
    override init(dependency: RegisterDependency) {
        super.init(dependency: dependency)
    }

    // MARK: RootBuildable's members
    func build(withListener listener: RegisterListener) -> RegisterRouting {
        let component = RegisterComponent(dependency: dependency)
        
        let interactor = RegisterInteractor(mutableAuthenticationVatoUser: component.mutableAuthenticationVatoUser)
        interactor.listener = listener
        
        // todo: Create builder modules builders and inject into router here.
        
        return RegisterRouter(interactor: interactor,
                              viewController: component.registerVC,
                              form: component.form,
                              referralCode: dependency.referralCode)
    }
}
