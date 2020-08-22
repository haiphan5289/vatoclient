//  File name   : PhoneAuthenticationVC+PhoneVerification.swift
//
//  Author      : Vato
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

extension PhoneAuthenticationVC: PhoneVerificationViewControllable {
    func generatePhoneVerificationNextButton() -> UIButton {
//        self.disposeBag_ = nil
//        setupKeyboardAnimation()
        title = Text.verifyingAuthenticationCode.localizedText
        return continueButton
    }
}
