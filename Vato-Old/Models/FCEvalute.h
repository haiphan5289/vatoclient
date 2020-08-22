//
//  FCEvalute.h
//  FaceCar
//
//  Created by facecar on 2/26/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCEvalute : FCModel

@property (assign, nonatomic) NSInteger rating; // star
@property (strong, nonatomic) NSString* comment;
@property (strong, nonatomic) NSString* bookingId;
@property (assign, nonatomic) NSInteger driverId;
@property (assign, nonatomic) NSInteger clientId;
@property (assign, nonatomic) NSInteger zoneId;
@property (assign, nonatomic) long long created;

@end
