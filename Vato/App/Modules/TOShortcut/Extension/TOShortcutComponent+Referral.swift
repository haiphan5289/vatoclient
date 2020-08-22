//  File name   : TOShortcutComponent+Referral.swift
//
//  Author      : khoi tran
//  Created date: 3/6/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the Referral scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyReferral: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the Referral scope.
}

extension TOShortcutComponent: ReferralDependency {

    // todo: Implement properties to provide for Referral scope.
}
