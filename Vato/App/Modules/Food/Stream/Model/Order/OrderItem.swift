/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation


struct OrderItem : Codable, ImageDisplayProtocol {
    var imageURL: String? {
        return images?.components(separatedBy: ";").first
    }
    
    var cacheLocal: Bool { return false }
    
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : String?
	let appliedRuleIds : String?
	let amountRefunded : Int?
	let baseAmountRefunded : Int?
	let baseCost : Int?
	let baseDiscountAmount : Int?
	let baseDiscountInvoice : Int?
	let baseDiscountRefunded : Int?
	let baseOriginalPrice : Int?
	let basePrice : Int?
	let basePriceInclTax : Int?
	let baseRowInvoiced : Int?
	let baseRowTotal : Int?
	let baseRowTotalInclTax : Int?
	let baseTaxAmount : Int?
	let baseTaxBeforeDiscount : Int?
	let baseTaxInvoiced : Int?
	let baseTaxRefunded : Int?
	let description : String?
	let discountAmount : Int?
	let discountInvoiced : Int?
	let discountPercent : Int?
	let discountRefunded : Int?
	let storeId : Int?
	let qty : Int?
	let productId : Int?
	let name : String?
	let nameStore : String?
	let addressStore : String?
	let phoneStore : String?
	let salesOrderItemOptions : String?
	let available : Bool?
    let images: String?
	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case appliedRuleIds = "appliedRuleIds"
		case amountRefunded = "amountRefunded"
		case baseAmountRefunded = "baseAmountRefunded"
		case baseCost = "baseCost"
		case baseDiscountAmount = "baseDiscountAmount"
		case baseDiscountInvoice = "baseDiscountInvoice"
		case baseDiscountRefunded = "baseDiscountRefunded"
		case baseOriginalPrice = "baseOriginalPrice"
		case basePrice = "basePrice"
		case basePriceInclTax = "basePriceInclTax"
		case baseRowInvoiced = "baseRowInvoiced"
		case baseRowTotal = "baseRowTotal"
		case baseRowTotalInclTax = "baseRowTotalInclTax"
		case baseTaxAmount = "baseTaxAmount"
		case baseTaxBeforeDiscount = "baseTaxBeforeDiscount"
		case baseTaxInvoiced = "baseTaxInvoiced"
		case baseTaxRefunded = "baseTaxRefunded"
		case description = "description"
		case discountAmount = "discountAmount"
		case discountInvoiced = "discountInvoiced"
		case discountPercent = "discountPercent"
		case discountRefunded = "discountRefunded"
		case storeId = "storeId"
		case qty = "qty"
		case productId = "productId"
		case name = "name"
		case nameStore = "nameStore"
		case addressStore = "addressStore"
		case phoneStore = "phoneStore"
		case salesOrderItemOptions = "salesOrderItemOptions"
		case available = "available"
        case images = "images"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		appliedRuleIds = try values.decodeIfPresent(String.self, forKey: .appliedRuleIds)
		amountRefunded = try values.decodeIfPresent(Int.self, forKey: .amountRefunded)
		baseAmountRefunded = try values.decodeIfPresent(Int.self, forKey: .baseAmountRefunded)
		baseCost = try values.decodeIfPresent(Int.self, forKey: .baseCost)
		baseDiscountAmount = try values.decodeIfPresent(Int.self, forKey: .baseDiscountAmount)
		baseDiscountInvoice = try values.decodeIfPresent(Int.self, forKey: .baseDiscountInvoice)
		baseDiscountRefunded = try values.decodeIfPresent(Int.self, forKey: .baseDiscountRefunded)
		baseOriginalPrice = try values.decodeIfPresent(Int.self, forKey: .baseOriginalPrice)
		basePrice = try values.decodeIfPresent(Int.self, forKey: .basePrice)
		basePriceInclTax = try values.decodeIfPresent(Int.self, forKey: .basePriceInclTax)
		baseRowInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseRowInvoiced)
		baseRowTotal = try values.decodeIfPresent(Int.self, forKey: .baseRowTotal)
		baseRowTotalInclTax = try values.decodeIfPresent(Int.self, forKey: .baseRowTotalInclTax)
		baseTaxAmount = try values.decodeIfPresent(Int.self, forKey: .baseTaxAmount)
		baseTaxBeforeDiscount = try values.decodeIfPresent(Int.self, forKey: .baseTaxBeforeDiscount)
		baseTaxInvoiced = try values.decodeIfPresent(Int.self, forKey: .baseTaxInvoiced)
		baseTaxRefunded = try values.decodeIfPresent(Int.self, forKey: .baseTaxRefunded)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		discountAmount = try values.decodeIfPresent(Int.self, forKey: .discountAmount)
		discountInvoiced = try values.decodeIfPresent(Int.self, forKey: .discountInvoiced)
		discountPercent = try values.decodeIfPresent(Int.self, forKey: .discountPercent)
		discountRefunded = try values.decodeIfPresent(Int.self, forKey: .discountRefunded)
		storeId = try values.decodeIfPresent(Int.self, forKey: .storeId)
		qty = try values.decodeIfPresent(Int.self, forKey: .qty)
		productId = try values.decodeIfPresent(Int.self, forKey: .productId)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		nameStore = try values.decodeIfPresent(String.self, forKey: .nameStore)
		addressStore = try values.decodeIfPresent(String.self, forKey: .addressStore)
		phoneStore = try values.decodeIfPresent(String.self, forKey: .phoneStore)
		salesOrderItemOptions = try values.decodeIfPresent(String.self, forKey: .salesOrderItemOptions)
		available = try values.decodeIfPresent(Bool.self, forKey: .available)
        images = try values.decodeIfPresent(String.self, forKey: .images)
	}

}

extension OrderItem: Equatable {
    static func == (lhs: OrderItem, rhs: OrderItem) -> Bool {
        return lhs.id == rhs.id
    }
}
