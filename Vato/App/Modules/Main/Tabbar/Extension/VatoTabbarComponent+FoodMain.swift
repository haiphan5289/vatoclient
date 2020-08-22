//  File name   : VatoTabbarComponent+FoodMain.swift
//
//  Author      : Dung Vu
//  Created date: 10/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the FoodMain scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyFoodMain: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the FoodMain scope.
}

extension VatoTabbarComponent: FoodMainDependency {
    // todo: Implement properties to provide for FoodMain scope.
//    var mProfileStream: MutableProfileStream {
//        return mutableProfile
//    }
}
