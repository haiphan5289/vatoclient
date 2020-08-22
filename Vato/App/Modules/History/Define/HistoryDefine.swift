//  File name   : HistoryDefine.swift
//
//  Author      : Dung Vu
//  Created date: 12/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit

// MARK: - Define Section
enum HistoryExpressSectionType {
    case title
    case expand
   
    var style: HistoryExpressSectionStyle {
        switch self {
        case .title:
            return HistoryExpressSectionStyle(background: #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1), seperator: true, font: .systemFont(ofSize: 14, weight: .medium), textColor: #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1))
        case .expand:
            return HistoryExpressSectionStyle(background: .white, seperator: false, font: .systemFont(ofSize: 15, weight: .medium), textColor: #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1))
        }
    }
}

struct HistoryExpressSectionStyle {
    let background: UIColor
    let seperator: Bool
    let font: UIFont
    let textColor: UIColor
}

protocol HistoryExpressDisplayProtocol {
    func setup(display item: HistoryExpressItemProtocol, idx: Int)
}

// MARK: - Status
enum HistoryExpressStatus: Int {
    case none
    case intrip
    case completed
}

// MARK: - Data
protocol HistoryExpressItemProtocol {
    var numberItems: Int { get }
}

final class HistoryExpressSection {
    var type: HistoryExpressSectionType = .title
    var id: Double = Date().timeIntervalSince1970
    var expand: Bool = false
    var title: String?
    var canExpand: Bool {
        return !items.isEmpty
    }
    var items: [HistoryExpressItemProtocol] = []
    init(type: HistoryExpressSectionType, items: [HistoryExpressItemProtocol], title: String?) {
        self.type = type
        self.items = items
        self.title = title
    }
}

// MARK: - Dummy
typealias HistoryExpress = DummyHistoryExpress

struct DummyHistoryExpress: HistoryExpressItemProtocol, Equatable {
    static func ==(lhs: DummyHistoryExpress, rhs: DummyHistoryExpress) -> Bool {
        return lhs.id == rhs.id
    }
    var id: Int
    var numberItems: Int
    
}

