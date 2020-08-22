//
//  FCLocation.m
//  FaceCar
//
//  Created by Vu Dang on 7/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCLocation.h"

@implementation FCLocation

- (id) initWithLat:(CLLocationDegrees) lat lon: (CLLocationDegrees) lon {
    self = [super init];
    self.lat = lat;
    self.lon = lon;
    return self;
}
@end
