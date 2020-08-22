//  File name   : InputCodeVC.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX

final class InputCodeVC: UIViewController {
    var didSelectCode: ((String?) -> Void)?
    var inputCodeQRDismiss: (() -> Void)?
    private(set) lazy var disposeBag = DisposeBag()
    
    private struct Config {
    }
    
    /// Class's public properties.
    @IBOutlet weak var noteView: UIView?
    @IBOutlet weak var lbTitle: UILabel?
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var backGroundButton: UIButton!
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 14)
        v.containerColor = .white
        return v
    }()

    private var arrayCell = [NotePakageSizeTableViewCell]()
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        
        codeTextField?.becomeFirstResponder()
        codeTextField?.returnKeyType = UIReturnKeyType.done
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        codeTextField?.resignFirstResponder()
    }

   
}

// MARK: View's event handlers
extension InputCodeVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension InputCodeVC {
}

// MARK: Class's private methods
private extension InputCodeVC {
    private func localize() {
        // todo: Localize view's here.
        lbTitle?.text = Text.inputCode.localizedText
        btnConfirm?.setTitle(Text.sendCode.localizedText, for: .normal)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        noteView?.backgroundColor = .clear
        noteView?.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    private func setupRX() {
        self.btnClose?.rx.tap.bind { [weak self] in
            self?.inputCodeQRDismiss?()
        }.disposed(by: disposeBag)
        
        self.backGroundButton?.rx.tap.bind { [weak self] in
            self?.inputCodeQRDismiss?()
            }.disposed(by: disposeBag)
        
        self.checkIsEnableTextField()
        self.codeTextField.rx.controlEvent([.editingChanged])
            .asObservable().subscribe({ [weak self] _ in
                self?.checkIsEnableTextField()
            }).disposed(by: disposeBag)
        self.codeTextField.rx.controlEvent([.editingDidEndOnExit])
            .asObservable().subscribe ({ [weak self] _ in

            }).disposed(by: disposeBag)
        self.btnConfirm?.rx.tap.bind { [weak self] in
            let keywordTrim = self?.codeTextField.text?.trim() ?? ""
            self?.didSelectCode?(keywordTrim)
        }.disposed(by: disposeBag)
        
        setupKeyboardAnimation()
    }
    
    private func checkIsEnableTextField() {
        let keywordTrim = self.codeTextField.text?.trim() ?? ""
        let isEnable = keywordTrim.count > 0
        self.btnConfirm.isEnabled = isEnable
        self.btnConfirm.backgroundColor = Color.orange.withAlphaComponent(isEnable ? 1 : 0.6)
    }
}

extension InputCodeVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return noteView
    }
}

