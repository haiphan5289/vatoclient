//
//  NSString+MD5.m
//  FC
//
//  Created by Son Dinh on 4/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

- (void) gradient:(UIColor*) from to: (UIColor*) to {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.bounds;
    gradient.colors = @[(id)from.CGColor, (id)to.CGColor];
    
    [self.layer insertSublayer:gradient atIndex:0];
}

@end
