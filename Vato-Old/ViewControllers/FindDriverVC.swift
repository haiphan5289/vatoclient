//  File name   : FindDriverVC.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa

protocol FindDriverPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    func close()
    func goContinue(phone: String)
    func validPhone(phoneNumber: String)
}

final class FindDriverVC: UIViewController, FindDriverPresentable, FindDriverViewControllable {
    private struct Config {
    }
    
    /// Class's public properties.
    weak var listener: FindDriverPresentableListener?
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        view.backgroundColor = Color.black40

   }
    
    func validateBtnNext(isValidate: Bool) {
        self.findDriverView.btnContinue.isEnabled = isValidate
        if isValidate {
            self.findDriverView.btnContinue?.backgroundColor = #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)
        } else {
            self.findDriverView.btnContinue?.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
        }
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.findDriverView.textField.becomeFirstResponder()
        localize()
    }
    private lazy var findDriverView = FindDriverView()
    /// Class's private properties.
    private(set) lazy var disposeBag = DisposeBag()
}

// MARK: View's event handlers
extension FindDriverVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension FindDriverVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return self.view
    }
}

// MARK: Class's private methods
private extension FindDriverVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        setupView()
        // todo: Visualize view's here.
        
    }
    
    private func setupView() {
        let findDriverView = FindDriverView() >>> self.view
            >>> {
                $0.snp.makeConstraints({make in
                    make.edges.equalToSuperview()
                })
        }
        self.findDriverView = findDriverView
        self.findDriverView.btnContinue.isEnabled = false
        self.findDriverView.textField.delegate = self
    }
    
    // private method
    
    private func setupRX() {
        setupKeyboardAnimation()
        
        self.findDriverView.btnClose.rx.tap.bind { [weak self] in
            self?.listener?.close()
        }.disposed(by: disposeBag)
        
        self.findDriverView.btnContinue.rx.tap.bind { [weak self] in
            self?.listener?.goContinue(phone:self?.findDriverView.textField.text ?? "")
        }.disposed(by: disposeBag)
    }

}




extension FindDriverVC : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        self.listener?.validPhone(phoneNumber: result)
        return true
    }
}
