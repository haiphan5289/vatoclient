//  File name   : MapComponent+Home.swift
//
//  Author      : Vato
//  Created date: 9/13/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FirebaseDatabase
import GoogleMaps
import RIBs

/// The dependencies needed from the parent scope of Map to provide for the Home scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyHome: Dependency {
}

extension MapComponent: HomeDependency {
    var homeVC: HomeViewControllable {
        return mapVC
    }

    var mapView: GMSMapView {
        return mapVC.mapView
    }

    var profile: ProfileStream {
        return mutableProfile
    }
}
