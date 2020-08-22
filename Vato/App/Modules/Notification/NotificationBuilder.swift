//  File name   : NotificationBuilder.swift
//
//  Author      : khoi tran
//  Created date: 1/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol NotificationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }

}

final class NotificationComponent: Component<NotificationDependency> {
    /// Class's public properties.
    let NotificationVC: NotificationVC
    
    /// Class's constructor.
    init(dependency: NotificationDependency, NotificationVC: NotificationVC) {
        self.NotificationVC = NotificationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol NotificationBuildable: Buildable {
    func build(withListener listener: NotificationListener) -> NotificationRouting
}

final class NotificationBuilder: Builder<NotificationDependency>, NotificationBuildable {
    /// Class's constructor.
    override init(dependency: NotificationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: NotificationBuildable's members
    func build(withListener listener: NotificationListener) -> NotificationRouting {
        let vc = NotificationVC(nibName: NotificationVC.identifier, bundle: nil)
        let component = NotificationComponent(dependency: dependency, NotificationVC: vc)

        let interactor = NotificationInteractor(presenter: component.NotificationVC, authenticated: component.dependency.authenticated)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return NotificationRouter(interactor: interactor, viewController: component.NotificationVC)
    }
}
