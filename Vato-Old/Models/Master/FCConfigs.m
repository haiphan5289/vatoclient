//
//  FCConfigs.m
//  FaceCar
//
//  Created by Vu Dang on 10/7/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCConfigs.h"

@implementation FCConfigs

- (id) init {
    self = [super init];
    self.defaultRadius = 3; // km
    self.mapZoom = 13;
    self.distanceAllow = 500;
    self.zalopayEnable = YES;
    self.outCountryAllow = YES;
    
    return self;
}
@end