//
//  FCTripBook.m
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCBookInfo.h"

@implementation FCBookInfo

- (NSInteger) getBookPrice {
    NSInteger bookPrice = (self.farePrice > 0 && self.price != 0) ? self.farePrice : self.price;
    return bookPrice;
}

- (BOOL)isEqual:(id)object {
    FCBookInfo *info = [FCBookInfo castFrom:object];
    if (!info) { return NO; }
    return [self.tripId isEqual:info.tripId];
}

@end
