//  File name   : BookingRequestInteractor+ListenerManage.swift
//
//  Author      : Dung Vu
//  Created date: 1/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

protocol ManageListenerProtocol: AnyObject, SafeAccessProtocol {
    var listenerManager: [Disposable] { get set }
}

extension ManageListenerProtocol {
    func cleanUpListener() {
        excute(block: { [unowned self] in
            self.listenerManager.forEach({ $0.dispose() })
            self.listenerManager.removeAll()
        })
    }
    
    func add(_ disposable: Disposable) {
        excute(block: { [unowned self] in
            self.listenerManager.append(disposable)
        })
    }
}

extension BookingRequestInteractor: ManageListenerProtocol {}
