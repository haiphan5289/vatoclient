//
//  FCMCar.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCMCarModel.h"
#import "FCMCarType.h"

@interface FCMCar : FCModel

@property(assign, nonatomic) BOOL active;
@property(strong, nonatomic) NSString* code;
@property(strong, nonatomic) NSString* driverId;
@property(assign, nonatomic) long long id;
@property(strong, nonatomic) NSString* imageUrl;
@property(strong, nonatomic) FCMCarType* type;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSArray<FCMCarType>* services;

@end
