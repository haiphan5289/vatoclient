//  File name   : LoggedOutComponent+SocialNetwork.swift
//
//  Author      : Vato
//  Created date: 9/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of LoggedOut to provide for the SocialNetwork scope.
// todo: Update LoggedOutDependency protocol to inherit this protocol.
protocol LoggedOutDependencySocialNetwork: Dependency {
    // todo: Declare dependencies needed from the parent scope of LoggedOut to provide dependencies
    // for the SocialNetwork scope.
}

extension LoggedOutComponent: SocialNetworkDependency {
    var mutableAuthenticationSocialCredential: MutableAuthenticationSocialCredentialStream {
        return mutableAuthentication
    }
}
