
//
//  MerchantList.swift
//  Vato
//
//  Created by khoi tran on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

enum MerchantStatus: Int, Decodable {
    case inited = 1
    case waitingApprove = 2
    case reject = 4
    case approved = 3
    
    func stringValue() -> String {
        switch self {
        case .inited:
            return "Khởi tạo"
        case .waitingApprove:
            return "Đang chờ duyệt"
        case .reject:
            return "Từ chối"
        case .approved:
            return "Đã duyệt"
        }
    }
    
    func getIcon() -> UIImage? {
        switch self {
        case .inited:
            return UIImage(named: "ic_merchant_inited")
        case .waitingApprove:
            return UIImage(named: "ic_merchant_waitingApprove")
        case .reject:
            return UIImage(named: "ic_merchant_reject")
        case .approved:
            return UIImage(named: "ic_merchant_approved")
        }
    }
    
    func getTextColor() -> UIColor {
        switch self {
        case .inited:
            return UIColor(red: 162/255, green: 171/255, blue: 179/255, alpha: 1.0)
        case .waitingApprove:
            return UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1.0)
        case .reject:
            return UIColor(red: 225/255, green: 36/255, blue: 36/255, alpha: 1.0)
        case .approved:
            return UIColor(red: 76/255, green: 181/255, blue: 8/255, alpha: 1.0)
        }
    }
}

enum StoreStatus: Int, Decodable {
    case inited = 1
    case waitingApprove = 2
    case reject = 3
    case approved = 4
    
    func stringValue() -> String {
        switch self {
        case .inited:
            return "Khởi tạo"
        case .waitingApprove:
            return "Đang chờ duyệt"
        case .reject:
            return "Từ chối"
        case .approved:
            return "Đã duyệt"
        }
    }
    
    func getIcon() -> UIImage? {
        switch self {
        case .inited:
            return UIImage(named: "ic_merchant_inited")
        case .waitingApprove:
            return UIImage(named: "ic_merchant_waitingApprove")
        case .reject:
            return UIImage(named: "ic_merchant_reject")
        case .approved:
            return UIImage(named: "ic_merchant_approved")
        }
    }
    
    func getTextColor() -> UIColor {
        switch self {
        case .inited:
            return UIColor(red: 162/255, green: 171/255, blue: 179/255, alpha: 1.0)
        case .waitingApprove:
            return UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1.0)
        case .reject:
            return UIColor(red: 225/255, green: 36/255, blue: 36/255, alpha: 1.0)
        case .approved:
            return UIColor(red: 76/255, green: 181/255, blue: 8/255, alpha: 1.0)
        }
    }
}



protocol MerchantInfoDisplayProtocol {
    var id: String? { get }
    var iconUrl: String? { get }
    var merchantName: String? { get }
    var status: Int? { get }
}



protocol StoreInfoDisplayProtocol {
    var storeName: String { get }
    var address: String? { get }
    var status: Int { get }
    var lat: String? { get }
    var long: String? { get }
    var activeTime: [ActiveTime]? { get }
}

struct MerchantInfoDisplay: MerchantInfoDisplayProtocol {
    var id: String?
    var iconUrl: String?
    var merchantName: String?
    var status: Int?
}






