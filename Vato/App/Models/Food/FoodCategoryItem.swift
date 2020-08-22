/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

struct FoodCategoryResponse: Codable, Comparable, CategoryRequestProtocol {
    var hasChildren: Bool {
        let items = children ?? []
        return !items.isEmpty
    }
    
    var id: Int?
    var name: String?
    var children: [FoodCategoryItem]?
    var catImage: [String]?
    var status: Int?
    var parentId: Int?
    
    static func < (lhs: FoodCategoryResponse, rhs: FoodCategoryResponse) -> Bool {
        let id1 = lhs.id ?? 0
        let id2 = rhs.id ?? 0
        
        return id1 < id2
    }
    
    static func == (lhs: FoodCategoryResponse, rhs: FoodCategoryResponse) -> Bool {
        let id1 = lhs.id ?? 0
        let id2 = rhs.id ?? 0
        
        return id1 == id2
    }
}


struct FoodCategoryItem : Codable, Comparable, ImageDisplayProtocol {
    var imageURL: String? {
        return iconUrl //catImage?.first
    }
	var createdBy : Double?
	var updatedBy : Double?
	var createdAt : Double?
	var updatedAt : Double?
	var id : Int?
	var name : String?
    var children : [MerchantCategory]?
	var catImage : [String]?
	var toggled : Bool?
	var status : Int?
	var parentId : Int?
    var iconUrl: String?
    var local: Bool = true
    var cacheLocal: Bool { return false }
	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case name = "name"
        case children = "children"
		case catImage = "catImage"
		case toggled = "toggled"
		case status = "status"
		case parentId = "parentId"
        case iconUrl = "iconUrl"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
        children = try values.decodeIfPresent([MerchantCategory].self, forKey: .children)
		catImage = try values.decodeIfPresent([String].self, forKey: .catImage)
		toggled = try values.decodeIfPresent(Bool.self, forKey: .toggled)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		parentId = try values.decodeIfPresent(Int.self, forKey: .parentId)
        iconUrl = try values.decodeIfPresent(String.self, forKey: .iconUrl)
        local = false
	}
    
    static func < (lhs: FoodCategoryItem, rhs: FoodCategoryItem) -> Bool {
        let id1 = lhs.id ?? 0
        let id2 = rhs.id ?? 0
        
        return id1 < id2
    }
    
    static func == (lhs: FoodCategoryItem, rhs: FoodCategoryItem) -> Bool {
        let id1 = lhs.id ?? 0
        let id2 = rhs.id ?? 0
        
        return id1 == id2
    }
    
    init() {}

}
