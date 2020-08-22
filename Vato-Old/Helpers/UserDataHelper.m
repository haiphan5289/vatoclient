//
//  DriverHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "UserDataHelper.h"
#import "AppDelegate.h"
#import "FCBookInfo.h"
#import "FCProfileLevel2.h"
#import <Firebase.h>

@implementation UserDataHelper {
}

static UserDataHelper * instnace = nil;
+ (UserDataHelper*) shareInstance {
    if (instnace == nil) {
        instnace = [[UserDataHelper alloc] init];
    }
    return instnace;
}

- (void) saveUserToLocal :(FCClient*) client {
    NSString* json = [client toJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"current_user_4.2.1"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) updateEmail:(NSString *)email {
    FCClient *client = [self getCurrentUser];
    if (!client) {
        return;
    }
    client.user.email = email;
    [self saveUserToLocal:client];
}

- (FCClient*) getCurrentUser {
    NSString* json = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_user_4.2.1"];
    FCClient* client = [[FCClient alloc] initWithString:json error:nil];
    return client;
}

- (void) clearUserData {
    _firebaseToken = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"current_user_4.2.1"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveLastestTripbook: (FCBookInfo*)  trip currentCar: (NSInteger) car {
    if (trip.tripId.length > 0) {
        [FirebaseHelper.shareInstance writeClientCurrentTrip:trip.tripId];
    }
    NSString* json = [trip toJSONString];
    [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"lastest_trip"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:car] forKey:@"car_selected_1.0.0"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveJSONTrip: (NSDictionary *) json currentCar:(NSInteger) car {
    if (!json) {
        return;
    }
    FCBookInfo* trip = [[FCBookInfo alloc] initWithDictionary:json error:nil];
    if (!trip) {
        return;
    }
    [self saveLastestTripbook:trip currentCar:car];
}

- (void) removeLastestTripbook {
    [FirebaseHelper.shareInstance removeClientCurrentTrip];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastest_trip"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (FCBookInfo*) getLastestTripbook {
    NSString* json = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastest_trip"];
    FCBookInfo* trip = [[FCBookInfo alloc] initWithString:json error:nil];
    return trip;
}

- (NSString*) getLastestTripbookId {
    FCBookInfo* info = [self getLastestTripbook];
    return info.tripId;
}

- (NSInteger) getCurrentCar {
    NSNumber* num = [[NSUserDefaults standardUserDefaults] valueForKey:@"car_selected_1.0.0"];
    
    return [num integerValue];
}

- (void) getAuthToken:(nullable FIRAuthTokenCallback) callback {
    if (_firebaseToken.length > 0) {
        callback(_firebaseToken, nil);
        return;
    }
    AppLog([FIRAuth auth].currentUser.uid)

    [NSTimer scheduledTimerWithTimeInterval:30*60 target:self selector:@selector(forceGetNewToken) userInfo:nil repeats:NO];
    [[FIRAuth auth].currentUser getIDTokenForcingRefresh:YES
                                              completion:^(NSString * _Nullable token, NSError * _Nullable error) {
                                                  _firebaseToken = token;
                                                  callback(token, error);
                                              }];
}

- (void) forceGetNewToken {
    _firebaseToken = nil;
    [self getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
        _firebaseToken = token;
    }];
}

- (void) cacheNotificationStatus : (BOOL) noshowAgain {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:noshowAgain] forKey:@"allow_show_notification_1"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) allowShowNotification {
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"allow_show_notification_1"] ) {
        return TRUE;
    }
    FCSetting* setting = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentSetting;
    BOOL allow = [[[NSUserDefaults standardUserDefaults] valueForKey:@"allow_show_notification_1"] boolValue] && !setting.isApply;
    return allow;
}

- (void) cacheCurrentPushData: (NSDictionary*) dict {
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"push_data"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary*) getPushData {
    NSDictionary* dict =  [[NSUserDefaults standardUserDefaults] valueForKey:@"push_data"];
    if (dict) {
        [self removePushData];
    }
    return dict;
}

- (void) removePushData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"push_data"];
}

#pragma mark - Notification
- (void) saveLastestNotification: (long long) notifyCreated {
    [[NSUserDefaults standardUserDefaults] setObject:@(notifyCreated)
                                              forKey:@"lastestNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long long) getLastestNotification {
    NSNumber* time =  [[NSUserDefaults standardUserDefaults] valueForKey:@"lastestNotification"];
    return [time longLongValue];
}

#pragma mark - LVL2 profile
- (void) cacheLvl2Info: (FCProfileLevel2*) lvl2 {
    [[NSUserDefaults standardUserDefaults] setObject:[lvl2 toDictionary] forKey:@"lvl2_data"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FCProfileLevel2*) getLvl2Info {
    NSDictionary* dict =  [[NSUserDefaults standardUserDefaults] valueForKey:@"lvl2_data"];
    if (dict) {
        return [[FCProfileLevel2 alloc] initWithDictionary:dict error:nil];
    }
    return nil;
}

- (void) removeLvl2Info {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lvl2_data"];
}

#pragma mark - Tutorial StartUp
- (void) cacheFinishedTutorialStartup {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"tutorial-startup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) isFinishedTutorialStartup {
    NSNumber* val =  [[NSUserDefaults standardUserDefaults] valueForKey:@"tutorial-startup"];
    if (val) {
        return [val boolValue];
    }
    return nil;
}

- (NSInteger) userId {
    FCClient *client = [self getCurrentUser];
    NSInteger result = client.user.id;
    return result;
}

@end
