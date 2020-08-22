//
//  FCSearchDriver.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCSearchDriverModel.h"

@implementation FCSearchDriverModel {
    CGFloat _currRadius;
}

- (id) init {
    self = [super init];
    if (self) {
        self.size = 10;
        self.page = 0;
        self.distance = 10.0;
        self.service = 1;
    }
    
    return self;
}

- (void) setLocation:(CLLocation *)lo {
    self.lat = lo.coordinate.latitude;
    self.lon = lo.coordinate.longitude;
}

- (void) setRadiusRequest:(CGFloat)readius {
    _currRadius = readius;
    self.distance = _currRadius;
}

- (CGFloat) getCurrentRadius {
    return _currRadius > 0 ? _currRadius : 10;
}

@end
