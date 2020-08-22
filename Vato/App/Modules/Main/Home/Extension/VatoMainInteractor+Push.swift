//  File name   : VatoMainInteractor+Push.swift
//
//  Author      : Dung Vu
//  Created date: 8/28/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import RxSwift
import RxCocoa

protocol HandlerProtocol {
    var canHandler: Bool { get }
}

extension VatoMainInteractor: HandlerProtocol {
    var canHandler: Bool {
        return self.presenter.canHandler
    }
}

// MARK: -- Push
extension VatoMainInteractor {
    func listenPushEcom() {
        NotificationPushService.instance.new.bind { [weak self](push) in
            guard let wSelf = self else { return }
            guard wSelf.canHandler == true else {
                return
            }
            let tapped = push.value(UserNotificationTap, defaultValue: false)
            guard tapped else { return }
            
            let aps: JSON? = push.value("aps", defaultValue: nil)
            let extra: JSON = aps?.value("extra", defaultValue: nil) ?? [:]
            let value: String = extra.value("type", defaultValue: "-1")
            
            guard let type = Int(value),
                let action = ManifestAction(rawValue: type)
            else {
                return
            }
            wSelf.handler(manifest: action, info: extra)
        }.disposeOnDeactivate(interactor: self)
    }
    
    func listenPushPromotion() {
        // Listen to promotion
        NotificationPushService.instance.new
            .distinctUntilChanged { [weak self](pushData) -> Bool in
                let previousID = self?.previousPush?.value(for: "gcm.message_id", defaultValue: "")
                let pushDataID = pushData.value(for: "gcm.message_id", defaultValue: "")
                return previousID == pushDataID
            }
            .observeOn(MainScheduler.instance)
            .bind { [weak self] (pushData) in
                guard self?.canHandler == true else {
                    return
                }
                self?.handler(new: pushData)
            }
            .disposeOnDeactivate(interactor: self)
    }
}

// MARK: -- Deeplink
extension VatoMainInteractor {
    private func loadDeeplinkEcom(type: ServiceCategoryType, action: ServiceCategoryAction) {
        checkLocation().bind(onNext: weakify({ (wSelf) in
            wSelf.routeToServiceCategory(type: type, action: action)
        })).disposeOnDeactivate(interactor: self)
    }
    
    func listenDeepLink() {
        VatoManageDeepLink.instance.newDeepLink.bind(onNext: weakify({ (deepLink, wSelf) in
            guard wSelf.canHandler == true else {
                return
            }
            
            VatoManageDeepLink.instance.reset()
            guard let service = deepLink.ecomService else { return }
            guard let storeId = deepLink.storeId else { return }
            
            wSelf.loadDeeplinkEcom(type: service, action: .storeId(id: storeId))
        })).disposeOnDeactivate(interactor: self)
    }
}

