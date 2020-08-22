//
//  PlaceModel.swift
//  Vato
//
//  Created by vato. on 7/18/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import CoreLocation

enum FavoritePlaceType: Int, Codable {
    case Home = 1
    case Work = 2
    case Orther = 3
    case AddNew = 4
    
    var priority:Int {
        switch self {
        case .Home:
            return 1000
        case .Work:
            return 999
        case .AddNew:
            return 1001
        default:
            return 1
        }
    }
}


struct PlaceModel: Codable, Comparable {
    var id: Int64?
    var name: String?
    var address: String?
    var typeId: FavoritePlaceType
    var placeId: String?
    
    var lat: String?
    var lon: String?
    let lastUse: TimeInterval
    
    var raw: AddressProtocol?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case typeId
        case placeId
        case lat
        case lon
        case lastUse
    }
    
    var coordinate: CLLocationCoordinate2D {
        guard let lat = Double(lat ?? ""), let lng = Double(lon ?? "") else {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    func getIconName() -> String {
        switch self.typeId {
        case .Home:
            return "ic_booking_home_new"
        case .Work:
            return "ic_booking_work_new"
        case .Orther:
            return "ic_booking_place_save_new"
        case .AddNew:
            return "iconBookingPlaceSavedOrange"
        }
    }
    func getName() -> String? {
        switch self.typeId {
        case .Home:
            return Text.home.localizedText
        case .Work:
            return Text.workNoun.localizedText
        case .Orther:
            return self.name
        case .AddNew:
            return "Địa điểm yêu thích"
        }
    }
    
    var value: Address? {
        guard let lat = lat, let lon = lon else { return nil }
        let coordinate = CLLocationCoordinate2D(latitude: Double(lat) ?? 0 , longitude: Double(lon) ?? 0)

        let result = Address(
         placeId: nil,
         coordinate: coordinate,
         name: address ?? "",
         thoroughfare: "",
         locality: "",
         subLocality: address ?? "",
         administrativeArea: "",
         postalCode: "",
         country: "",
         lines: [],
         zoneId: 0,
         isOrigin: false,
         counter: 0,
         distance: nil, favoritePlaceID: 0)
        return result
    }
    
    static func generateModel(listModelBackend: [PlaceModel]?) -> [PlaceModel] {
        let listDefautNotOther = [
            PlaceModel(id: nil, name: Text.home.localizedText, address: nil, typeId: .Home, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime),
            PlaceModel(id: nil, name: Text.workNoun.localizedText, address: nil, typeId: .Work, lat: nil, lon: nil, lastUse: FireBaseTimeHelper.default.currentTime)
        ]
        guard let listModelBackend = listModelBackend,
            listModelBackend.count > 0 else { return listDefautNotOther }
        
        var result = [PlaceModel]()
        listDefautNotOther.forEach { (model) in
            var resultModel = model
            for index in 0..<listModelBackend.count {
                let modelInListDefault = listModelBackend[index]
                if model.typeId == modelInListDefault.typeId {
                    resultModel = modelInListDefault
                    resultModel.name = model.getName()
                    break
                }
            }
            result.append(resultModel)
        }
        return result
    }
    
    static func == (lhs: PlaceModel, rhs: PlaceModel) -> Bool {
        return lhs.typeId.priority == rhs.typeId.priority
    }
    
    static func < (lhs: PlaceModel, rhs: PlaceModel) -> Bool {
        return lhs.typeId.priority < rhs.typeId.priority
    }
}

extension PlaceModel {
    init(address: AddressProtocol) {
        self.raw = address
        self.lastUse = Date().timeIntervalSince1970
        self.typeId = address.typeKindFavorite
        self.id = address.favoritePlaceID
        self.name = address.nameFavorite
        self.address = address.descriptionFavorite
        self.lat = "\(address.coordinate.latitude)"
        self.lon = "\(address.coordinate.longitude)"
    }
}
