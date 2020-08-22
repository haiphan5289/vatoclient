//  File name   : FoodMainComponent+LocationPicker.swift
//
//  Author      : Dung Vu
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the LocationPicker scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the LocationPicker scope.
}

extension FoodMainComponent: LocationPickerDependency {

    // todo: Implement properties to provide for LocationPicker scope.
}
