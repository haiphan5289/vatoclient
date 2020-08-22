//  File name   : MapComponent+BookingConfirm.swift
//
//  Author      : Dung Vu
//  Created date: 9/18/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Firebase
import RIBs

/// The dependencies needed from the parent scope of Map to provide for the BookingConfirm scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyBookingConfirm: Dependency {}

extension MapComponent: BookingConfirmDependency {
    var bookingConfirmVC: BookingConfirmViewControllable {
        return mapVC
    }

    var authenticated: AuthenticatedStream {
        return dependency.mutableAuthenticated
    }

    var profileStream: MutableProfileStream {
        return dependency.mutableProfile
    }

    var bookingPoints: BookingStream {
        return mutableBooking
    }

    var mutableBookingState: MutableBookingStateStream {
        return mutableBooking
    }
    
    var mutablePaymentStream: MutablePaymentStream {
       return shared { PaymentStreamImpl() }
    }
}
