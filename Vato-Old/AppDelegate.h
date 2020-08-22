//
//  AppDelegate.h
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCSetting;
@class FCHomeViewModel;
@protocol ApplicationDelegateProtocol;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ApplicationDelegateProtocol>
@property (strong, nonatomic) UIWindow * window;
@property (strong, nonatomic) FCSetting* currentSetting;
@property (weak, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) NSString* inviteUrl;
@property (strong, nonatomic) NSDictionary* pushData;

- (NSString*) getInviteCode : (NSString*) inviteLink;
- (void) verifyInviteCode: (NSString*) inviteUrl;
- (UIViewController *)visibleViewController:(UIViewController *)rootViewController;

- (void)handlerChangeMethodPayment:(void(^)(void))handler;
- (void)cleanUpListenChangeMethod;
- (void)moveToHomeNew;
- (void)cleanUp;
- (void)signOut;
@end

