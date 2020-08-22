//
//  FCBooking.h
//  FC
//
//  Created by facecar on 4/29/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCBookCommand.h"
#import "FCBookTracking.h"
#import "FCBookInfo.h"
#import "FCBookEstimate.h"
#import "FCBookExtra.h"

@interface FCBooking : FCModel

@property (strong, nonatomic) FCBookInfo* info;
@property (strong, nonatomic) NSArray<Ignore>* command;
@property (strong, nonatomic) NSArray<Ignore>* tracking;
@property (strong, nonatomic) FCBookEstimate* estimate;
@property (strong, nonatomic) FCBookExtra* extra;

- (BOOL)isAllowLoadTripLasted;
- (BOOL)isTripComplete;
- (BOOL)isIntrip;
@end
