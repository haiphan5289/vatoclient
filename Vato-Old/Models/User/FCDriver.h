//
//  FCDriver.h
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "FCLocation.h"
#import "FCUCar.h"
#import "FCUser.h"
#import "FCDevice.h"

@interface FCDriver : FCModel

@property(strong, nonatomic) FCUser* user;
@property(strong, nonatomic) NSString* code;
@property(strong, nonatomic) FCUCar* vehicle;
@property(assign, nonatomic) BOOL active;
@property(strong, nonatomic) NSString* deviceToken;
@property(strong, nonatomic) NSString* currentVersion;
@property(strong, nonatomic) NSString* group;
@property(assign, nonatomic) long long created;
@property(strong, nonatomic) NSString* topic;
@property(strong, nonatomic) FCDevice* deviceInfo;

@end
