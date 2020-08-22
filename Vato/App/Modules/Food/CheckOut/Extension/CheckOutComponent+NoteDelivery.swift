//  File name   : CheckOutComponent+NoteDelivery.swift
//
//  Author      : vato.
//  Created date: 12/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the NoteDelivery scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencyNoteDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the NoteDelivery scope.
}

extension CheckOutComponent: NoteDeliveryDependency {

    // todo: Implement properties to provide for NoteDelivery scope.
}
