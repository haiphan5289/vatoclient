//  File name   : ProfileComponent+Referral.swift
//
//  Author      : Dung Vu
//  Created date: 9/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Profile to provide for the Referral scope.
// todo: Update ProfileDependency protocol to inherit this protocol.
protocol ProfileDependencyReferral: Dependency {
    // todo: Declare dependencies needed from the parent scope of Profile to provide dependencies
    // for the Referral scope.
}

extension ProfileComponent: ReferralDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticated
    }
    
    // todo: Implement properties to provide for Referral scope.
}
