//  File name   : TOShortcutComponent+SetLocation.swift
//
//  Author      : Dung Vu
//  Created date: 8/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the SetLocation scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencySetLocation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the SetLocation scope.
}

extension TOShortcutComponent: SetLocationDependency {
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBookingStream
    }
    // todo: Implement properties to provide for SetLocation scope.
}
