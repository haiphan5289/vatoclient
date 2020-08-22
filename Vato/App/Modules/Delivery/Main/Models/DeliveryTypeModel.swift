//
//  DeliveryTypeModel.swift
//  Vato
//
//  Created by khoi tran on 11/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation


enum DeliveryTypeModel {
    case urban
    case cities
    
    
    func text() -> String {
        switch self {
        case .urban:
            return Text.urbanDelivery.localizedText
        case .cities:
            return Text.citiesDelivery.localizedText
        
        }
    }
}


struct DeliveryVehicle: ImageDisplayProtocol {
    var id: String?
    var imageURL: String?
    var name: String?
    var cacheLocal: Bool { return true }
}


