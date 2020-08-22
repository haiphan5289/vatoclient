//
//  IndicatorUtils.m
//  FaceCar
//
//  Created by Vu Dang on 6/3/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "IndicatorUtils.h"
#import "FCProgressView.h"

@implementation IndicatorUtils

static FCProgressView* _currentProgressView;

+ (void) showWithAllowDismiss: (BOOL) allow {
    [IndicatorUtils show];
}

+ (void) show {
    [LoadingManager showProgressWithDuration:30];
}

+ (void) dissmiss {
    [LoadingManager dismissProgress];
}

+ (void) showWithMessage:(NSString *)message {
    [self show];
}

@end
