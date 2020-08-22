//
//  QuickSupportModel.swift
//  FC
//
//  Created by khoi tran on 1/14/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation


struct QuickSupportList: Codable {
    let values: [QuickSupportRequest]?
}

protocol QuickSupportDisplay {
    var title: String? { get }
    var description: String? { get }
    var enable: Bool { get }
}

struct QuickSupportRequest: QuickSupportDisplay, Codable {
    var title: String?
    var description: String?
    var enable: Bool
    
    
    
}

