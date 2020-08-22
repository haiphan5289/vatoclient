//  File name   : HomeComponent+Wallet.swift
//
//  Author      : Dung Vu
//  Created date: 12/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase

/// The dependencies needed from the parent scope of Home to provide for the Wallet scope.
// todo: Update HomeDependency protocol to inherit this protocol.
protocol HomeDependencyWallet: Dependency {
    // todo: Declare dependencies needed from the parent scope of Home to provide dependencies
    // for the Wallet scope.
}

extension HomeComponent: WalletDependency {
    var profileStream: ProfileStream {
        return self.dependency.profile
    }
    
    var mProfileStream: ProfileStream {
        return self.dependency.profile
    }
    
    
    // todo: Implement properties to provide for Wallet scope.
}
