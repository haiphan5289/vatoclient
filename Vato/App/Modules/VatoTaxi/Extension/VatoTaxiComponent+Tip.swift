//  File name   : VatoTaxiComponent+Tip.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTaxi to provide for the Tip scope.
// todo: Update VatoTaxiDependency protocol to inherit this protocol.
protocol VatoTaxiDependencyTip: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTaxi to provide dependencies
    // for the Tip scope.
}

extension VatoTaxiComponent: TipDependency {
    // todo: Implement properties to provide for Tip scope.
}


extension VatoTaxiComponent: ConfirmBookingServiceMoreDependency {
    // todo: Implement properties to provide for Tip scope.
}
