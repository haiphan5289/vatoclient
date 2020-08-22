//  File name   : WalletTransactionsHistoryModel.swift
//
//  Author      : Dung Vu
//  Created date: 12/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct WalletTransactionItem: Codable, WalletItemDisplayProtocol, Comparable {
    var increase: Bool {
        let userId = UserManager.instance.userId
        return userId == accountTo
//        switch type {
//        case 300:
//            let userId = UserDataHelper.shareInstance().userId()
//            return !(userId == id)
//        case 60000:
//            return true
//        default:
//            return false
//        }
    }
    
//    TRIP(100), // các giao dịch liên quan tới chuyến đi
//    "Chuyến đi"
//    TOPUP(40001), // các giao dịch liên quan tộp tiền
//    "Nạp tiền"
//    WITHDRAW(50001), // các giao dịch liên quan tới rút tiền
//    "Rút tiền"
//    TRANSFER(60001), // các giao dịch liên quan tới chuyển tiền
//    "Chuyển tiền"
//    CONVERT(70001), // các giao dịch liên quan tới duyệt tiền chờ duyệt
//    "Chờ duyệt"
    
    var title: String? {
        switch referType {
        case 100:
            return Text.trip.localizedText
        case 40001:
            return Text.topUp.localizedText
        case 50001:
            return Text.withdraw.localizedText
        case 60001:
            return Text.transfers.localizedText
        case 70001:
            return Text.pending.localizedText
        case 80001:
            return Text.referral.localizedText
        default:
            return ""
        }
    }
    
    var amount: Double
    
    var id: Int
    var transactionDate: Double
    var description: String?
    var referId: String?
    let type: Int
    let referType: Int
    let status: Int
    let accountFrom: Int
    let accountTo: Int
    var source: String?
    var groupId: String?
    let after: Double
    
    static func <(lhs: WalletTransactionItem, rhs: WalletTransactionItem) -> Bool {
        let today = Date().timeIntervalSince1970 * 1000
        let d1 = lhs.transactionDate - today
        let d2 = rhs.transactionDate - today
        return d1 < d2
    }
}

struct WalletTransactionsHistoryResponse: Codable {
//    transactions
    // more
    var transactions: [WalletTransactionItem]?
    var more: Bool = false
}

struct ConfigVisaATM: Codable {
    let allowAddCardAtm: Bool
    let allowAddCardVisaMaster: Bool
    
}

