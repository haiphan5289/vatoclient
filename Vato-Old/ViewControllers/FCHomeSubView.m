//
//  FCHomeSubView.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCHomeSubView.h"

@implementation FCHomeSubView {
    BOOL _configured;
    CGRect _targetFrame;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    if (self.autoShow) {
        [self animationShow];
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self configs];
}

- (void) configs {
    if (!_configured) {
        _configured = YES;
        
        _targetFrame = self.frame;
        CGRect fromFrame = _targetFrame;
        if (self.animationType == FCAnimationFromTop) {
            fromFrame.origin.y = -fromFrame.size.height;
            self.frame = fromFrame;
        }
        else if (self.animationType == FCAnimationFromBottom) {
            fromFrame.origin.y = [UIScreen mainScreen].bounds.size.height + fromFrame.size.height;
            self.frame = fromFrame;
        }
        [self layoutIfNeeded];
    }
}

- (void) animationShow {
    if (!_configured) {
        [self configs];
    }
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.frame = _targetFrame;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {

                     }];
}

- (void) resetAnimationShow {
    _configured = FALSE;
    [self configs];
}

@end
