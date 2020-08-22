//
//  FCTripHistory.m
//  FaceCar
//
//  Created by facecar on 6/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCTripHistory.h"

@implementation FCTripHistory

- (instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict error:err];
    if (self) {
        self.tripId = self.id;
    }
    return self;
}

- (BOOL)isInTrip {
    if  (self.statusDetail == BookStatusClientCreateBook ||
         self.statusDetail == BookStatusDriverAccepted ||
         self.statusDetail == BookStatusClientAgreed ||
         self.statusDetail == BookStatusDeliveryReceivePackageSuccess ||
         self.statusDetail == BookStatusStarted) {
        return YES;
    }
    return NO;
}
@end
