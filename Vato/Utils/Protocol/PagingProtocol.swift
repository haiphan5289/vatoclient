//  File name   : PagingProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 10/24/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

protocol PagingNextProtocol {
    static var `default`: Self { get }
    var page: Int { get }
    var size: Int { get }
    var canRequest: Bool { get }
    var next: Self? { get }
    var first: Bool { get }
    init(page: Int, canRequest: Bool, size: Int)
}

extension PagingNextProtocol {
    var next: Self? {
        guard canRequest else {
            return nil
        }
        return Self(page: page + 1, canRequest: false, size: size)
    }
    
    var first: Bool {
        return page <= 1
    }
}

enum ListUpdate<T> {
    case reload(items: [T])
    case update(items: [T])
}

struct ResponsePaging<T: Codable>: Codable {
    var data: [T]?
    var totalPage: Int = 0
    var pageSize: Int = 0
    var currentPage: Int = 0
    var total: Int = 0
    var next: Bool {
        let result = currentPage != totalPage
        return result
    }
}

struct Paging: PagingNextProtocol {
    static let `default` = Paging(page: 0, canRequest: true, size: 15)
    
    var page: Int
    var size: Int
    var canRequest: Bool
    
    init(page: Int, canRequest: Bool, size: Int) {
        self.page = page
        self.canRequest = canRequest
        self.size = size
    }
}

struct PagingEcom: PagingNextProtocol {
    static let `default` = PagingEcom(page: -1, canRequest: true, size: 30)
    
    var page: Int
    var size: Int
    var canRequest: Bool
    
    init(page: Int, canRequest: Bool, size: Int) {
        self.page = page
        self.canRequest = canRequest
        self.size = size
    }
    
    var params: JSON {
        var result = JSON()
        result["page"] = page
        result["size"] = size
        return result
    }
}

struct PagingKeyword: PagingNextProtocol {
    static let `default` = PagingKeyword(page: -1, canRequest: true, size: 15)
    var keyword: String?
    var page: Int
    var size: Int
    var canRequest: Bool
    
    var first: Bool {
        return page == -1
    }
    
    var next: PagingKeyword? {
        guard canRequest else {
            return nil
        }
        
        return PagingKeyword(keyword: keyword, page: page + 1, size: size, canRequest: false)
    }
    
    mutating func update(keyword: String?) {
        self.keyword = keyword
    }
    
    mutating func resetPage() {
        self.page = -1
        self.canRequest = true
    }
}

extension PagingKeyword {
    init(page: Int, canRequest: Bool, size: Int) {
        self.keyword = nil
        self.page = page
        self.canRequest = canRequest
        self.size = size
    }
//    https://api-ecom.vato.vn/api/ecom/store/by-key-words?indexPage=0&lat=10.765868&lon=106.693385&keyWords=B%C3%BAn%20b%C3%B2&sizePage=10
    var params: [String: Any] {
        var p = [String: Any]()
        p["indexPage"] = page
        p["keyWords"] = keyword
        p["sizePage"] = size
        return p
    }
}
