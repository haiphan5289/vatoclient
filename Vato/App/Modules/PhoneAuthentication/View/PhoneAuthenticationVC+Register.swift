//  File name   : PhoneAuthenticationVC+Register.swift
//
//  Author      : Vato
//  Created date: 11/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Eureka

extension PhoneAuthenticationVC: RegisterViewControllable {
    func generateRegisterNextButton() -> UIButton {
        navigationOptions = RowNavigationOptions.Enabled
        disposeBag_ = nil
        
        title = Text.profileInfo.localizedText
        return continueButton
    }
}
