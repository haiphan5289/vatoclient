//  File name   : LoggedOutBuilder.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

// MARK: Dependency
protocol LoggedOutDependency: LoggedOutDependencyPhoneAuthentication {
}

final class LoggedOutComponent: Component<LoggedOutDependency> {
    var mutableAuthentication: MutableAuthenticationStream {
        return shared { AuthenticationStreamImpl() }
    }
}

// MARK: Builder
protocol LoggedOutBuildable: Buildable {
    func build(withListener listener: LoggedOutListener) -> LoggedOutRouting
}

final class LoggedOutBuilder: Builder<LoggedOutDependency>, LoggedOutBuildable {
    override init(dependency: LoggedOutDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: LoggedOutListener) -> LoggedOutRouting {
        let viewController = LoggedOutVC(nibName: LoggedOutVC.identifier, bundle: nil)
        let component = LoggedOutComponent(dependency: dependency)

        let interactor = LoggedOutInteractor(presenter: viewController,
                                             component: component)
        interactor.listener = listener

        let phoneAuthenticationBuilder = PhoneAuthenticationBuilder(dependency: component)
        let socialNetworkBuilder = SocialNetworkBuilder(dependency: component)

        return LoggedOutRouter(interactor: interactor,
                               viewController: viewController,
                               phoneAuthenticationBuilder: phoneAuthenticationBuilder,
                               socialNetworkBuilder: socialNetworkBuilder)
    }
}
