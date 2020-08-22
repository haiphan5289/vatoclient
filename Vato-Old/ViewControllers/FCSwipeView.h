//
//  FCSwipeView.h
//  FaceCar
//
//  Created by facecar on 12/14/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCSwipeView : FCView

@property (assign, nonatomic) CGFloat marginTop;
@property (assign, nonatomic) CGFloat marginBottom;

- (void) setSuperView:(UIView *)superView
        withBackgound:(UIView *)bgview; // background view for transparents

- (void) setTargetFrame: (CGRect) target;
- (void) setTargetAlpha: (CGFloat) alpha;

- (void) setInteractionListener: (void (^) (BOOL isHide, BOOL isShow)) block;
- (void) setTargetFrame:(CGRect) target andAlpha:(CGFloat) alpha;
@end
