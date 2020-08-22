//
//  UIImage+fixOrientation.m
//  FaceCar
//
//  Created by facecar on 4/21/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "UIImage+fixOrientation.h"

@implementation UIImageView (Helper)
- (void) setImageColor: (UIColor*) color {
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:color];
}
@end
