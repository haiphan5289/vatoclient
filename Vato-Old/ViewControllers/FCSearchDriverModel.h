//
//  FCSearchDriver.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCSearchDriverModel : FCModel
@property (assign, nonatomic) CGFloat lat;
@property (assign, nonatomic) CGFloat lon;
@property (assign, nonatomic) CGFloat distance;
@property (assign, nonatomic) NSInteger service;
@property (strong, nonatomic) NSArray* partners;
@property (assign, nonatomic) BOOL isFavorite;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) NSInteger size;
@property (assign, nonatomic) double fare;

- (void) setLocation: (CLLocation*) lo;
- (void) setRadiusRequest: (CGFloat) readius;
- (CGFloat) getCurrentRadius;
@end
