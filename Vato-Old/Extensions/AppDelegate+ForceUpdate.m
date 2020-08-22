//
//  AppDelegate+ForceUpdate.m
//  Vato
//
//  Created by THAI LE QUANG on 10/30/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#import "AppDelegate+ForceUpdate.h"
#import "FCBookingService.h"

@interface AppDelegate (Dependency)
@property BOOL isIntrip;
@property (nonatomic, strong) PopupForceUpdateViewController *forePopup;
@property (assign, nonatomic) BOOL needCheckVersion;
@end


@implementation AppDelegate (ForceUpdate)

- (void) showPopupForceMessage:(NSString *)message type:(PopupForeType)type  {
    BOOL isShowedPopup = (self.forePopup != nil && self.forePopup.presentingViewController != nil);
    if (isShowedPopup && self.forePopup.popupType == type) {
        return;
    }
    
    void (^blockExcute)() = ^() {
        self.forePopup = [PopupForceUpdateViewController generateVCWith:type message:message];
        [self.forePopup setModalPresentationStyle:UIModalPresentationOverFullScreen];
        [self.forePopup setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        UIViewController* vc = [self visibleViewController:self.window.rootViewController];
        [vc presentViewController:self.forePopup animated:true completion:nil];
    };
    
    if (isShowedPopup) {
        [self.forePopup dismissViewControllerAnimated:NO completion:^{
            blockExcute();
        }];
    } else {
        blockExcute();
    }
}

- (void) checkingLastestBooking {
    if ([[UserDataHelper shareInstance] getLastestTripbook]) {
        FCBookingService* service = [FCBookingService shareInstance];
        @try {
            [service getBookingDetail:[[UserDataHelper shareInstance] getLastestTripbook]
                              handler:^(FCBooking * book) {
                                  if (book && [book isAllowLoadTripLasted]) {
                                      self.isIntrip = true;
                                  } else {
                                      self.isIntrip = false;
                                  }
                              }];
        }
        @catch (NSException* e) {
            self.isIntrip = false;
        }
    } else {
        self.isIntrip = false;
    }
}

- (void) checkLockAccount {
    __weak AppDelegate * const weakSelf = self;
    FIRUser* user = [[FIRAuth auth] currentUser];
    if (!user) {
        AppLogCurrentUser()
    }
    
    if (!user || !self.needCheckVersion) {
        return;
    }
    
    [[FirebaseHelper shareInstance] getClient:^(FCClient* client) {
        if (weakSelf.isIntrip) {
            if (weakSelf.forePopup != nil) {
                [weakSelf.forePopup dismissViewControllerAnimated:NO completion:nil];
            }
            return;
        }
        @autoreleasepool {
            if ((client != nil ) && (![client.active boolValue])) {
                [weakSelf showPopupForceMessage:client.statusChangeMessage type:(PopupForeTypeBlockUser)];
            } else {
                [weakSelf checkUpdateVersion];
            }
        }
    }];
}

- (void) checkUpdateVersion {
    __weak AppDelegate * const weakSelf = self;
    FIRUser* user = [[FIRAuth auth] currentUser];
    if (!user) {
        AppLogCurrentUser()
    }
    
    if (!user || !self.needCheckVersion) {
        return;
    }
    
    [[FirebaseHelper shareInstance] getAppSettings:^(FCSetting *setting) {
        if (!setting || weakSelf.isIntrip) {
            if (weakSelf.forePopup != nil) {
                [weakSelf.forePopup dismissViewControllerAnimated:NO completion:nil];
            }
            return;
        }
        
        @autoreleasepool {
            
            NSString *appVersion = [weakSelf getAppVersion];
            BOOL needUpdate = [NSString differentWithCurrentVersion:appVersion compareVersion:setting.ver];
            if (!needUpdate) {
                if (weakSelf.forePopup != nil) {
                    [weakSelf.forePopup dismissViewControllerAnimated:NO completion:nil];
                }
                return;
            }
            
            if (setting.force) {
                [weakSelf showPopupForceMessage:setting.message type:(PopupForeTypeForceUpdate)];
            } else {
                [weakSelf showPopupForceMessage:setting.message type:(PopupForeTypeRemindpdate)];
            }
        }
    }];
}

@end
