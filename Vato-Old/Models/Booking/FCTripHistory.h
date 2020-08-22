//
//  FCTripHistory.h
//  FaceCar
//
//  Created by facecar on 6/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBookInfo.h"

@interface FCTripHistory : FCBookInfo

@property (strong, nonatomic) NSString* id;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) NSInteger statusDetail;
@property (assign, nonatomic) long long createdAt;

- (BOOL)isInTrip;
@end
