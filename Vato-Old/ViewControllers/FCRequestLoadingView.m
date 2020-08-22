//
//  FCRequestLoadingView.m
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCRequestLoadingView.h"

@implementation FCRequestLoadingView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self start];
}

- (void) start {
    self.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.alpha = 1.0f;
    [UIView animateWithDuration:2.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionRepeat
                     animations:^{
                         self.alpha = 0.45f;
                         self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
                     }
                     completion:^(BOOL finished) {
                         // Remove avoid high energy
//                         [self start];
                     }];
}

@end
