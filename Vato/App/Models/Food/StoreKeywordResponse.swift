//  File name   : StoreKeywordResponse.swift
//
//  Author      : Dung Vu
//  Created date: 11/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct StoreKeywordItem: Codable, Comparable {
    var textSearch: String?
    var countTimeSearch: Int?
    
    static func ==(lhs: StoreKeywordItem, rhs: StoreKeywordItem) -> Bool {
        return lhs.countTimeSearch == rhs.countTimeSearch
    }
    
    static func < (lhs: StoreKeywordItem, rhs: StoreKeywordItem) -> Bool {
       let l1 = lhs.countTimeSearch ?? 0
       let l2 = rhs.countTimeSearch ?? 0
        
       return l1 < l2
    }
}

struct StoreKeywordsResponse: Codable {
    var listSearchText: [StoreKeywordItem]?
    var indexPage: Int?
    var sizePage: Int?
    var totalPage: Int?
}


