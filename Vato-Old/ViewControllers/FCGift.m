//
//  FCGift.m
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGift.h"

@implementation FCGift
@synthesize description;

- (NSInteger) getAmountPromotion: (NSInteger) originPrice {
    if (self.unit == PERCENT) {
        NSInteger res = (NSInteger) (self.amount_seed*1.0f/100.0f * originPrice);
        if (res < self.amount_seed_min) {
            res = self.amount_seed_min;
        }
        else if (res > self.amount_seed_max)
            res = self.amount_seed_max;
        
        return  res;
    }
    
    return self.amount_seed;
}
@end
