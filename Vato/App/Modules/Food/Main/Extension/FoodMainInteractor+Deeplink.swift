//  File name   : FoodMainInteractor+Deeplink.swift
//
//  Author      : Dung Vu
//  Created date: 5/21/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

extension FoodMainInteractor: HandlerProtocol {
    var canHandler: Bool {
        return presenter.canHandler
    }
    
    func listenDeepLink() {
        VatoManageDeepLink.instance.newDeepLink.bind(onNext: weakify({ (deepLink, wSelf) in
            VatoManageDeepLink.instance.reset()
            guard wSelf.canHandler == true else {
                return
            }
            
            guard deepLink.ecomService != nil else { return }
            guard let storeId = deepLink.storeId else { return }
            wSelf.requestStoreDetailDeepLink(storeId: storeId)
        })).disposeOnDeactivate(interactor: self)
    }
}
