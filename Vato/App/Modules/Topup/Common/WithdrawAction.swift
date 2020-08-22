//  File name   : WithdrawAction.swift
//
//  Author      : Dung Vu
//  Created date: 11/15/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift

protocol WithdrawActionHandlerProtocol {
    var eAction: PublishSubject<WithdrawConfirmAction> { get }
//    var errorMessageSubject: Observable<String> { get }
    var eIndicator: Observable<ActivityProgressIndicator.Element>? { get }
}

