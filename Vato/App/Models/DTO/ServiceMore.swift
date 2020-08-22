//
//  ServiceMore.swift
//  Vato
//
//  Created by MacbookPro on 11/15/19.
//  Copyright © 2019 Vato. All rights reserved.
//
// MARK: - AdditionalService

enum AdditionalServicesType: String, Codable {
    case PERCENT
    case FLAT
}

struct AdditionalServices: Codable {
    var id: Int?
    var name: String?
    var amount: Double?
    var type: AdditionalServicesType?
    var service: Int?
    var changeable: Bool?
    
    func canAppy(serviceId: Int) -> Bool {
        return (((service ?? 0) & serviceId) == serviceId)
    }
}


extension AdditionalServices {
    func caculateAdditionalAmount(currentAmount: Double) -> Double {
        guard let type = type, let amount = amount else {
            return 0
        }
        
        switch type {
        case .FLAT:
            return amount
        case .PERCENT:
            return currentAmount * (amount / 100)
        }
        return 0
    }

}

extension AdditionalServices: Hashable {
    func hash(into hasher: inout Hasher) {
        let id = self.id ?? 0
        let service = self.service ?? 0
        hasher.combine(id)
        hasher.combine(service)
    }
}
