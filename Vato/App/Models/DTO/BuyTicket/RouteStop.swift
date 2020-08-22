
import Foundation
struct RouteStop : Codable {
	var address : String?
	var code : String?
	var distance : Double?
	var duration : Double?
	var fax : String?
	var id : Int?
	var latitude : Double?
	var longitude : Double?
	var name : String?
	var note : String?
	var officeId : Int?
	var orderNumber : Int?
	var passing : Bool?
	var phone : String?
	var routeId : Int?
	var shuttleBefore : Int?
	var type : Int?
	var wayId : Int?

	enum CodingKeys: String, CodingKey {

		case address = "address"
		case code = "code"
		case distance = "distance"
		case duration = "duration"
		case fax = "fax"
		case id = "id"
		case latitude = "latitude"
		case longitude = "longitude"
		case name = "name"
		case note = "note"
		case officeId = "officeId"
		case orderNumber = "orderNumber"
		case passing = "passing"
		case phone = "phone"
		case routeId = "routeId"
		case shuttleBefore = "shuttleBefore"
		case type = "type"
		case wayId = "wayId"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		distance = try values.decodeIfPresent(Double.self, forKey: .distance)
		duration = try values.decodeIfPresent(Double.self, forKey: .duration)
		fax = try values.decodeIfPresent(String.self, forKey: .fax)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
		longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		note = try values.decodeIfPresent(String.self, forKey: .note)
		officeId = try values.decodeIfPresent(Int.self, forKey: .officeId)
		orderNumber = try values.decodeIfPresent(Int.self, forKey: .orderNumber)
		passing = try values.decodeIfPresent(Bool.self, forKey: .passing)
		phone = try values.decodeIfPresent(String.self, forKey: .phone)
		routeId = try values.decodeIfPresent(Int.self, forKey: .routeId)
		shuttleBefore = try values.decodeIfPresent(Int.self, forKey: .shuttleBefore)
		type = try values.decodeIfPresent(Int.self, forKey: .type)
		wayId = try values.decodeIfPresent(Int.self, forKey: .wayId)
	}

}

extension RouteStop {
    init(with ticket: TicketInformation?) {
        name = ticket?.routeStopName
        address = ticket?.routeStopAddress
        id = ticket?.routeStopId
    }
}
