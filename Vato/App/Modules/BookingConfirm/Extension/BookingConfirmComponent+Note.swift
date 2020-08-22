//  File name   : BookingConfirmComponent+Note.swift
//
//  Author      : Dung Vu
//  Created date: 9/18/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the Note scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyNote: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the Note scope.
}

extension BookingConfirmComponent: NoteDependency {
    var note: MutableNoteStream {
        return noteStream
    }
}
