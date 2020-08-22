/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

enum MerchantAttributeElementType: String, Codable {
    case TEXT
    case IMAGE
    case IMAGE_LIST
    case TEXT_AREA
    case MULTI_SELECT
    case CATEGORY
    case DOUBLE
    case BOOLEAN
    case DATE
    case SELECT
}

extension MerchantAttributeElementType {
    var keyboardType: UIKeyboardType {
        switch self {
        case .DOUBLE:
            return .numberPad
        default:
            return .default
        }
    }
}

struct MerchantAttributeElementValue: Codable {
    let id: Int?
    let label: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case label = "label"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        label = try values.decodeIfPresent(String.self, forKey: .label)
    }
}

struct MerchantAttributeElement : Codable {
	let code : String?
	let label : String?
	let isRequired : Bool?
	let sortOrder : Int?
	let type : MerchantAttributeElementType?
    let values: [MerchantAttributeElementValue]?
    
	enum CodingKeys: String, CodingKey {

		case code = "code"
		case label = "label"
		case isRequired = "isRequired"
		case sortOrder = "sortOrder"
		case type = "type"
        case values = "values"
	}

	init(from decoder: Decoder) throws {
		let decodeValues = try decoder.container(keyedBy: CodingKeys.self)
		code = try decodeValues.decodeIfPresent(String.self, forKey: .code)
		label = try decodeValues.decodeIfPresent(String.self, forKey: .label)
		isRequired = try decodeValues.decodeIfPresent(Bool.self, forKey: .isRequired)
		sortOrder = try decodeValues.decodeIfPresent(Int.self, forKey: .sortOrder)
        
		type = try decodeValues.decodeIfPresent(MerchantAttributeElementType.self, forKey: .type)
        values = try decodeValues.decodeIfPresent([MerchantAttributeElementValue].self, forKey: .values)
	}

}


struct ProductAttributeVisibility: CategoryDisplayItemView {
    var name: String?
    var id: Int?
}

enum ProductAttributeVisibilityEnum: Int {
    case NOT_VISIBLE_INDIVIDUALLY = 1
    case CATALOG = 2
    case SEARCH = 3
    case CATALOG_SEARCH = 4
    
    var stringValue : String {
        switch self {
        case .NOT_VISIBLE_INDIVIDUALLY:
            return "Không hiển thị độc lập"
        case .CATALOG:
            return "Danh mục"
        case .SEARCH:
            return "Tìm kiếm"
        case .CATALOG_SEARCH:
            return "Danh mục và tìm kiếm"
        }
    }
    
    static var allCases: [ProductAttributeVisibilityEnum] {
        return [.NOT_VISIBLE_INDIVIDUALLY, .CATALOG, .SEARCH, .CATALOG_SEARCH]
    }
}

