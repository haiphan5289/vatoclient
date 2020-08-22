//  File name   : ProgressHUDRegister.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation


//extension SVProgressHUD: LoadingViewProtocol {}

@objcMembers
final class ProgressHUDRegister: NSObject {
    static func registerLoading() {
        LoadingManager.register(type: VatoLoadingView.self)
    }
}
