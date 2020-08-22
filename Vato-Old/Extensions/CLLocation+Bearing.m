//
//  CLLocation+Bearing.m
//  FaceCar
//
//  Created by Vu Dang on 7/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "CLLocation+Bearing.h"

double DegreesToRadians(double degrees) {return degrees * M_PI / 180;};
double RadiansToDegrees(double radians) {return radians * 180/M_PI;};

@implementation CLLocation (Bearing)

- (double) bearingToLocation:(CLLocation *) destinationLocation {
    
    double lat1 = DegreesToRadians(self.coordinate.latitude);
    double lon1 = DegreesToRadians(self.coordinate.longitude);
    
    double lat2 = DegreesToRadians(destinationLocation.coordinate.latitude);
    double lon2 = DegreesToRadians(destinationLocation.coordinate.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    
    return RadiansToDegrees(radiansBearing);
}

- (CLLocation*) getLocationByRadius:(NSInteger)radius {
    CGFloat originX = self.coordinate.latitude;
    CGFloat originY = self.coordinate.longitude;
    
    double a = 1.0*(originX*originX)/(originY*originY) + 1;
    double b = -2.0f*((originX*originX)/originY + originY);
    double c = a*a + b*b - radius*radius;
    
    double detal = b*b - 4*a*c;
    double y1 = (-b + sqrt(detal))/(2*a);
//    double y2 = (-b - sqrt(detal))/(2*a);
    
    double x1 = a*y1/b;
//    double x2 = a*y2/b;
    
    return [[CLLocation alloc] initWithLatitude:x1 longitude:y1];
}
@end
