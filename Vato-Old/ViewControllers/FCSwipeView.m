//
//  FCSwipeView.m
//  FaceCar
//
//  Created by facecar on 12/14/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCSwipeView.h"
#import "CXSwipeGestureRecognizer.h"
#import "NSArray+Extension.h"

@interface FCSwipeView () <CXSwipeGestureRecognizerDelegate>

@end

@implementation FCSwipeView {
    CGFloat _originInfoViewY;
    __weak UIView* _superView;
    __weak UIView* _backgroundView;
    
    void (^_listenerCallback)(BOOL isHide, BOOL isShow);
}

- (void) setSuperView:(UIView *)superView
        withBackgound:(UIView *)bgview {
    _superView = superView;
    _backgroundView = bgview;
    
    [self initLayout];
}

- (void) initLayout {
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    _originInfoViewY = size.height - _marginBottom;
    self.frame = CGRectMake(0, _originInfoViewY, size.width, size.height);
    
    // add tap
    CXSwipeGestureRecognizer* swipe = [[CXSwipeGestureRecognizer alloc] init];
    swipe.delegate = self;
    [self addGestureRecognizer:swipe];
}

// overrited
- (void) show {
    CGRect frame = self.frame;
    frame.origin.y = _marginTop;
    [self setTargetFrame:frame];
}

- (void) hide {
    CGRect frame = self.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    [self setTargetFrame:frame];
}

- (void) setInteractionListener:(void (^)(BOOL, BOOL))block {
    _listenerCallback = block;
}

- (void)removeFromSuperview {
    NSArray<UIGestureRecognizer *> *gestures = self.gestureRecognizers;
    [gestures forEach:^(__kindof UIGestureRecognizer * _Nonnull gesture) {
        [self removeGestureRecognizer:gesture];
    }];
    [super removeFromSuperview];
}

- (void)dealloc {
    
}

#pragma mark - Swipe Footer Up
- (void)swipeGestureRecognizerDidUpdate:(CXSwipeGestureRecognizer *)gestureRecognizer {
    CGRect frame = self.frame;
    CGFloat translation = [gestureRecognizer translationInDirection:gestureRecognizer.currentDirection];
    
    if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionUpwards) {
        if (frame.origin.y > _marginTop) {
            frame.origin.y = _originInfoViewY - translation;
            self.frame = frame;
            
            DLog(@"swipeGestureRecognizerDidUpdate: up -> %@", NSStringFromCGRect(frame))
        }
    }
    else if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionDownwards) {
        if (frame.origin.y < _superView.bounds.size.height - _marginBottom) {
            frame.origin.y = (translation + _marginTop);
            self.frame = frame;
            
            DLog(@"swipeGestureRecognizerDidUpdate: down -> %@", NSStringFromCGRect(frame))
        }
    }
    
    CGFloat alpha = 4*(_originInfoViewY - frame.origin.y) / _originInfoViewY;
    if (_backgroundView) {
        _backgroundView.alpha = alpha > 1.0f ? 1.0f : alpha;
    }
}

- (void)swipeGestureRecognizerDidStart:(CXSwipeGestureRecognizer *)gestureRecognizer
{
    _backgroundView.hidden = NO;
}

- (void)swipeGestureRecognizerDidCancel:(CXSwipeGestureRecognizer *)gestureRecognizer
{
    CGRect frame = self.frame;
    
    if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionUpwards) {
        frame.origin.y = _superView.bounds.size.height - _marginBottom;
    }
    else if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionDownwards) {
        frame.origin.y = _marginTop;
    }
    
    [self setTargetFrame:frame];
    [self setTargetAlpha:-1];
    
    DLog(@"swipeGestureRecognizerDidCancel: %@", NSStringFromCGRect(frame))
}

- (void)swipeGestureRecognizerDidFinish:(CXSwipeGestureRecognizer *)gestureRecognizer
{
    CGRect frame = self.frame;
    CGFloat targetAlpha = 0;
    if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionUpwards) {
        frame.origin.y = _marginTop;
        targetAlpha = 1.0f;
    }
    else if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionDownwards) {
        frame.origin.y = _superView.bounds.size.height - _marginBottom;
        targetAlpha = 0.0f;
    }
    
    [self setTargetFrame:frame];
    [self setTargetAlpha:targetAlpha];
    
    DLog(@"swipeGestureRecognizerDidFinish: %@", NSStringFromCGRect(frame))
}

- (BOOL)swipeGestureRecognizerShouldCancel:(CXSwipeGestureRecognizer *)gestureRecognizer {
    CGRect frame = self.frame;
    if (gestureRecognizer.currentDirection == CXSwipeGestureDirectionUpwards) {
        if (frame.origin.y > _superView.frame.size.height / 2) {
            return YES;
        }
    }
    else {
        if (frame.origin.y < _superView.frame.size.height / 2) {
            return YES;
        }
    }
    
    return NO;
}

- (void) setTargetFrame: (CGRect) target {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.frame = target;
                     }
                     completion:^(BOOL finished) {
                         
                         if (_listenerCallback) {
                             if (target.origin.y >= _originInfoViewY) {
                                 _listenerCallback(YES, NO);
                             }
                             else if (target.origin.y <= _marginTop) {
                                 _listenerCallback(NO, YES);
                             }
                         }
                     }];
}

- (void) setTargetAlpha: (CGFloat) alpha {
    
    __block CGFloat finishedAlpha = self.alpha;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         if (alpha == -1) {
                             finishedAlpha = 4 * (_originInfoViewY - self.frame.origin.y) / _originInfoViewY;
                             _backgroundView.alpha = finishedAlpha > 1.0f ? 1.0f : finishedAlpha;
                         }
                         else {
                             _backgroundView.alpha = alpha;
                             finishedAlpha = alpha;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (finishedAlpha < 0.15) {
                             _backgroundView.hidden = YES;
                         }
                     }];
}

- (void) setTargetFrame:(CGRect) target andAlpha:(CGFloat) alpha {
    __block CGFloat finishedAlpha = self.alpha;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.frame = target;
                         if (alpha == -1) {
                             finishedAlpha = 4 * (_originInfoViewY - self.frame.origin.y) / _originInfoViewY;
                             _backgroundView.alpha = finishedAlpha > 1.0f ? 1.0f : finishedAlpha;
                         } else {
                             _backgroundView.alpha = alpha;
                             finishedAlpha = alpha;
                         }
                     } completion:^(BOOL finished) {
                         if (_listenerCallback) {
                             if (target.origin.y >= _originInfoViewY) {
                                 _listenerCallback(YES, NO);
                             } else if (target.origin.y <= _marginTop) {
                                 _listenerCallback(NO, YES);
                             }
                         }
                         if (finishedAlpha < 0.15) {
                             _backgroundView.hidden = YES;
                         }
                     }];
}

@end
