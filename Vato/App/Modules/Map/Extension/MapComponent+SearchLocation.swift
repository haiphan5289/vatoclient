//  File name   : MapComponent+SearchLocation.swift
//
//  Author      : Vato
//  Created date: 9/17/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the SearchLocation scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencySearchLocation: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the SearchLocation scope.
}

extension MapComponent: SearchLocationDependency {
    var authStream: AuthenticatedStream {
        return mutableAuthenticated
    }
    
    var searchLocationVC: SearchLocationViewControllable {
        return mapVC
    }

    var currentLocation: CLLocationCoordinate2D {
        return mapView.camera.target
    }
}
