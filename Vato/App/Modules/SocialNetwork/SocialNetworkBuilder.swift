//  File name   : SocialNetworkBuilder.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol SocialNetworkDependency: Dependency {
    var mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream { get }
}

final class SocialNetworkComponent: Component<SocialNetworkDependency> {
    fileprivate var mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream {
        return dependency.mutableAuthenticationSocialCredential
    }
}

// MARK: Builder
protocol SocialNetworkBuildable: Buildable {
    func build(withListener listener: SocialNetworkListener) -> SocialNetworkRouting
}

final class SocialNetworkBuilder: Builder<SocialNetworkDependency>, SocialNetworkBuildable {
    override init(dependency: SocialNetworkDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SocialNetworkListener) -> SocialNetworkRouting {
        let viewController = SocialNetworkVC(nibName: SocialNetworkVC.identifier, bundle: nil)
        let component = SocialNetworkComponent(dependency: dependency)

        let interactor = SocialNetworkInteractor(presenter: viewController,
                                                 mutableAuthenticationSocialCredential: component.mutableAuthenticationSocialCredential)
        interactor.listener = listener

        return SocialNetworkRouter(interactor: interactor, viewController: viewController)
    }
}
