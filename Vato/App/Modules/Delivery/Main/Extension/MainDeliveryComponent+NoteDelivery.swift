//  File name   : MainDeliveryComponent+NoteDelivery.swift
//
//  Author      : Dung Vu
//  Created date: 8/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the NoteDelivery scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyNoteDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the NoteDelivery scope.
}

extension MainDeliveryComponent: NoteDeliveryDependency {

    // todo: Implement properties to provide for NoteDelivery scope.
}
