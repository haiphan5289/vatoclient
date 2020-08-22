//  File name   : VatoNewRouting.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RIBs

@objcMembers
final class VatoHomeNewRouting: NSObject, VatoTabbarDependency, VatoTabbarListener {
    private var route: Routing?
    
    func presentMain() -> UIViewController {
        let builder = VatoTabbarBuilder(dependency: self)
        let r = builder.build(withListener: self)
        defer {
            self.route = r
        }
        r.interactable.activate()
        r.load()
        
        let viewController = r.viewControllable.uiviewController
        return viewController
    }
    
    func deactive() {
        route?.interactable.deactivate()
    }
}


