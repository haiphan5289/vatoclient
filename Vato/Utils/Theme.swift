//  File name   : Theme.swift
//
//  Author      : Futa Corp
//  Created date: 12/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

extension UINavigationBar {
    func applyTheme() {
        titleTextAttributes = [
            NSAttributedString.Key.foregroundColor:UIColor.white,
            NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16.0, weight: .medium)
        ]
        tintColor = .white
        barTintColor = .white
        isTranslucent = false
        setBackgroundImage(#imageLiteral(resourceName: "bg_master_navigation"), for: .default)
    }
}
