//  File name   : ShoppingMainComponent+NoteDelivery.swift
//
//  Author      : khoi tran
//  Created date: 4/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the NoteDelivery scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyNoteDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the NoteDelivery scope.
}

extension ShoppingMainComponent: NoteDeliveryDependency {

    // todo: Implement properties to provide for NoteDelivery scope.
}
