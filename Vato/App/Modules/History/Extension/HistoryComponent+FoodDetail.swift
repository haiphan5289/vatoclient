//  File name   : HistoryComponent+FoodDetail.swift
//
//  Author      : khoi tran
//  Created date: 4/16/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of History to provide for the FoodDetail scope.
// todo: Update HistoryDependency protocol to inherit this protocol.
protocol HistoryDependencyFoodDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of History to provide dependencies
    // for the FoodDetail scope.
}

extension HistoryComponent: FoodDetailDependency {
    var foodDetailProfile: ProfileStream {
        dependency.profile
    }
    
   
    

    

    // todo: Implement properties to provide for FoodDetail scope.
}
