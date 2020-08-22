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
    private var lblTitle: UILabel!
    var lblError: UILabel!
    private var seperateView: UIView!
    private var containerView :UIView!
    
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
        let btnContinue = UIButton(frame: .zero) >>> {
            $0.setTitle("Tiếp tục", for: .normal)
            $0.backgroundColor =  #colorLiteral(red: 0.7529411765, green: 0.7764705882, blue: 0.8, alpha: 1)
            $0.layer.cornerRadius = 5
            
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.height.equalTo(50)
                    $0.bottom.equalTo(self.snp.bottom).inset(10)
                    $0.leading.trailing.equalTo(self).inset(10)
                })
        }
        self.btnContinue = btnContinue
        
        
        let lblError = UILabel(frame: .zero) >>> {
            $0.backgroundColor = .clear
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.height.equalTo(44)
                    $0.bottom.equalTo(btnContinue.snp.top)
                    $0.leading.trailing.equalTo(btnContinue)
                })
        }
        self.lblError = lblError
        
        let textField = UITextField(frame: .zero) >>> self >>> {
            $0.snp.makeConstraints({
                $0.bottom.equalTo(lblError.snp.top)
                $0.leading.trailing.equalTo(lblError)
                $0.height.equalTo(40)
            })
            }  >>> {
                $0.keyboardType = .phonePad
                $0.textContentType = .telephoneNumber
                $0.textAlignment = .center
                $0.becomeFirstResponder()
                $0.borderStyle = UITextField.BorderStyle.none
        }
        self.textField = textField
        let seperateView = UIView(frame: .zero) >>> {
            $0.backgroundColor = .black
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.height.equalTo(1)
                    $0.leading.trailing.equalTo(textField)
                    $0.top.equalTo(textField.snp.bottom)
                })
        }
        self.seperateView = seperateView
        
        let lblTitle = UILabel(frame: .zero) >>> {
            $0.textAlignment = .center
            $0.text = "Nhập số điện thoại lái xe"
            } >>> self >>> {
                $0.snp.makeConstraints({
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(50)
                    $0.bottom.equalTo(textField.snp.top)
                    $0.leading.trailing.equalTo(self).inset(10)
                })
        }
        self.lblTitle = lblTitle
        
        self.containerView = UIView()
        self.containerView.backgroundColor = .white
        self.insertSubview(containerView, belowSubview: btnContinue)
        self.containerView.snp.makeConstraints({
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(lblTitle)
        })
        
        let btnClose = UIButton(frame: .zero) >>> {
            $0.setImage(UIImage(named: "close-g"), for: .normal)
            
            } >>> containerView >>> {
                $0.snp.makeConstraints({
                    $0.top.equalToSuperview().inset(10)
                    $0.leading.equalToSuperview().inset(15)
                    $0.height.width.equalTo(15)
                })
        }
        self.btnClose = btnClose
        btnClose.isEnabled = true
        
    }
}


