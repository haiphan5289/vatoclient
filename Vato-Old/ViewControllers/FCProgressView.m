//
//  FCProgressView.m
//  FaceCar
//
//  Created by facecar on 11/19/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCProgressView.h"
#define TIME_ANIM 5.0f

@implementation FCProgressView {
    NSTimer *_loadingTimer;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self setProgress:0.0f animated:NO];
    if (self.showOnStart) {
        [self show];
    }
    else {
        self.hidden = YES;
    }
}

- (void) setProgressType: (FCProgressType) type {
    if (type == FCProgressTypeAllowInteraction) {
//        self.frame = self.originFame;
//        self.progressView.frame = CGRectMake(0, 0, self.originFame.size.width, self.originFame.size.height);
    }
    else {
//        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
//        self.progressView.frame = self.originFame;
    }
}

- (void) show {
    self.hidden = NO;
    [self setProgress:0.0f animated:NO];
    _loadingTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_ANIM
                                                     target:self
                                                   selector:@selector(start)
                                                   userInfo:nil
                                                    repeats:TRUE];
    [_loadingTimer fire];
}

- (void) dismiss {
    [_loadingTimer invalidate];
    [self setProgress:0.0 animated:NO];
    self.hidden = TRUE;
}

- (void) start {
    [self setProgress:0.0f animated:NO];
    [UIView animateWithDuration:TIME_ANIM/2.0f
                     animations:^{
                         [self setProgress:1.0f animated:YES];
                     }
                     completion:^(BOOL finished) {

                     }];

    // repeat
    [NSTimer scheduledTimerWithTimeInterval:TIME_ANIM/2.0f
                                     target:self
                                   selector:@selector(repeat)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) repeat {
    @try {
        [self setProgress:1.0f animated:NO];
        [UIView animateWithDuration:TIME_ANIM/2.0f
                         animations:^{
                             [self setProgress:0.0f animated:YES];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    @catch (NSException* e) {}
}

@end
