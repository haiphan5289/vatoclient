//  File name   : RootVC.swift
//
//  Author      : Phuc Tran
//  Created date: 8/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit

protocol RootPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class RootVC: UIViewController, RootPresentable, RootViewControllable {
    /// Class's public properties.
    weak var listener: RootPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    // MARK: RootViewControllable's members
    func dismiss(viewController: ViewControllable) {
        if presentedViewController === viewController.uiviewController {
            dismiss(animated: true, completion: nil)
        }
    }

    func presentLoggedOut(viewController: ViewControllable) {
        let navigationViewController = UINavigationController(rootViewController: viewController.uiviewController)
        navigationViewController.modalTransitionStyle = .crossDissolve

        present(navigationViewController, animated: true, completion: nil)
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension RootVC {
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return .all
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
}

// MARK: View's key pressed event handlers
extension RootVC {
    @IBAction func handleButtonOnPressed(_ sender: Any) {}
}

// MARK: Class's public methods
extension RootVC {}

// MARK: Class's private methods
private extension RootVC {
    private func localize() {
        // todo: Localize view's here.
    }

    private func visualize() {
        // todo: Visualize view's here.
    }

    private func setupRX() {
        // todo: Bind data to UI here.
    }
}
