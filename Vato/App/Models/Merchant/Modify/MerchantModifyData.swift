/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct MerchantModifyData : Codable {
	var attributes : [MerchantAttributeData]?
	var avatarUrl : String?
	var categoryId : Int?
	var description : String?
	var name : String?
	var ownerId : Int?
	var phoneNumber : String?
	var shortDescription : String?
	var typeCode : String?

	enum CodingKeys: String, CodingKey {
		case attributes = "attributes"
		case avatarUrl = "avatarUrl"
		case categoryId = "categoryId"
		case description = "description"
		case name = "name"
		case ownerId = "ownerId"
		case phoneNumber = "phoneNumber"
		case shortDescription = "shortDescription"
		case typeCode = "typeCode"
	}
    
    init() {
        
    }
    
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		attributes = try values.decodeIfPresent([MerchantAttributeData].self, forKey: .attributes)
		avatarUrl = try values.decodeIfPresent(String.self, forKey: .avatarUrl)
		categoryId = try values.decodeIfPresent(Int.self, forKey: .categoryId)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		ownerId = try values.decodeIfPresent(Int.self, forKey: .ownerId)
		phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
		shortDescription = try values.decodeIfPresent(String.self, forKey: .shortDescription)
		typeCode = try values.decodeIfPresent(String.self, forKey: .typeCode)
	}

}
