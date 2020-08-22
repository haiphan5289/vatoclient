//
//  FCRoundTrip.h
//  FaceCar
//
//  Created by Vu Dang on 6/23/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCPlace.h"

@interface FCRoundTrip : FCModel
@property(strong, nonatomic) NSString* driverId;
@property(strong, nonatomic) FCPlace* startPlace;
@property(strong, nonatomic) FCPlace* endPlace;
@property(assign, nonatomic) double created;
@property(assign, nonatomic) double timeStart;
@property(strong, nonatomic) NSString* message;
@end
