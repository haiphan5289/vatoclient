//  File name   : FormHandlerProtocol.swift
//
//  Author      : Phuc, Tran Huu
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

#if canImport(Eureka)
import Eureka
import UIKit
import FwiCore

protocol FormHandlerProtocol: class {
    /// Cancel form.
    func cancelForm()

    /// Execute user's input.
    func execute(input: [String: Any?])
}

extension FormHandlerProtocol where Self: UIViewController {
    func execute(form: Form, prefixAction: (() -> Void)?, suffixAction: (() -> Void)?) {
        view.findAndResignFirstResponder()
        
        /* Condition validation: if user's input is valid or not */
        let info = form.values()
        guard form.validate().count <= 0 else {
            return
        }
        prefixAction?()
        execute(input: info)
    }
}
#endif

#if canImport(RIBs)
import RIBs

extension FormHandlerProtocol where Self: Interactable {
    func execute(form: Form, viewController: ViewControllable) {
        guard let view = viewController.uiviewController.view else {
            return
        }
        view.findAndResignFirstResponder()

        /* Condition validation: if user's input is valid or not */
        let info = form.values()
        guard form.validate().count <= 0 else {
            return
        }
        execute(input: info)
    }
}
#endif
