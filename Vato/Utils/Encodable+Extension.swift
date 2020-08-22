//  File name   : Encodable+Extension.swift
//
//  Author      : Dung Vu
//  Created date: 1/17/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

extension Encodable {
    func toJSON() throws -> JSON {
        let data = try toData()
        let value = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = value as? JSON else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey : "Failed make json!!!!"])
        }
        return json
    }
    
    func toData() throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return data
    }
}

