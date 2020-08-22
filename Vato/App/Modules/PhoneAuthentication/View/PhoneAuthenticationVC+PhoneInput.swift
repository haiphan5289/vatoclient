//  File name   : PhoneAuthenticationVC+PhoneInput.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit

extension PhoneAuthenticationVC: PhoneInputViewControllable {
    func generatePhoneInputNextButton() -> UIButton {
//        self.disposeBag_ = nil
//        setupKeyboardAnimation()
        title = Text.joinVato.localizedText
        return continueButton
    }
}
