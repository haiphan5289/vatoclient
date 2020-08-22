/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import FwiCore

enum StoreOrderStatus: Int, Codable, Comparable  {
    static func < (lhs: StoreOrderStatus, rhs: StoreOrderStatus) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case CANCELED = 0
    case NEW = 1
    case PENDING_PAYMENT = 2
    case PAYMENT_SUCCESS = 3
    case MERCHANT_ACCEPTED = 4
    case FIND_DRIVER = 5
    case DRIVER_ACCEPTED = 6
    case PICK_SALES_ORDER = 7
    case SHIPPING_SALES_ORDER = 8
    case COMPLETE = 9
    case HAVE_NOT_DRIVER = 10
    case DRIVER_CANCEL = 11
    case CLIENT_CANCEL = 12
    case MERCHANT_CANCEL = 13
    case MERCHANT_DELIVERY = 14
    case PAYMENT_FOR_MERCHANT = 15
    case PROBLEM = 16
    case ERROR = -1
}

extension StoreOrderStatus {
    var canCancelOrder: Bool {
        return (self < .MERCHANT_ACCEPTED && self != .CANCELED)
    }
}

enum StoreOrderState: Int, Codable, Comparable {
    case CANCELED = 0
    case NEW = 1
    case PAYMENT = 2
    case PROCESSING = 3
    case COMPLETE = 4
    case PROBLEM = 5
    
    static func <( lhs: StoreOrderState, rhs: StoreOrderState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var stringValue: String {
        switch self {
        case .CANCELED:
            return "Hủy"
        case .NEW:
            return "Đang xác nhận"
        case .PAYMENT:
            return "Đã xác nhận"
        case .PROCESSING:
            return "Đang chuẩn bị"
        case .COMPLETE:
            return "Hoàn thành"
        case .PROBLEM:
            return "Problem"
        }
    }
    
    var color: UIColor {
        switch self {
        case .NEW, .PAYMENT, .PROCESSING, .PROBLEM:
            return #colorLiteral(red: 0.9588660598, green: 0.4115985036, blue: 0.1715823114, alpha: 1)
        case .COMPLETE:
            return #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1)
        case .CANCELED:
            return #colorLiteral(red: 1, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        }
    }
}

struct SalesOrderShipments: Codable {
    let address: String?
    let discountAmount: Double?
    let id: String?
    let method: Int?
    let methodDesc: String?
    let phone: String?
    let price: Double?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        discountAmount = try values.decodeIfPresent(Double.self, forKey: .discountAmount)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        method = try values.decodeIfPresent(Int.self, forKey: .method)
        methodDesc = try values.decodeIfPresent(String.self, forKey: .methodDesc)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        price = try values.decodeIfPresent(Double.self, forKey: .price)
    }
}

struct SalesOrder : Codable {

	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : String?
	let appliedRuleIds : String?
	let adjustmentNegative : Int?
	let adjustmentPositive : Int?
	let baseAdjustmentNegative : Int?
	let baseAdjustmentPositive : Int?
	let baseDiscountAmount : Int?
	let baseDiscountCanceled : Int?
	let baseDiscountInvoiced : Int?
	let baseDiscountRefunded : Int?
	let baseGrandTotal : Int?
	let baseShippingAmount : Int?
	let baseShippingCanceled : Int?
	let baseShippingDiscountAmount : Int?
	let baseShippingInvoice : Int?
	let baseShippingRefunded : Int?
	let baseSubTotal : Int?
	let baseSubTotalCanceled : Int?
	let baseSubTotalInvoiced : Int?
	let baseSubTotalRefunded : Int?
	let baseToOrderRate : Int?
	let baseTotalCanceled : Int?
	let baseTotalDue : Int?
	let baseTotalInvoiced : Int?
	let baseTotalPaid : Int?
	let baseTotalQtyOrdered : Int?
	let baseTotalRefunded : Int?
	let couponCode : String?
	let customerId : Int?
	let customerNote : String?
	let customerNoteNotify : String?
	let discountAmount : Int?
	let discountCanceled : Int?
	let discountDescription : String?
	let discountInvoice : Int?
	let discountRefunded : Int?
	let grandTotal : Int?
	let codeShip : String?
	let salesOrderAddress : [SalesOrderAddress]?
	let paymentAuthExpiration : Int?
	let state : StoreOrderState?
    var status : StoreOrderStatus?
    let _status: Int?
	let statusDes : String?
	let stateDes : String?
	let storeId : String?
	let storeName : String?
	let subTotal : Int?
	let subTotalInvoice : Int?
	let taxAmount : Int?
	let totalCanceled : Int?
	let totalDue : Int?
	let totalInvoiced : Int?
	let totalItemCount : Int?
	let totalQtyOrdered : Int?
	let totalPaid : Int?
	let totalRefunded : Int?
	let payment : Bool?
	let timePickup : Double?
	let nameShipper : String?
	let phoneShipper : String?
	let orderItems : [OrderItem]?
	let salesOrderShipments : [SalesOrderShipments]?
	let salesOrderPayments : [SalesOrderPayment]?
	let salesOrderStatusHistories : [SalesOrderStatusHistory]?
    let code: String?
    
    var discountShippingFee: Double?
    var vatoDiscountShippingFee: Double?
    var vatoCampaignDiscountInfo: [String: Int]?
    
    var completed: Bool {
        guard let status = state else { return true }
        switch status {
        case .CANCELED, .COMPLETE, .PROBLEM:
            return true
        default:
            return false
        }
    }
    
	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case appliedRuleIds = "appliedRuleIds"
		case adjustmentNegative = "adjustmentNegative"
		case adjustmentPositive = "adjustmentPositive"
		case baseAdjustmentNegative = "baseAdjustmentNegative"
		case baseAdjustmentPositive = "baseAdjustmentPositive"
		case baseDiscountAmount = "baseDiscountAmount"
		case baseDiscountCanceled = "baseDiscountCanceled"
		case baseDiscountInvoiced = "baseDiscountInvoiced"
		case baseDiscountRefunded = "baseDiscountRefunded"
		case baseGrandTotal = "baseGrandTotal"
		case baseShippingAmount = "baseShippingAmount"
		case baseShippingCanceled = "baseShippingCanceled"
		case baseShippingDiscountAmount = "baseShippingDiscountAmount"
		case baseShippingInvoice = "baseShippingInvoice"
		case baseShippingRefunded = "baseShippingRefunded"
		case baseSubTotal = "baseSubTotal"
		case baseSubTotalCanceled = "baseSubTotalCanceled"
		case baseSubTotalInvoiced = "baseSubTotalInvoiced"
		case baseSubTotalRefunded = "baseSubTotalRefunded"
		case baseToOrderRate = "baseToOrderRate"
		case baseTotalCanceled = "baseTotalCanceled"
		case baseTotalDue = "baseTotalDue"
		case baseTotalInvoiced = "baseTotalInvoiced"
		case baseTotalPaid = "baseTotalPaid"
		case baseTotalQtyOrdered = "baseTotalQtyOrdered"
		case baseTotalRefunded = "baseTotalRefunded"
		case couponCode = "couponCode"
		case customerId = "customerId"
		case customerNote = "customerNote"
		case customerNoteNotify = "customerNoteNotify"
		case discountAmount = "discountAmount"
		case discountCanceled = "discountCanceled"
		case discountDescription = "discountDescription"
		case discountInvoice = "discountInvoice"
		case discountRefunded = "discountRefunded"
		case grandTotal = "grandTotal"
		case codeShip = "codeShip"
		case salesOrderAddress = "salesOrderAddress"
		case paymentAuthExpiration = "paymentAuthExpiration"
		case state = "state"
		case status = "status"
		case statusDes = "statusDes"
		case stateDes = "stateDes"
		case storeId = "storeId"
		case storeName = "storeName"
		case subTotal = "subTotal"
		case subTotalInvoice = "subTotalInvoice"
		case taxAmount = "taxAmount"
		case totalCanceled = "totalCanceled"
		case totalDue = "totalDue"
		case totalInvoiced = "totalInvoiced"
		case totalItemCount = "totalItemCount"
		case totalQtyOrdered = "totalQtyOrdered"
		case totalPaid = "totalPaid"
		case totalRefunded = "totalRefunded"
		case payment = "payment"
		case timePickup = "timePickup"
		case nameShipper = "nameShipper"
		case phoneShipper = "phoneShipper"
		case orderItems = "orderItems"
//		case salesOrderShipments = "salesOrderShipments"
		case salesOrderPayments = "salesOrderPayments"
		case salesOrderStatusHistories = "salesOrderStatusHistories"
        case code
        case salesOrderShipments
        case discountShippingFee
        case vatoCampaignDiscountInfo
        case vatoDiscountShippingFee
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		appliedRuleIds = try values.decodeIfPresent(String.self, forKey: .appliedRuleIds)
		adjustmentNegative = try values.decodeIfPresent(Int.self, forKey: .adjustmentNegative)
		adjustmentPositive = try values.decodeIfPresent(Int.self, forKey: .adjustmentPositive)
		baseAdjustmentNegative = try values.decodeIfPresent(Int.self, forKey: .baseAdjustmentNegative)
		baseAdjustmentPositive = try values.decodeIfPresent(Int.self, forKey: .baseAdjustmentPositive)
		baseDiscountAmount = try values.decodeIfPresent(Int.self, forKey: .baseDiscountAmount)
		baseDiscountCanceled = try values.decodeIfPresent(Int.self, forKey: .baseDiscountCanceled)
		baseDiscountInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseDiscountInvoiced)
		baseDiscountRefunded = try values.decodeIfPresent(Int.self, forKey: .baseDiscountRefunded)
		baseGrandTotal = try values.decodeIfPresent(Int.self, forKey: .baseGrandTotal)
		baseShippingAmount = try values.decodeIfPresent(Int.self, forKey: .baseShippingAmount)
		baseShippingCanceled = try values.decodeIfPresent(Int.self, forKey: .baseShippingCanceled)
		baseShippingDiscountAmount = try values.decodeIfPresent(Int.self, forKey: .baseShippingDiscountAmount)
		baseShippingInvoice = try values.decodeIfPresent(Int.self, forKey: .baseShippingInvoice)
		baseShippingRefunded = try values.decodeIfPresent(Int.self, forKey: .baseShippingRefunded)
		baseSubTotal = try values.decodeIfPresent(Int.self, forKey: .baseSubTotal)
		baseSubTotalCanceled = try values.decodeIfPresent(Int.self, forKey: .baseSubTotalCanceled)
		baseSubTotalInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseSubTotalInvoiced)
		baseSubTotalRefunded = try values.decodeIfPresent(Int.self, forKey: .baseSubTotalRefunded)
		baseToOrderRate = try values.decodeIfPresent(Int.self, forKey: .baseToOrderRate)
		baseTotalCanceled = try values.decodeIfPresent(Int.self, forKey: .baseTotalCanceled)
		baseTotalDue = try values.decodeIfPresent(Int.self, forKey: .baseTotalDue)
		baseTotalInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseTotalInvoiced)
		baseTotalPaid = try values.decodeIfPresent(Int.self, forKey: .baseTotalPaid)
		baseTotalQtyOrdered = try values.decodeIfPresent(Int.self, forKey: .baseTotalQtyOrdered)
		baseTotalRefunded = try values.decodeIfPresent(Int.self, forKey: .baseTotalRefunded)
		couponCode = try values.decodeIfPresent(String.self, forKey: .couponCode)
		customerId = try values.decodeIfPresent(Int.self, forKey: .customerId)
		customerNote = try values.decodeIfPresent(String.self, forKey: .customerNote)
		customerNoteNotify = try values.decodeIfPresent(String.self, forKey: .customerNoteNotify)
		discountAmount = try values.decodeIfPresent(Int.self, forKey: .discountAmount)
		discountCanceled = try values.decodeIfPresent(Int.self, forKey: .discountCanceled)
		discountDescription = try values.decodeIfPresent(String.self, forKey: .discountDescription)
		discountInvoice = try values.decodeIfPresent(Int.self, forKey: .discountInvoice)
		discountRefunded = try values.decodeIfPresent(Int.self, forKey: .discountRefunded)
		grandTotal = try values.decodeIfPresent(Int.self, forKey: .grandTotal)
		codeShip = try values.decodeIfPresent(String.self, forKey: .codeShip)
		salesOrderAddress = try values.decodeIfPresent([SalesOrderAddress].self, forKey: .salesOrderAddress)
		paymentAuthExpiration = try values.decodeIfPresent(Int.self, forKey: .paymentAuthExpiration)
		state = try values.decodeIfPresent(StoreOrderState.self, forKey: .state)
        _status = try values.decodeIfPresent(Int.self, forKey: .status)
        status = nil
        if let s = _status {
            self.status = StoreOrderStatus.init(rawValue: s) ?? StoreOrderStatus.ERROR
        }
		statusDes = try values.decodeIfPresent(String.self, forKey: .statusDes)
		stateDes = try values.decodeIfPresent(String.self, forKey: .stateDes)
		storeId = try values.decodeIfPresent(String.self, forKey: .storeId)
		storeName = try values.decodeIfPresent(String.self, forKey: .storeName)
		subTotal = try values.decodeIfPresent(Int.self, forKey: .subTotal)
		subTotalInvoice = try values.decodeIfPresent(Int.self, forKey: .subTotalInvoice)
		taxAmount = try values.decodeIfPresent(Int.self, forKey: .taxAmount)
		totalCanceled = try values.decodeIfPresent(Int.self, forKey: .totalCanceled)
		totalDue = try values.decodeIfPresent(Int.self, forKey: .totalDue)
		totalInvoiced = try values.decodeIfPresent(Int.self, forKey: .totalInvoiced)
		totalItemCount = try values.decodeIfPresent(Int.self, forKey: .totalItemCount)
		totalQtyOrdered = try values.decodeIfPresent(Int.self, forKey: .totalQtyOrdered)
		totalPaid = try values.decodeIfPresent(Int.self, forKey: .totalPaid)
		totalRefunded = try values.decodeIfPresent(Int.self, forKey: .totalRefunded)
		payment = try values.decodeIfPresent(Bool.self, forKey: .payment)
		timePickup = try values.decodeIfPresent(Double.self, forKey: .timePickup)
		nameShipper = try values.decodeIfPresent(String.self, forKey: .nameShipper)
		phoneShipper = try values.decodeIfPresent(String.self, forKey: .phoneShipper)
		orderItems = try values.decodeIfPresent([OrderItem].self, forKey: .orderItems)
//		salesOrderShipments = try values.decodeIfPresent([String].self, forKey: .salesOrderShipments)
		salesOrderPayments = try values.decodeIfPresent([SalesOrderPayment].self, forKey: .salesOrderPayments)
		salesOrderStatusHistories = try values.decodeIfPresent([SalesOrderStatusHistory].self, forKey: .salesOrderStatusHistories)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        salesOrderShipments = try values.decodeIfPresent([SalesOrderShipments].self, forKey: .salesOrderShipments)
        discountShippingFee = try values.decodeIfPresent(Double.self, forKey: .discountShippingFee)
        vatoCampaignDiscountInfo = try values.decodeIfPresent([String: Int].self, forKey: .vatoCampaignDiscountInfo)
        vatoDiscountShippingFee = try values.decodeIfPresent(Double.self, forKey: .vatoDiscountShippingFee)
	}

}


extension SalesOrder: Equatable {
    static func == (lhs: SalesOrder, rhs: SalesOrder) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status && lhs.state == rhs.state
    }
}


extension SalesOrder {
    func timePickUpString() -> String {
        guard let timePickup = self.timePickup else {
            return Text.asSoonAsPossible.localizedText
        }
        
        let date = Date.init(timeIntervalSince1970: timePickup/1000)
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let text = dateFormatter.string(from: date)
        return text
    }
}


extension SalesOrder: BookingHistoryProtocol {
    var waypoints: [PointViewType]? {
        return nil
    }
    
    var dateCreate: Date? {
        if let createAt = self.createdAt {
            return Date(timeIntervalSince1970: TimeInterval(createAt/1000))
        }
        return nil
    }
    
    var originLocation: String? {
        return self.orderItems?.first?.nameStore
    }
    
    var destLocation: String? {
        return self.salesOrderAddress?.first?.address
    }
    
    var serviceName: String? {
        let orderCount = self.orderItems?.count ?? 0
        return "\(FwiLocale.localized("Đồ ăn & Cửa hàng")) • \(orderCount) \(FwiLocale.localized("Món").lowercased())"
    }
    
    var statusStr: String? {
        return self.state?.stringValue
    }
    
    var priceStr: String? {
        return self.grandTotal?.currency
    }
    
    var statusColor: UIColor? {
        return self.state?.color
    }
    
    
}
