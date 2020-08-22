//
//  FCTrip.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCTrip : FCModel

@property(nonatomic, strong) NSString*  bookingId;
@property(nonatomic, assign) long long  requestId;
@property(nonatomic, assign) long long  carId;
@property(nonatomic, strong) NSString*  serviceId;
@property(nonatomic, strong) NSString*  driverId;
@property(nonatomic, strong) NSString*  clientId;
@property(nonatomic, strong) FCPlace*  start;
@property(nonatomic, strong) FCPlace*  end;
@property(nonatomic, assign) NSInteger  salePrice; // gia goc vivu
@property(nonatomic, assign) NSInteger  bookPrice; // gia khach dat
@property(nonatomic, assign) NSInteger  stationTip; // tien bo cho station
@property(nonatomic, assign) NSInteger  promotionValue; // tien khuyen mai
@property(nonatomic, strong) NSString*  promotionCode;
@property(nonatomic, assign) NSInteger  promotionEventId;
@property(nonatomic, strong) NSString*  contactPhone;
@property(nonatomic, assign) NSInteger  status;
@property(nonatomic, assign) NSInteger  lastStatus;
@property(nonatomic, assign) NSInteger  distance; // metter
@property(nonatomic, assign) NSInteger  duration; // second
@property(nonatomic, assign) NSInteger  userType;
@property(nonatomic, assign) NSInteger  stationFee;
@property(nonatomic, assign) double  created; // second

@end
