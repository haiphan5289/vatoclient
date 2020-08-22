//  File name   : InTripRequestInfoProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 5/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import VatoNetwork
import RxSwift

enum InTripDurationRequest {
    case started
    case inTrip
}

protocol InTripRequestInfoProtocol {}

extension InTripRequestInfoProtocol {
    static func requestInfo(start: Observable<CLLocationCoordinate2D>, end: Observable<CLLocationCoordinate2D>) -> Observable<Swift.Result<MessageDTO<MapModel.Router>, Error>> {
        return Observable.zip(start, end) { (c1, c2) -> APIRequestProtocol in
            MapAPI.Router.direction(authToken: "", origin: c1.value, destination: c2.value, transport: .car)
        }.flatMap { (router)  in
            return self.requestPolyline(router: router)
        }
    }
    
    private static func requestPolyline(router: APIRequestProtocol) -> Observable<Swift.Result<MessageDTO<MapModel.Router>, Error>> {
        let network = NetworkRequester(provider: NetworkTokenProvider(token: FirebaseTokenHelper.instance.eToken.filterNil()))
        return network.request(using: router, decodeTo: MessageDTO<MapModel.Router>.self)
    }
}
