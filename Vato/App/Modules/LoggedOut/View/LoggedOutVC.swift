//  File name   : LoggedOutVC.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit

import CocoaLumberjackSwift
import MessageUI

protocol LoggedOutPresentableListener: class {
    /// Request to present social network module.
    func attachSocialNetworkAction()

    /// Request to present phone authentication module.
    func handlePhoneAuthenticationAction()
}

final class LoggedOutVC: UIViewController, LoggedOutPresentable, LoggedOutViewControllable {
    private struct Config {
        static let welcomeText = Text.slogan.localizedText
        static let welcomeDescriptionText = Text.superApp.localizedText
        static let enterPhoneNumberText = Text.inputPhoneNumber.localizedText
    }


    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeDescriptionLabel: UILabel!
    @IBOutlet weak var enterPhoneNumberLabel: UILabel!
    @IBOutlet var hImageView: NSLayoutConstraint!

    /// Class's public properties.
    weak var listener: LoggedOutPresentableListener?

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        listener?.attachSocialNetworkAction()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    /// Class's private properties.
}

// MARK: View's event handlers
extension LoggedOutVC {
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
        return .lightContent
    }
}

// MARK: View's key pressed event handlers
extension LoggedOutVC {
    @IBAction func handleAuthenticationButtonOnPressed(_ sender: Any) {
        listener?.handlePhoneAuthenticationAction()
    }
}

// MARK: Class's public methods
extension LoggedOutVC {}

// MARK: Class's private methods
private extension LoggedOutVC {
    private func localize() {
        welcomeLabel.text = Config.welcomeText
        welcomeDescriptionLabel.text = Config.welcomeDescriptionText
        enterPhoneNumberLabel.text = Config.enterPhoneNumberText
    }

    private func visualize() {
        let ratio = UIScreen.main.bounds.width / 375
        let h = 400 * ratio
        hImageView.constant = h
        view.layoutIfNeeded()

        navigationController?.navigationBar.applyTheme()
    }
}
