//  File name   : ShoppingFillInformationComponent+SearchLocation.swift
//
//  Author      : khoi tran
//  Created date: 4/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingFillInformation to provide for the SearchLocation scope.
// todo: Update ShoppingFillInformationDependency protocol to inherit this protocol.
protocol ShoppingFillInformationDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingFillInformation to provide dependencies
    // for the SearchLocation scope.
}

extension ShoppingFillInformationComponent: LocationPickerDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticated
    }
    

    // todo: Implement properties to provide for SearchLocation scope.
}
