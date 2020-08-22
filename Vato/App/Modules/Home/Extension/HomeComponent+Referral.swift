//  File name   : HomeComponent+Referral.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Home to provide for the Referral scope.
// todo: Update HomeDependency protocol to inherit this protocol.
protocol HomeDependencyReferral: Dependency {
    // todo: Declare dependencies needed from the parent scope of Home to provide dependencies
    // for the Referral scope.
}

extension HomeComponent: ReferralDependency {
    var authenticatedStream: AuthenticatedStream {
        return self.authenticated
    }
    
    // todo: Implement properties to provide for Referral scope.
}
