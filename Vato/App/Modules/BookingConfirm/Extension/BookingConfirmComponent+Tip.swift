//  File name   : BookingConfirmComponent+Tip.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the Tip scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyTip: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the Tip scope.
}

extension BookingConfirmComponent: TipDependency {
    // todo: Implement properties to provide for Tip scope.
}
