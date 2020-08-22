//
//  FacebookHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FacebookHelper : NSObject

+ (FacebookHelper*) shareInstance;
- (void) requestGetUserInfoWithCallback:(FBSDKGraphRequestBlock)handler;

@end
