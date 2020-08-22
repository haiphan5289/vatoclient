//
//  FCTripBook.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCPlace.h"
#import "FCGift.h"
#import "Enums.h"

@interface FCBookInfo : FCModel

@property(nonatomic, assign) long long  timestamp;
@property(nonatomic, strong) NSString*  tripId;
@property(nonatomic, strong) NSString*  tripCode;
@property(nonatomic, assign) NSInteger  price;
@property(nonatomic, assign) NSInteger  additionPrice;
@property(nonatomic, strong) NSString*  clientFirebaseId;
@property(nonatomic, assign) NSInteger  clientUserId;
@property(nonatomic, strong) NSString*  driverFirebaseId;
@property(nonatomic, assign) NSInteger  driverUserId;
@property(nonatomic, strong) NSString*  contactPhone;
@property(nonatomic, assign) NSInteger  tripType;
@property(nonatomic, assign) NSInteger  distance;
@property(nonatomic, assign) NSInteger  duration;
@property(nonatomic, assign) PaymentMethod  payment;
@property(nonatomic, strong) NSString<Ignore> *cardId;
@property(nonatomic, assign) NSInteger  vehicleId;
@property(nonatomic, strong) NSString*  note;

// start place
@property(strong, nonatomic) NSString* startName;
@property(strong, nonatomic) NSString* startAddress;
@property(assign, nonatomic) double startLat;
@property(assign, nonatomic) double startLon;
@property(assign, nonatomic) NSInteger zoneId;

// end place
@property(strong, nonatomic) NSString* endName;
@property(strong, nonatomic) NSString* endAddress;
@property(assign, nonatomic) double endLat;
@property(assign, nonatomic) double endLon;

// service
@property(assign, nonatomic) NSInteger serviceId;
@property(strong, nonatomic) NSString* serviceName;

// fare
@property(assign, nonatomic) NSInteger modifierId;
@property(assign, nonatomic) NSInteger farePrice;
@property(assign, nonatomic) NSInteger fareClientSupport;
@property(assign, nonatomic) NSInteger fareDriverSupport;

// promotion
@property(nonatomic, assign) NSInteger  promotionValue;
@property(nonatomic, strong) NSString*  promotionCode;
@property(nonatomic, assign) NSInteger  promotionModifierId;
@property(nonatomic, assign) NSInteger  promotionDelta;
@property(nonatomic, assign) CGFloat  promotionRatio;
@property(nonatomic, assign) NSInteger  promotionMin;
@property(nonatomic, assign) NSInteger  promotionMax;
@property(nonatomic, strong) NSString*  promotionToken;
@property(nonatomic, strong) NSString*  promotionDescription;

// appversion
@property(nonatomic, strong) NSString*  clientVersion;
@property(nonatomic, strong) NSString*  driverVersion;
@property(nonatomic, strong) NSString  * _Nullable taxiBrandName;

@property(nonatomic, assign) NSInteger end_reason_id;
@property(nonatomic, copy) NSString <Optional> *_Nullable end_reason_value;
@property(nonatomic, assign) NSInteger statusDetail;

// express
@property(copy, nonatomic) NSString*_Nullable senderName;
@property(copy, nonatomic) NSString*_Nullable receiverName;
@property(nonatomic, strong) NSArray<NSDictionary<NSString *, id> *><Optional> * _Nullable wayPoints;

- (NSInteger) getBookPrice;

@end
