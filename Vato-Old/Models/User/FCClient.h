//
//  FCClient.h
//  FaceCar
//
//  Created by Vu Dang on 6/3/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//


#import "FCModel.h"
#import "FCUser.h"
#import "FCDevice.h"
#import "Enums.h"

@interface FCClient : FCModel

@property(strong, nonatomic) FCUser* user;
@property(strong, nonatomic) NSNumber* active;
@property(strong, nonatomic) NSString* statusChangeMessage;
@property(strong, nonatomic) NSString* version;
@property(strong, nonatomic) NSString* topic;
@property(assign, nonatomic) long long created;
@property(strong, nonatomic) NSString* deviceToken;
@property(strong, nonatomic) FCDevice* deviceInfo;
@property(assign, nonatomic) NSInteger zoneId;
@property(assign, nonatomic) PaymentMethod paymentMethod;

@end
