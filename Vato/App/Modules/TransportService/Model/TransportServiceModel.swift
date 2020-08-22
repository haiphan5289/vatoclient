//  File name   : TransportServiceModel.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct TransportGroup {
    let name: String
    let services: [ServiceCanUseProtocol]

    subscript(index: Int) -> ServiceCanUseProtocol {
        return services[index]
    }
    
    func index(of item: ServiceCanUseProtocol) -> Int? {
        for (idx, element) in services.enumerated(){
            if element.service.id == item.service.id {
                return idx
            }
        }
        return nil
    }
}

extension TransportGroup {
    static func dummy() -> [TransportGroup] {
        return []
//        let bike = TransportGroup(name: "Vato Xe máy", services: [ TransportServiceModel(icon: #imageLiteral(resourceName: "car_menu_8-selected"), description: "Xe thường", price: 30000), TransportServiceModel(icon: #imageLiteral(resourceName: "car_menu_16-selected"), description: "Xe tay ga", price: 30000)])
//        let car = TransportGroup(name: "Vato Car", services: [TransportServiceModel(icon: #imageLiteral(resourceName: "car_menu_4-selected"), description: "4 bánh", price: 30000)])
//        let taxi = TransportGroup(name: "Vato Taxi", services: [TransportServiceModel(icon: #imageLiteral(resourceName: "car_menu_10-normal"), description: "4 chỗ", price: 30000),TransportServiceModel(icon: #imageLiteral(resourceName: "car_menu_10-selected"), description: "7 chỗ", price: 30000)])
//        return [bike, car, taxi]
    }
}
