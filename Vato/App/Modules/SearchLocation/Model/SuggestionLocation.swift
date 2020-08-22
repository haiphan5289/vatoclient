//  File name   : SuggestionLocation.swift
//
//  Author      : Vato
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct SuggestionLocation: Hashable {
    let placeID: String
    let primaryText: String
    let secondaryText: String

    var hashValue: Int {
        return "\(primaryText.lowercased())_\(secondaryText.lowercased())".hashValue
    }

    static func == (lhs: SuggestionLocation, rhs: SuggestionLocation) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
