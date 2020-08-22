//  File name   : Location.swift
//
//  Author      : Dung Vu
//  Created date: 10/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore
import RxSwift

typealias LocationBlockComplete = () -> Void
typealias LocationBlockError = (Error) -> Void

@objcMembers
final class LocationHelper: NSObject {
    /// Class's public properties.
    private var handlerComplete: LocationBlockComplete?
    private var handlerError: LocationBlockError?
    private lazy var disposeBag = DisposeBag()

    /// Class's constructors.
    private override init() {
        super.init()
    }

    convenience init(_ complete: LocationBlockComplete?, error: LocationBlockError?) {
        self.init()
        self.handlerComplete = complete
        self.handlerError = error
    }

    func checkLocation() {
        guard VatoLocationManager.shared.location == nil else {
            handlerComplete?()
            return
        }

        // Request location
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocation()
        default:
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorDataNotAllowed, userInfo: [NSLocalizedDescriptionKey: "Can't check location"])
            handlerError?(error)
        }
    }

    /// Class's private properties.
    private func requestLocation() {
        // Note : Not need weak self for this
        NotificationCenter.default.rx.notification(.locationUpdated)
            .buffer(timeSpan: 2, count: 10, scheduler: MainScheduler.instance)
            .filter { $0.count > 0 }
            .timeout(2, scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { _ in
                self.handlerComplete?()
            }, onError: {
                self.handlerError?($0)
            }).disposed(by: disposeBag)

        VatoLocationManager.shared.startUpdatingLocation()
    }

    deinit {
        printDebug("\(#function)")
    }
}
