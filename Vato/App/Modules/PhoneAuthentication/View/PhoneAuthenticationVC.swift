//  File name   : PhoneAuthenticationVC.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import Eureka
import SnapKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol PhoneAuthenticationPresentableListener: class {
    var phoneInputState: Observable<PhoneInputState> { get }

    func handleBackAction()
    func handleReadyAction()
}

final class PhoneAuthenticationVC: FormViewController, PhoneAuthenticationPresentable, PhoneAuthenticationViewControllable, KeyboardAnimationProtocol {
    lazy var continueButton: UIButton = UIButton(type: .system)

    /// Class's public properties.
    weak var listener: PhoneAuthenticationPresentableListener?

    var containerView: UIView? {
        return continueButton
    }

    var disposeBag: DisposeBag {
        if disposeBag_ == nil {
            disposeBag_ = DisposeBag()
        }
        return disposeBag_
    }
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        
        listener?.handleReadyAction()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()

        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        view.findAndResignFirstResponder()
        super.viewWillDisappear(animated)
    }

    /// Class's private properties.
    internal lazy var disposeBag_: DisposeBag! = DisposeBag()

    private lazy var backItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(PhoneAuthenticationVC.handleBackItemOnPressed(_:)))
        return item
    }()
}

// MARK: View's event handlers
extension PhoneAuthenticationVC {
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
extension PhoneAuthenticationVC {
    @IBAction func handleBackItemOnPressed(_ sender: Any) {
        listener?.handleBackAction()
    }
}

// MARK: Class's public methods
extension PhoneAuthenticationVC {}

// MARK: Class's private methods
private extension PhoneAuthenticationVC {
    private func localize() {
        title = Text.joinVato.localizedText
        continueButton.setTitle(Text.continue.localizedText.uppercased(), for: .normal)
    }

    private func visualize() {
        view.tintColor = Color.orange
        navigationItem.leftBarButtonItems = [backItem]
        view.backgroundColor = .white
        
        continueButton >>> view >>> {
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.setBackground(using: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1), state: .normal)
            $0.setBackground(using: #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 0.6), state: .disabled)
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(32)
                make.right.equalTo(-32)
                make.bottom.equalTo(-16)
                make.height.equalTo(48)
            }
        }
        view.insertSubview(tableView, belowSubview: continueButton)
        tableView >>> {
            $0.snp.makeConstraints { (make) in
                make.left.equalTo(32)
                make.right.equalTo(-32)
                make.bottom.equalTo(continueButton.snp.top).offset(-16)
                make.top.equalTo(view.layoutMarginsGuide.snp.top)
            }
        }

        navigationOptions = RowNavigationOptions.Disabled
        setupKeyboardAnimation()
    }

    private func setupRX() {
        _ = listener?.phoneInputState
            .map { $0 == .register }
            .takeUntil(self.rx.deallocated)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isHidden) in
                guard let wSelf = self else {
                    return
                }

                if isHidden {
                    let dummyItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                    wSelf.navigationItem.leftBarButtonItems = [dummyItem]
                } else {
                    wSelf.navigationItem.leftBarButtonItems = [wSelf.backItem]
                }
            })
    }
}
