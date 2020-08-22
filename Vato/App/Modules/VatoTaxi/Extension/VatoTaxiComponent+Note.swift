//  File name   : VatoTaxiComponent+Note.swift
//
//  Author      : Dung Vu
//  Created date: 9/18/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTaxi to provide for the Note scope.
// todo: Update VatoTaxiDependency protocol to inherit this protocol.
protocol VatoTaxiDependencyNote: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTaxi to provide dependencies
    // for the Note scope.
}

extension VatoTaxiComponent: NoteDependency {
    var note: MutableNoteStream {
        return noteStream
    }
}
