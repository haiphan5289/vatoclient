

import Foundation
struct Store : Codable {
	let createdBy : Double?
	let updatedBy : Double?
	let createdAt : Double?
	let updatedAt : Double?
	let id : Int?
	let name : String?
	let address : String?
	let lat : Double?
	let lon : Double?
	let bannerImage : [String]?
	let otherImage : [String]?
	let phoneNumber : String?
	var workingHours : FoodWorkingHours?
	let status : Int?
    let zoneName : String?
    let zoneId : Int?
    let urlRefer: String?
    let category: [MerchantCategory]?
    
	enum CodingKeys: String, CodingKey {

		case createdBy = "createdBy"
		case updatedBy = "updatedBy"
		case createdAt = "createdAt"
		case updatedAt = "updatedAt"
		case id = "id"
		case name = "name"
		case address = "address"
		case lat = "lat"
		case lon = "lon"
		case bannerImage = "bannerImage"
		case otherImage = "otherImage"
		case phoneNumber = "phoneNumber"
		case workingHours = "workingHours"
		case status = "status"
        case zoneName = "zoneName"
        case zoneId = "zoneId"
        case urlRefer = "urlRefer"
        case category = "category"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		createdBy = try values.decodeIfPresent(Double.self, forKey: .createdBy)
		updatedBy = try values.decodeIfPresent(Double.self, forKey: .updatedBy)
		createdAt = try values.decodeIfPresent(Double.self, forKey: .createdAt)
		updatedAt = try values.decodeIfPresent(Double.self, forKey: .updatedAt)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		lat = try values.decodeIfPresent(Double.self, forKey: .lat)
		lon = try values.decodeIfPresent(Double.self, forKey: .lon)
		bannerImage = try values.decodeIfPresent([String].self, forKey: .bannerImage)
		otherImage = try values.decodeIfPresent([String].self, forKey: .otherImage)
		phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)

        if let w = try values.decodeIfPresent(String.self, forKey: .workingHours), let data = w.data(using: .utf8) {
            let json = (try JSONSerialization.jsonObject(with: data, options: [])) as? JSON
            do {
                workingHours = try WorkingHoursType.toModel(from: json)
            } catch {
                print(error.localizedDescription)
            }
            
        }
//        workingHours = try values.decodeIfPresent(FoodWorkingHours.self, forKey: .workingHours)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
        zoneName = try values.decodeIfPresent(String.self, forKey: .zoneName)
        zoneId = try values.decodeIfPresent(Int.self, forKey: .zoneId)
        urlRefer = try values.decodeIfPresent(String.self, forKey: .urlRefer)
        category = try values.decodeIfPresent([MerchantCategory].self, forKey: .category)
	}
}
