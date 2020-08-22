//  File name   : VatoTabbarComponent+Wallet.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the Wallet scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyWallet: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the Wallet scope.
}

extension VatoTabbarComponent: WalletDependency {
    var authenticated: AuthenticatedStream {
        return self.mutableAuthenticated
    }
    
    var profileStream: ProfileStream {
        return self.mutableProfile
    }
    
    var mProfileStream: ProfileStream {
        return self.mutableProfile
    }
    
    // todo: Implement properties to provide for Wallet scope.
}
