//  File name   : FillInformationComponent+PinAddress.swift
//
//  Author      : vato.
//  Created date: 11/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FillInformation to provide for the PinAddress scope.
// todo: Update FillInformationDependency protocol to inherit this protocol.
protocol FillInformationDependencyPinAddress: Dependency {
    // todo: Declare dependencies needed from the parent scope of FillInformation to provide dependencies
    // for the PinAddress scope.
}

extension FillInformationComponent: PinAddressDependency {

    // todo: Implement properties to provide for PinAddress scope.
}
