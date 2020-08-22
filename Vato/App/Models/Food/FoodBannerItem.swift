/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
enum FoodBannerType: Int, Codable {
    case store = 1
    case product = 2
    case listing = 3
}

struct FoodBannerAction {
    var type: FoodBannerType
    var targetId: Int
    
    init?(type: FoodBannerType?, targetId: Int?) {
        guard let type = type, let targetId = targetId else {
            return nil
        }
        self.type = type
        self.targetId = targetId
    }
    
}

struct FoodBannerItem : Codable, ImageDisplayProtocol {
    var imageURL: String? {
        return imgUrl
    }
    var cacheLocal: Bool { return false }
	let createdBy : TimeInterval?
	let updatedBy : TimeInterval?
	let createdAt : TimeInterval?
	let updatedAt : TimeInterval?
	let id : Int?
	let name : String?
	let imgUrl : String?
	let targetPath : String?
	let sortOrder : Int?
	let startDate : String?
	let endDate : String?
	let status : Bool?
    var type: FoodBannerType?
    var targetId: Int?
    
    var action: FoodBannerAction? {
        return FoodBannerAction(type: type, targetId: targetId)
    }

	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case name = "name"
		case imgUrl = "imgUrl"
		case targetPath = "targetPath"
		case sortOrder = "sortOrder"
		case startDate = "startDate"
		case endDate = "endDate"
		case status = "status"
        case type = "type"
        case targetId = "targetId"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        if let date = try values.decodeIfPresent(TimeInterval.self, forKey: .createdBy) {
            createdBy = date / 1000
        } else {
            createdBy = nil
        }
        if let date = try values.decodeIfPresent(TimeInterval.self, forKey: .createdBy) {
            updatedBy = date / 1000
        } else {
            updatedBy = nil
        }
        if let date = try values.decodeIfPresent(TimeInterval.self, forKey: .createdBy) {
            createdAt = date / 1000
        } else {
            createdAt = nil
        }
        if let date = try values.decodeIfPresent(TimeInterval.self, forKey: .createdBy) {
            updatedAt = date / 1000
        } else {
            updatedAt = nil
        }
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		imgUrl = try values.decodeIfPresent(String.self, forKey: .imgUrl)
		targetPath = try values.decodeIfPresent(String.self, forKey: .targetPath)
		sortOrder = try values.decodeIfPresent(Int.self, forKey: .sortOrder)
		startDate = try values.decodeIfPresent(String.self, forKey: .startDate)
		endDate = try values.decodeIfPresent(String.self, forKey: .endDate)
		status = try values.decodeIfPresent(Bool.self, forKey: .status)
        
        if let t = try values.decodeIfPresent(Int.self, forKey: .type), let v = FoodBannerType(rawValue: t)  {
            type = v
        }
        
        targetId = try values.decodeIfPresent(Int.self, forKey: .targetId)
	}

}
