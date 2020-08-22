/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct ScanQRResult : Codable {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : Int?
	let active : Bool?
	let expired : Bool?
	let userId : Int?
	let masterId : Int?
	let promotionPredicateId : Int?
	let code : String?
	let total : Int?
	let perDay : Int?
	let current : Int?
	let currentToday : Int?
	let manifestId : Int?
	let startDate : Int?
	let endDate : Int?
	let startTime : Double?
	let endTime : Double?
	let priority : Int?

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case active = "active"
		case expired = "expired"
		case userId = "userId"
		case masterId = "masterId"
		case promotionPredicateId = "promotionPredicateId"
		case code = "code"
		case total = "total"
		case perDay = "perDay"
		case current = "current"
		case currentToday = "currentToday"
		case manifestId = "manifestId"
		case startDate = "startDate"
		case endDate = "endDate"
		case startTime = "startTime"
		case endTime = "endTime"
		case priority = "priority"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		active = try values.decodeIfPresent(Bool.self, forKey: .active)
		expired = try values.decodeIfPresent(Bool.self, forKey: .expired)
		userId = try values.decodeIfPresent(Int.self, forKey: .userId)
		masterId = try values.decodeIfPresent(Int.self, forKey: .masterId)
		promotionPredicateId = try values.decodeIfPresent(Int.self, forKey: .promotionPredicateId)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		total = try values.decodeIfPresent(Int.self, forKey: .total)
		perDay = try values.decodeIfPresent(Int.self, forKey: .perDay)
		current = try values.decodeIfPresent(Int.self, forKey: .current)
		currentToday = try values.decodeIfPresent(Int.self, forKey: .currentToday)
		manifestId = try values.decodeIfPresent(Int.self, forKey: .manifestId)
		startDate = try values.decodeIfPresent(Int.self, forKey: .startDate)
		endDate = try values.decodeIfPresent(Int.self, forKey: .endDate)
		startTime = try values.decodeIfPresent(Double.self, forKey: .startTime)
		endTime = try values.decodeIfPresent(Double.self, forKey: .endTime)
		priority = try values.decodeIfPresent(Int.self, forKey: .priority)
	}

}
