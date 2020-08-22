//  File name   : SocialNetworkVC.swift
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
import GoogleSignIn
import FwiCoreRX

protocol SocialNetworkPresentableListener: class {
    var isLoading: Observable<(Bool, Double)> { get }

    func handleFacebookAction()
    func handleGoogleAction()
}

final class SocialNetworkVC: UIViewController, SocialNetworkPresentable, SocialNetworkViewControllable, LoadingAnimateProtocol, DisposableProtocol {
    private struct Config {
        static let connectWithText = Text.connectWith.localizedText
        static let termAndPrivacyPolicyDescription = Text.termAndPrivacyPolicyDescription.localizedText
        static let term = Text.term.localizedText
        static let and = Text.and.localizedText
        static let privacyPolicy = Text.privacyPolicy.localizedText
        static let ofVato = Text.ofVato.localizedText
    }

    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var termAndPrivacyButton: UIButton!

    /// Class's public properties.
    weak var listener: SocialNetworkPresentableListener?

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
    
    deinit {
        printDebug("\(#function)")
    }

    /// Class's private properties.
    internal let disposeBag = DisposeBag()
}

// MARK: View's key pressed event handlers
extension SocialNetworkVC {
    @IBAction func handleFacebookButtonOnPressed(_ sender: Any) {
        listener?.handleFacebookAction()
    }

    @IBAction func handleGoogleButtonOnPressed(_ sender: Any) {
        listener?.handleGoogleAction()
    }

    @IBAction func handleTermAndPrivacyButtonOnPressed(_ sender: Any) {
        let url = URL(string: "https://vato.vn/quy-che-hoat-dong-va-dieu-khoan/")
        WebVC.loadWeb(on: self.parent, url: url, title: "Quy chế hoạt động và điều khoản")
    }
}

// MARK: Class's public methods
extension SocialNetworkVC {
    func sign(_ signIn: GIDSignIn, dismiss viewController: UIViewController) {
        if presentedViewController === viewController {
            DispatchQueue.main.async {
                viewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn, present viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            self?.present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: Class's private methods
private extension SocialNetworkVC {
    private func localize() {
        linkLabel.text = Config.connectWithText

        let t1 = "\(Config.termAndPrivacyPolicyDescription) ".attribute
            >>> .font(f: .systemFont(ofSize: 13.0, weight: .regular))
            >>> .color(c: Color.battleshipGreyTwo)

        let t2 = Config.term.attribute
            >>> .font(f: .systemFont(ofSize: 13.0, weight: .regular))
            >>> .color(c: Color.orange)

        let t3 = " \(Config.and) ".attribute
            >>> .font(f: .systemFont(ofSize: 13.0, weight: .regular))
            >>> .color(c: Color.battleshipGreyThree)

        let t4 = Config.privacyPolicy.attribute
            >>> .font(f: .systemFont(ofSize: 13.0, weight: .regular))
            >>> .color(c: Color.orange)
        
        let t5 = Config.ofVato.attribute
            >>> .font(f: .systemFont(ofSize: 13.0, weight: .regular))
            >>> .color(c: Color.battleshipGreyTwo)
        

        let title = (t1 >>> t2 >>> t3 >>> t4 >>> t5)
        termAndPrivacyButton.setAttributedTitle(title, for: .normal)
        termAndPrivacyButton.titleLabel?.textAlignment = .center
    }

    private func visualize() {
        // todo: Visualize view's here.
    }

    private func setupRX() {
        showLoading(use: listener?.isLoading)
    }
}
