//
//  TOShortcutModel.swift
//  Vato
//
//  Created by khoi tran on 3/4/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation


struct TOShortutModel: TOShortcutCellDisplay, Codable {
    var isNew: Bool?
    var badgeNumber: Int?
    var name: String?
    var description: String?
    var cellType: TOShortcutCellType
    var type: TOShortCutType
            
    
}
