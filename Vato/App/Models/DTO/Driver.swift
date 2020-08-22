//  File name   : Driver.swift
//
//  Author      : Dung Vu
//  Created date: 1/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
//@property(strong, nonatomic) FCUser* user;
//@property(strong, nonatomic) NSString* code;
//@property(strong, nonatomic) FCUCar* vehicle;
//@property(assign, nonatomic) BOOL active;
//@property(strong, nonatomic) NSString* deviceToken;
//@property(strong, nonatomic) NSString* currentVersion;
//@property(strong, nonatomic) NSString* group;
//@property(assign, nonatomic) long long created;
//@property(strong, nonatomic) NSString* topic;
//@property(strong, nonatomic) FCDevice* deviceInfo;


//@property (nonatomic, assign) NSInteger id;
//@property (nonatomic, assign) NSInteger createdBy;
//@property (nonatomic, assign) NSInteger updatedBy;
//@property (nonatomic, assign) NSInteger createdAt;
//@property (nonatomic, assign) NSInteger updatedAt;
//@property (nonatomic, assign) NSInteger identifier;
//@property (nonatomic, assign) NSInteger type;
//@property (nonatomic, assign) NSInteger rank;
//@property (nonatomic, assign) NSInteger ownerId;
//@property (nonatomic, copy)   NSString *plate;
//@property (nonatomic, copy)   NSString *color;
//@property (nonatomic, copy)   NSString *brand;
//@property (nonatomic, copy)   NSString *marketName;
//@property (nonatomic, copy)   NSString *registrationCertificateId;
//@property (nonatomic, copy)   NSString *inspectionCertificateId;
//@property (nonatomic, copy)   NSString *operatingCertificateId;
//@property (nonatomic, copy)   NSString *imageUrl;
//
//@property (nonatomic, assign) NSInteger service;
//@property (nonatomic, copy)   NSString *serviceName;
//@property (nonatomic, copy)   NSString* colorCode;

//@property(nonatomic, strong) NSString*  id;
//@property(nonatomic, strong) NSString*  version;
//@property(nonatomic, strong) NSString*  model;
//@property(nonatomic, strong) NSString*  name;

struct Vehicle: Codable {
    let id: UInt64
    let identifier: Int
    let type: Int
    let rank: Double
    let ownerId: Int
    var plate: String?
    var color: String?
    var brand: String?
    var marketName: String?
    var registrationCertificateId: String?
    var inspectionCertificateId: String?
    var operatingCertificateId: String?
    var imageUrl: String?
    let service: Int
    var serviceName: String?
    var colorCode: String?
    var taxiBrand: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let v = (try? values.decode(String.self, forKey: .taxiBrand)), let n = Int(v) {
            taxiBrand = n
        } else {
            taxiBrand = try values.decodeIfPresent(Int.self, forKey: .taxiBrand)
        }
        id =  try values.decode(UInt64.self , forKey: .id)
        identifier =  try values.decode(Int.self , forKey: .identifier)
        type =  try values.decode(Int.self , forKey: .type)
        rank =  try values.decode(Double.self , forKey: .rank)
        ownerId =  try values.decode(Int.self , forKey: .ownerId)
        plate =  try values.decodeIfPresent(String.self , forKey: .plate)
        color =  try values.decodeIfPresent(String.self , forKey: .color)
        brand =  try values.decodeIfPresent(String.self , forKey: .brand)
        marketName =  try values.decodeIfPresent(String.self , forKey: .marketName)
        registrationCertificateId =  try values.decodeIfPresent(String.self , forKey: .registrationCertificateId)
        inspectionCertificateId =  try values.decodeIfPresent(String.self , forKey: .inspectionCertificateId)
        operatingCertificateId =  try values.decodeIfPresent(String.self , forKey: .operatingCertificateId)
        imageUrl =  try values.decodeIfPresent(String.self , forKey: .imageUrl)
        service =  try values.decode(Int.self , forKey: .service)
        serviceName =  try values.decodeIfPresent(String.self , forKey: .serviceName)
        colorCode =  try values.decodeIfPresent(String.self , forKey: .colorCode)
    }
    
}

struct Driver: Codable, ModelFromFireBaseProtocol {
    var user: FirebaseUser?
    var code: String?
    var vehicle: Vehicle?
    let active: Bool
    var deviceToken: String?
    var currentVersion: String?
    var group: String?
    var deviceInfo: DeviceInfo?
}

