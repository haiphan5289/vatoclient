//  File name   : ProfileComponent+MainMerchant.swift
//
//  Author      : Dung Vu
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Profile to provide for the MainMerchant scope.
// todo: Update ProfileDependency protocol to inherit this protocol.
protocol ProfileDependencyMainMerchant: Dependency {
    // todo: Declare dependencies needed from the parent scope of Profile to provide dependencies
    // for the MainMerchant scope.
}

extension ProfileComponent: MainMerchantDependency {

    // todo: Implement properties to provide for MainMerchant scope.
}


extension ProfileComponent: NotificationDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    
    
}
