//
//  FCHomeSubView.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FCAnimationType) {
    FCAnimationFromTop = 1,
    FCAnimationFromBottom = 2
};

@interface FCHomeSubView : FCView

@property (assign, nonatomic) IBInspectable NSInteger animationType;
@property (assign, nonatomic) IBInspectable BOOL autoShow;

- (void) animationShow;
- (void) resetAnimationShow;

@end
