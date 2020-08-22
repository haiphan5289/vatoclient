//
//  NSString+MD5.m
//  FC
//
//  Created by Son Dinh on 4/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)

- (void) borderViewWithColor:(UIColor *)color andRadius:(NSInteger)radius {
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [color CGColor];
    self.clipsToBounds = YES;
}

- (void) borderViewWithColor:(UIColor *)color width: (CGFloat) w andRadius:(NSInteger)radius {
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = w;
    self.layer.borderColor = [color CGColor];
    self.clipsToBounds = YES;
}

- (void) circleView {
    [self layoutIfNeeded];
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.clipsToBounds = YES;
}

- (void) circleView: (UIColor*) boderColor {
    [self layoutIfNeeded];
    self.layer.borderColor = [boderColor CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.clipsToBounds = YES;
}
@end
