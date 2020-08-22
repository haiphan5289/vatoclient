//
//  FirebaseHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AFNetworking/AFURLRequestSerialization.h>
#import "FCDriver.h"
#import "FCClient.h"
#import "FCMCar.h"
#import "FCBookInfo.h"
#import "FCFavorite.h"
#import "FCTrip.h"
#import "FCMCarType.h"
#import "FCMCarGroup.h"
#import "FCFareSetting.h"
#import "FCRoundTrip.h"
#import "FCSetting.h"
#import "FCConfigs.h"
#import "FCOnlineStatus.h"
#import "FCService.h"
#import "FCDevice.h"
#import "FCPriceTripInfo.h"
#import "FCZone.h"
#import "FCGift.h"
#import "UIImage+fixOrientation.h"
#import "NSString+MD5.h"
#import "FCBookTracking.h"
#import "FCPartner.h"
#import "FCFee.h"
#import "FCEvalute.h"
#import "FCShipService.h"
#import "FCAppConfigure.h"
#import "FCMInvite.h"
#import "FCBooking.h"
#import "FCGoogleKey.h"
#import "FCUCar.h"
#import "Enums.h"

@import GoogleMaps;
@import Firebase;
@import FirebaseDatabase;
@class FIRStorageUploadTask;
@protocol AuthenDependencyProtocol;
@protocol UserProtocol;
extern const struct MONExtResultStruct MONExtResult;

@interface FirebaseHelper : NSObject<AuthenDependencyProtocol>

@property (strong, nonatomic) FIRDatabaseReference* __nullable ref;
@property (strong, nonatomic) FCClient* __nullable currentClient;
@property (strong, nonatomic) NSString*__nullable currentClientLocationAddress; // vi tri hien tai cua khach hang
@property (strong, nonatomic) FCConfigs* __nullable appConfigs;
@property (strong, nonatomic) FCAppConfigure* __nullable appConfigure;
@property (strong, nonatomic) NSString* __nullable googleKeys;
@property (assign, nonatomic) NSInteger authService; // - 0: firebase, 1: vato

+ (FirebaseHelper* __nullable) shareInstance;

#pragma mark - Users
- (FIRAuthCredential*__nonnull) getfacebookCredential;
- (void) facebookAuth:(FIRAuthCredential*__nullable)credential handler:(void (^__nullable)(FIRUser*__nullable))completed;
- (FIRAuthCredential*__nonnull) getPhoneCredential:(NSString*__nonnull) phone;
- (FIRAuthCredential*__nullable) getGoogleCredential:(NSString*__nullable) idToken accessToken: (NSString*__nullable) acctoken;
- (void) googleAuth:(FIRAuthCredential*__nullable) credential handler:(void (^__nullable)(FIRUser *__nullable))completed;

- (void) updateClientData: (FCClient*__nonnull) client
      withCompletionBlock: (void (^)(NSError *__nullable error, FIRDatabaseReference *__nullable ref))block;
- (void) getClient: (void (^__nullable) (FCClient* __nullable client)) completed;
- (void) addClientInfoChangedListener:(void (^)(FIRDataSnapshot * _Nullable))completed;
- (void) updateUserPhone: (NSString*__nonnull) phone;
- (void) updateUserCreated;
- (void) updateDeviceToken:(NSString*__nullable) token;
- (void) updateUserEmail: (NSString*__nonnull) email complete: (void (^) (NSError* err)) block ;
- (void) updateNickname: (NSString*) nickname;
- (void) updateFullname: (NSString*) nickname;
- (void) updatePlatfom;
- (void) updateDeviceInfo;
- (void) updateLocationInfo: (CLLocation*__nonnull) location;
- (void) updateZoneId: (NSInteger) zoneId;
- (void) updateAvatarUrl:(NSString*) avatarUrl;
- (void) updateUserAvatar: (NSURL*) url;
- (void) updateUserId:(NSInteger) userid;
- (FIRStorageUploadTask*__nullable) uploadImage:(UIImage*__nonnull) image  withPath: (NSString*__nullable) path handler: (void (^__nullable)(NSURL*__nullable url)) block;
- (void) updatePaymentMethod:(PaymentMethod) method;
- (void) findTrip: (NSString*) tripId handler:(void (^)(NSDictionary* value))completed;
#pragma mark - Drivers
- (void) driverChangedListener:(NSString*__nullable) key handler:(void (^__nullable)(FIRDataSnapshot*__nullable))completed;
- (void) removeDriverChangedListener;
- (void) driverDeadListener:(NSString*__nullable) key handler:(void (^__nullable)(FIRDataSnapshot*__nullable))completed ;
- (void) removeDriverDeadListener;
- (void) listenerDriverLocationChanged:(NSString*__nullable) driverFirebaseId callback: (void (^__nullable)(FCLocation * _Nullable))completed;
- (void) getDriver: (NSString*__nullable) driverId handler:(void (^__nullable)(FCDriver*__nullable))completed;
- (void) getLastLocationOfDriver:(NSString* __nonnull) driverFirebaseId callback: (void (^__nullable)(FCLocation * __nullable))completed;
- (void) getDriverKeepalive: (NSString*__nonnull) firebaseId  handler:(void (^__nullable)(FCOnlineStatus*__nullable))completed;

#pragma mark - Driver KeepAlive
- (void) registerDriverRealtime: (NSArray*__nullable) drivers
                        handler: (void (^__nullable)(FIRDataSnapshot*__nullable, BOOL isOnline))completed;

#pragma mark - Cars
- (void) getCarsDetail:(NSInteger) carId handler:(void (^__nullable)(FCMCar*__nullable))completed;
- (void) getListCarType:(NSInteger) groupid handler:(void (^__nullable)(NSMutableArray *__nullable))completed;
- (void) getListCarGroup:(void (^__nullable)(NSMutableArray *__nullable listCars))completed;
- (void) getCarType:(NSInteger) carTypeId handler:(void (^__nullable)(FCMCarType*__nullable))completed;

#pragma mark - FareSetting
- (void) getServerTime: (void (^)(NSTimeInterval)) block;
- (void) getFareDetail: (NSInteger) cartype
             atLocation: (CLLocation*__nonnull) location
                handler: (void (^__nullable)(FCFareSetting*__nullable))completed;
- (void) getListFareByLocation: (CLLocation*__nonnull) atlocation
                       handler: (void (^__nullable)(NSArray*__nullable))completed;

#pragma mark - Evalute
- (void) setEvalute: (FCEvalute* __nonnull) evalute;

#pragma mark - Favorites
- (void) requestAddFavorite: (FCFavorite*__nullable) fav withCompletionBlock:(void (^__nullable)(NSError *__nullable error, FIRDatabaseReference *__nullable ref))block;
- (void) removeFromFavoritelist: (FCFavorite*__nonnull) favorite handler:(void (^__nullable)(NSError *__nullable error, FIRDatabaseReference *__nullable ref))block;
- (void) getFavoriteInfo: (NSString*__nullable) forDriver handler:(void (^__nullable)(FCFavorite *__nullable fav))block;
- (void) getListFavorite:(void (^__nullable)(NSMutableArray*__nullable))completed;
- (void) checkBlockDirverInfo: (NSString*) forDriver handler:(void (^)(FCFavorite * fav))block;
#pragma mark - BackList
- (void) removeFromBacklist: (FCFavorite*__nullable) favorite handler:(void (^__nullable)(NSError *__nullable error, FIRDatabaseReference *__nullable ref))block;
- (void) getListBackList:(void (^__nullable)(NSMutableArray*__nullable))completed;

#pragma mark - App Settings
- (void) getAppSettings:(void (^__nullable)(FCSetting*__nullable))completed;
- (void) getUserConfigs:(void (^__nullable)(FCConfigs*__nullable config))completed;
- (void) getZoneById: (NSInteger) zoneId handler:(void (^__nullable)(FCZone*__nullable)) completed;
- (void) getZoneByLocation: (CLLocationCoordinate2D) location handler:(void (^__nullable)(FCZone*__nullable)) completed;
- (void)getPunishmentForTrip:(FCBookInfo*__nonnull)trip
              withCompletion:(void (^__nullable)(CGFloat))completed;
- (void) getShipService: (void (^__nullable)(NSMutableArray*__nullable list)) handler;
- (void) getAppConfigure:(void (^__nullable)(FCAppConfigure*__nullable appconfigure))completed;
- (void) getInviteContent:(void (^__nullable)(FCMInvite *__nullable))completed;
- (void) getPriceAdditional: (void (^) (NSMutableArray*__nullable list)) block;
- (void) getGoogleMapKeys: (void (^__nullable)(NSString*__nullable key)) block;
- (void) resetMapKeys;
- (BOOL) isInPeakHours;

#pragma mark - Services
- (void) getServices:(CLLocation*__nonnull) atLocation
             handler:(void (^__nullable)(NSMutableArray*__nullable))completed;

- (void) getPartners:(CLLocation*__nonnull) atLocation
             handler:(void (^__nullable)(NSMutableArray*__nullable))completed;

#pragma mark - authenticate sms
- (void)authenWithPhone:(NSString * _Nonnull)phone complete:(void (^ _Nonnull)(NSString * _Nonnull))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error;
- (void)authenWithOtp:(NSString * _Nonnull)otp use:(NSString * _Nonnull)verify complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error;
- (void)authenWithCustomToken:(NSString * _Nonnull)customToken complete:(void (^ _Nonnull)(id <UserProtocol> _Nullable))complete error:(void (^ _Nonnull)(NSError * _Nonnull))error;
- (void)authenTrackingWithService:(NSInteger)type;
- (NSString*) getAuthServiceName;
- (void) removeClientCurrentTrip;
- (void) writeClientCurrentTrip:(NSString *)tripId;
/*
 - (void) writeClientCurrentRating:(FCBookInfo *)bookInfo;
 - (void) removeCurrentRating;
 */
@end
