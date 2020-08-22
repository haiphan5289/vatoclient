//
//  DriverHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FCProfileLevel2;
@class FCBookInfo;
@class FCClient;

@interface UserDataHelper : NSObject
@property(strong, nonatomic) NSString* _Nullable firebaseToken;
+ (UserDataHelper*__nonnull) shareInstance;

- (void) saveUserToLocal :(FCClient*__nonnull) client;
- (FCClient*__nullable) getCurrentUser;
- (NSInteger) userId;
- (void) clearUserData;
- (void) updateEmail:(NSString *__nonnull)email;

- (void)saveLastestTripbook: (FCBookInfo*__nonnull)  trip currentCar: (NSInteger) car;
- (void)saveJSONTrip:(NSDictionary <NSString *, id> *_Nullable)json currentCar:(NSInteger) car;
- (void) removeLastestTripbook;
- (FCBookInfo*__nullable) getLastestTripbook;
- (NSString*__nullable) getLastestTripbookId;

- (NSInteger) getCurrentCar;
- (void) cacheNotificationStatus : (BOOL) noshowAgain;
- (BOOL) allowShowNotification;

- (void) cacheCurrentPushData: (NSDictionary*__nonnull) dict;
- (NSDictionary*__nullable) getPushData;
- (void) removePushData;

- (void) cacheLvl2Info: (FCProfileLevel2*__nonnull) lvl2;
- (FCProfileLevel2*__nullable) getLvl2Info;
- (void) removeLvl2Info;

- (void) saveLastestNotification: (long long) notifyCreated;
- (long long) getLastestNotification;
    
- (void) cacheFinishedTutorialStartup;
- (BOOL) isFinishedTutorialStartup;

@end
