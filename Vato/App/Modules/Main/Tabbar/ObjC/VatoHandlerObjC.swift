//  File name   : VatoHandlerObjC.swift
//
//  Author      : Dung Vu
//  Created date: 8/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa

enum ObjCAction {
    case signout
    case routeNotifyDetail(data: NotificationModel?)
}

final class VatoHandlerObjC: NSObject {
    private (set)lazy var events: PublishSubject<ObjCAction> = PublishSubject()
}

extension VatoHandlerObjC: ProfileDetailDelegate, FCNotifyViewControllerDelegate {
    func onSelectedNotification(_ data: FCNotification!) {
//        events.onNext(.routeNotifyDetail(data: data))
    }
    
    func profileSignOut() {
        events.onNext(.signout)
    }
}

extension VatoHandlerObjC {
    func selectNotification(notify: NotificationModel?) {
        events.onNext(.routeNotifyDetail(data: notify))
    }
}

