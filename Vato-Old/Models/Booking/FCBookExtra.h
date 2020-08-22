//
//  FCBookExtra.h
//  FaceCar
//
//  Created by facecar on 6/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCBookExtra : FCModel
@property (assign, nonatomic) double driverCash;
@property (assign, nonatomic) double driverCoin;
@property (strong, nonatomic) NSString* polylineIntrip;
@property (strong, nonatomic) NSString* polylineReceive;
@property (strong, nonatomic) NSNumber* satisfied;
@end
