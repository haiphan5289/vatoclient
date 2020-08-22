//
//  SeatModel.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/9/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

/*
 “bookStatus”: 1 - vé đang được book, 0 không book
 “chair”: tên ghế ví dụ A05
 “columnNo”: dùng vẽ sơ đồ (cột)
 “discount”: giảm giá,
 “floorNo”: tầng 1, 2
 “id”: id vé
 “inSelect”: ghế đang được chọn 1 được chọn, 0 không chọn
 “lockChair”: 1 ghế bị khoá, 0 không khoá
 “rowNo”: dùng vẽ sơ đồ (dòng)
 */

struct SeatModel: Codable {

    var bookStatus      : Int?
    var chair           : String?
    var columnNo        : Int?
    var discount        : Double?
    var originPrice     : Double?
    var price           : Double?
    var floorNo         : Int?
    var id              : Int32?
    var inSelect        : Int?
    var lockChair       : Int?
    var rowNo           : Int?
    
    var position: Position {
        return Position(x: rowNo ?? 0, y: columnNo ?? 0)
    }
    
    var isSelectable: Bool {
        let bookStatus = self.bookStatus ?? 0
        let lockChair = self.lockChair ?? 0
        let inSelect = self.inSelect ?? 0
        return bookStatus == 0 && lockChair == 0 && inSelect == 0
    }
    var promotion       : PromotionTicket?
    
    enum CodingKeys: String, CodingKey {
        
        case bookStatus = "bookStatus"
        case chair = "chair"
        case columnNo = "columnNo"
        case discount = "discount"
        case floorNo = "floorNo"
        case id = "id"
        case inSelect = "inSelect"
        case lockChair = "lockChair"
        case rowNo = "rowNo"
        case promotion = "promotion"
        case originPrice = "originPrice"
        case price = "price"
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bookStatus = try values.decodeIfPresent(Int.self, forKey: .bookStatus)
        chair = try values.decodeIfPresent(String.self, forKey: .chair)
        columnNo = try values.decodeIfPresent(Int.self, forKey: .columnNo)
        discount = try values.decodeIfPresent(Double.self, forKey: .discount)
        floorNo = try values.decodeIfPresent(Int.self, forKey: .floorNo)
        id = try values.decodeIfPresent(Int32.self, forKey: .id)
        inSelect = try values.decodeIfPresent(Int.self, forKey: .inSelect)
        lockChair = try values.decodeIfPresent(Int.self, forKey: .lockChair)
        rowNo = try values.decodeIfPresent(Int.self, forKey: .rowNo)
        promotion = try values.decodeIfPresent(PromotionTicket.self, forKey: .promotion)
        originPrice = try values.decodeIfPresent(Double.self, forKey: .originPrice)
        price = try values.decodeIfPresent(Double.self, forKey: .price)
        
        
    }
}
