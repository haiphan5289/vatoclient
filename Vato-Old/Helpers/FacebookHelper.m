//
//  FacebookHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FacebookHelper.h"

@implementation FacebookHelper

static FacebookHelper * instnace = nil;
+ (FacebookHelper*) shareInstance {
    if (instnace == nil) {
        instnace = [[FacebookHelper alloc] init];
    }
    return instnace;
}

- (void) requestGetUserInfoWithCallback:(FBSDKGraphRequestBlock)handler {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler: handler];
}

- (void) initAccountKit {
    
}

@end
