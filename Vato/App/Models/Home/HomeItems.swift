/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import Kingfisher

enum VatoServiceAction: Int, Codable {
    case car = 202
    case bike = 201
    case delivery = 204
    case location = 205
    case buyTicket = 206
    case taxi = 203
    case beauty = 207
    case medicine = 208
    case shop = 209
    case erp = 213
    case hotel = 210
    case more = 212
    case supply = 290
    
    var categoryService: ServiceCategoryType? {
        switch self {
        case .location:
            return .food
        case .beauty:
            return .beauty
        case .medicine:
            return .medicine
        case .shop:
            return .shop
        case .erp:
            return .market
        case .hotel:
            return .hotel
        case .supply:
            return .supply
        case .more:
            return nil
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .car:
            return Text.car.localizedText
        case .bike:
            return Text.bike.localizedText
        case .delivery:
            return Text.delivery.localizedText
        case .buyTicket:
            return Text.buyTicket.localizedText
        case .location:
            return Text.location.localizedText
        case .taxi:
            return Text.taxi.localizedText
        case .beauty:
            return Text.beauty.localizedText
        case .medicine:
            return Text.medicine.localizedText
        case .shop, .supply:
            return Text.shop.localizedText
        default:
            return ""
        }
    }
    
    var image: UIImage? {
        switch self {
        case .car:
            return UIImage(named: "ic_home_car_s")
        case .bike:
            return UIImage(named: "ic_home_bike_s")
        case .delivery:
            return UIImage(named: "ic_home_delivery_s")
        case .buyTicket:
            return UIImage(named: "ic_home_ticket_s")
        case .location:
            return UIImage(named: "ic_home_location_s")
        case .taxi:
            return UIImage(named: "ic_home_taxi_s")
        case .beauty:
            return UIImage(named: "ic_beauty_s")
        case .medicine:
            return UIImage(named: "ic_medicine_s")
        case .shop:
            return UIImage(named: "ic_shop_s")
        case .erp:
            return UIImage(named: "ic_erp")
        case .supply:
            return UIImage(named: "ic_market_s")
        case .hotel:
            return UIImage(named: "ic_hotel_s")
        case .more:
            return UIImage(named: "ic_more_s")
        }
    }
    
    var serice: VatoServiceType? {
        switch self {
        case .car:
            return .car
        case .bike:
            return .moto
        case .delivery:
            return .delivery
        case .taxi:
            return .taxi
        case .buyTicket:
            return .buyTicket
        default:
            return nil
        }
    }
}

enum VatoPayAction: Int, Codable {
    case topup = 103
    case transaction = 104
    case promotion = 105
    case scanQR = 106
    case support = 107
    case wallet = -1
    case profile = 0
    
    var title: String {
        switch self {
        case .topup:
            return Text.topUp.localizedText
        case .transaction:
            return Text.transactions.localizedText
        case .promotion:
            return Text.promotion.localizedText
        case .wallet, .scanQR, .support, .profile:
            return ""
        }
    }
    
    var image: UIImage? {
        switch self {
        case .topup:
            return UIImage(named: "ic_home_topup")
        case .transaction:
            return UIImage(named: "ic_home_transaction")
        case .promotion:
            return UIImage(named: "ic_home_voucher")
        case .scanQR:
            return UIImage(named: "ic_qr")
        case .wallet, .support, .profile:
            return nil
        }
    }
}

struct ERPItem: Codable {
    var new_notifications: Int
    var url: String
}

struct HomeItems : Codable, Comparable, Hashable {
	let id : Int?
	let title : String?
	let imageURL : String?
	let description : String?
	let active : Int?
	let data : String?
    var isNew: Bool?
    var erp: ERPItem?
    var name: String?

    var isActived: Bool {
        #if DEBUG
            return self.active == 1
        #elseif STAGING
            return true
        #else
            return self.active == 1
        #endif
    }
    
	enum CodingKeys: String, CodingKey {

		case id = "id"
		case title = "title"
		case imageURL = "imageURL"
		case description = "description"
		case active = "active"
		case data = "data"
        case name
        case isNew
	}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(active, forKey: .active)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(isNew, forKey: .isNew)
        try container.encodeIfPresent(name, forKey: .name)
    }

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        if let v1 = try? values.decode(String.self, forKey: .id), let v = Int(v1) {
            id = v
        } else {
            id = try values.decodeIfPresent(Int.self, forKey: .id)
        }
		title = try values.decodeIfPresent(String.self, forKey: .title)
		imageURL = try values.decodeIfPresent(String.self, forKey: .imageURL)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		active = try values.decodeIfPresent(Int.self, forKey: .active)
        do {
            data = try values.decodeIfPresent(String.self, forKey: .data)
        } catch {
            data = nil
        }
        
        ERP: if let d = data, !d.isEmpty {
            
            guard let dataERP = d.data(using: .utf8) else {
                break ERP
            }
            
            do {
                erp = try ERPItem.toModel(from: dataERP)
            } catch {
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
        
        name = try values.decodeIfPresent(String.self, forKey: .name)
        isNew = try values.decodeIfPresent(Bool.self, forKey: .isNew)
	}
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id ?? 0)
        hasher.combine(active)
    }
    
    static func ==(lhs: HomeItems, rhs: HomeItems) -> Bool {
        return lhs.id == rhs.id && lhs.active == rhs.active
    }
    
    static func <(lhs: HomeItems, rhs: HomeItems) -> Bool {
        let i1 = lhs.id ?? 0
        let i2 = rhs.id ?? 0
        return i1 < i2
    }
}

extension HomeItems: ImageDisplayProtocol {
    var sourceImage: Source? {
        guard let url = URL(string: imageURL ?? "") else {
            return nil
        }
        return .network(url)
    }
    
    var cacheLocal: Bool { return true }
}

struct HomeResponse : Codable, Comparable {
    var layout_type : Int = -1
    let id: Int?
    let name : String?
    let active : Int?
    let items : [HomeItems]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case layout_type = "layout_type"
        case name = "name"
        case active = "active"
        case items = "items"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        if let type = try values.decodeIfPresent(Int.self, forKey: .layout_type) {
            layout_type = type
        }
        name = try values.decodeIfPresent(String.self, forKey: .name)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        items = try values.decodeIfPresent([HomeItems].self, forKey: .items)
    }
    
    static func ==(lhs: HomeResponse, rhs: HomeResponse) -> Bool {
        let l1 = (lhs.items ?? []).sorted(by: <)
        let l2 = (rhs.items ?? []).sorted(by: <)
        var check = l1.count == l2.count
        if check {
            var d = true
            var i = 0
            Compare: while i < l1.count {
                let i1 = l1[i]
                let i2 = l2[i]
                if i1 != i2 {
                    d = false
                    break Compare
                }
                i += 1
            }
            
            check = d
        }
        
        
        return lhs.id == rhs.id && lhs.active == rhs.active && check
    }
    
    static func < (lhs: HomeResponse, rhs: HomeResponse) -> Bool {
        return (lhs.id ?? 0) < (rhs.id ?? 0)
    }
    
}

