//  File name   : RoutableProtocol.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 10/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Aversafe. All rights reserved.
//  --------------------------------------------------------------

#if canImport(RIBs)
    import RIBs
    import UIKit

    protocol RoutableProtocol: class, RibsAccessControllableProtocol {
        var currentChild: Routing? { get set }
        var currentRoute: ViewableRouting? { get set }
    }

    extension RoutableProtocol where Self: Routing {
        /// Attach new child. Current child and current route will be detach automatically.
        ///
        /// - Parameter newChild: new child
        func attach(newChild: Routing) {
            defer { currentChild = newChild }
            detachCurrentChild()
//            detachCurrentRoute()
            attachChild(newChild)
        }

        /// Attach new route. Current child and current route will be detach automatically.
        ///
        /// - Parameters:
        ///   - newRoute: new route
        ///   - transition: transition type
        ///   - block: a call back action
        func attach(newRoute: ViewableRouting, transitionType: TransitonType, completion: (() -> Void)? = nil) {
            defer { currentRoute = newRoute }
//            detachCurrentChild()
            detachCurrentRoute()
            attachChild(newRoute)

            guard let viewController = viewControllable as? ControllableProtocol else {
                fatalError("\(type(of: viewControllable)) does not conform ControllableProtocol.")
            }
            viewController.present(viewController: newRoute.viewControllable,
                                   transitionType: transitionType,
                                   completion: completion)
        }

        func attachNavigationController(newRoute: ViewableRouting, transitionType: TransitonType, completion: (() -> Void)? = nil) -> UINavigationController {
            defer { currentRoute = newRoute }
//            detachCurrentChild()
            detachCurrentRoute()
            attachChild(newRoute)

            guard let viewController = viewControllable as? ControllableProtocol else {
                fatalError("\(type(of: viewControllable)) does not conform ControllableProtocol.")
            }
            return viewController.presentNavigationController(for: newRoute.viewControllable,
                                                              transitionType: transitionType,
                                                              completion: completion)
        }

        func replace(newRoute: ViewableRouting) {
            guard let current = currentRoute else {
                return
            }
//            detachCurrentChild()
            detachCurrentRoute()

            defer { currentRoute = newRoute }
            attachChild(newRoute)

            viewControllable.uiviewController.transition(from: current.viewControllable.uiviewController,
                                                         to: newRoute.viewControllable.uiviewController,
                                                         duration: 0.5,
                                                         options: UIView.AnimationOptions.curveEaseInOut,
                                                         animations: nil, completion: nil)
        }

        /// Detach current child.
        func detachCurrentChild() {
            guard let currentChild = currentChild else {
                return
            }
            detachChild(currentChild)
        }

        /// Detach current route.
        func detachCurrentRoute() {
            guard let currentRoute = currentRoute else {
                return
            }
            detachChild(currentRoute)

            guard let viewController = viewControllable as? ControllableProtocol else {
                fatalError("\(type(of: viewControllable)) does not conform ControllableProtocol.")
            }
            viewController.dismiss(viewController: currentRoute.viewControllable, completion: nil)
        }
    }
#endif
