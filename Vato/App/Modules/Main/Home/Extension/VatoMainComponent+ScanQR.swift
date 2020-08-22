//  File name   : VatoMainComponent+ScanQR.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoMain to provide for the ScanQR scope.
// todo: Update VatoMainDependency protocol to inherit this protocol.
protocol VatoMainDependencyScanQR: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoMain to provide dependencies
    // for the ScanQR scope.
}

extension VatoMainComponent: ScanQRDependency {
    var mutableAuthenticated: MutableAuthenticatedStream {
        return dependency.mutableAuthenticated
    }
    
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    

    // todo: Implement properties to provide for ScanQR scope.
}
