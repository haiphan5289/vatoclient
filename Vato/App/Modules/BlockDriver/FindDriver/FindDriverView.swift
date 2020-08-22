//
//  FindDriverView.swift
//  Vato
//
//  Created by thi nguyen on 6/25/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

final class FindDriverView: UIView {
    struct Config {
        
    }
    
    var btnClose: UIButton!
    var textField: UITextField!
    var btnContinue: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView () {
        self.backgroundColor = .white
                
        let btnContinue = UIButton(frame: .zero) >>> {
            $0.setTitle(Text.continue.localizedText, for: .normal)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 7.0
            $0.setBackground(using: #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1), state: .normal)
            $0.setBackground(using: #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1), state: .disabled)
            $0.isEnabled = false
        } >>> self >>> {
            $0.snp.makeConstraints({
                $0.height.equalTo(44)
                $0.leading.trailing.bottom.equalToSuperview().inset(16)
            })
        }
        self.btnContinue = btnContinue
        
        let seperateView = UIView(frame: .zero) >>> {
            $0.backgroundColor = .black
        } >>> self >>> {
            $0.snp.makeConstraints({
                $0.height.equalTo(0.5)
                $0.leading.trailing.equalTo(btnContinue)
                $0.bottom.equalTo(btnContinue.snp.top).inset(-16)
            })
        }

        let textField = UITextField(frame: .zero) >>> {
            $0.keyboardType = .phonePad
            $0.textContentType = .telephoneNumber
            $0.textAlignment = .center
            $0.becomeFirstResponder()
            $0.borderStyle = UITextField.BorderStyle.none
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.height.equalTo(40)
                    $0.leading.trailing.equalTo(btnContinue)
                    $0.bottom.equalTo(seperateView.snp.top)
                })
        }
        self.textField = textField
                
        let _ = UILabel(frame: .zero) >>> {
            $0.textAlignment = .center
            $0.text = Text.inputDriverPhone.localizedText
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(50)
                    $0.top.equalToSuperview()
                    $0.bottom.equalTo(textField.snp.top)
                })
        }
        
        let btnClose = UIButton(frame: .zero) >>> {
            $0.setImage(UIImage(named: "close-g"), for: .normal)
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.top.equalToSuperview().inset(10)
                    $0.leading.equalToSuperview().inset(15)
                    $0.height.width.equalTo(15)
                })
        }
        self.btnClose = btnClose
    }
}


