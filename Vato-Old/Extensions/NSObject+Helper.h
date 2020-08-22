//
//  NSObject.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface NSObject (Helper)

- (void) saveAppVersion :(NSString*) version;
- (NSString*) getCurrentAppVersion;

- (BOOL) giftAvailable: (FCGift*) gift
                client: (FCClient*) client;
- (BOOL) isNetworkAvailable ;
- (void) circleImageview : (UIImageView*) imageview;
- (void) playsound: (NSString*) soundname;
- (void) playsound:(NSString *)soundname withVolume:(CGFloat)volume isLoop:(BOOL)loop;
- (void) playsound:(NSString *)soundname
            ofType:(NSString*) type
        withVolume:(CGFloat)volume
            isLoop:(BOOL)loop;
- (double) getCurrentTimeStamp;
- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font;
- (NSString*) getTimeString:(double) timeStamp;
- (NSString*) getDateTimeString:(double)timeStamp;
- (NSString*) getTimeString:(long long) timeStamp withFormat: (NSString*) format;
- (NSString*) getTimeStringByDate:(NSDate*)date;
- (double) getTimestampOfDate:(NSDate *)date;
- (__autoreleasing NSString*) getAppVersion;
- (__autoreleasing NSString *)getBundleIdentifier;
- (NSString*) getDeviceId;
- (CLLocationDistance) getDistance:(CLLocation*) from fromMe: (CLLocation*) to;
- (CLLocationDistance) getDistanceByCoordinate:(CLLocationCoordinate2D) from fromMe: (CLLocationCoordinate2D) to;
- (NSString*) convertAccessString : (NSString*)input;
- (long) caculatePrice : (FCFareSetting*) receipe distance: (long) distance duration: (long) duration timeWait: (long) wait;
- (NSString*) formatPrice :(long) priceNum;
- (void) callPhone: (NSString*) phone;
- (NSInteger) getPrice : (NSString*) str;
- (NSString*) formatPrice:(long)priceNum withSeperator:(NSString *)seperator;
- (BOOL) validPhone :(NSString*) phone;
- (BOOL) validatePhone:(NSString *)phoneNumber;
- (BOOL) validEmail :(NSString*) email;

- (NSString*) formatNumber:(NSUInteger)n toBase:(NSUInteger)base;

- (BOOL) isPhoneX;
- (BOOL) isIpad;
- (void)openWifiSettings;
@end

@interface NSArray<ObjectType>(Extension)
- (ObjectType _Nullable)firstBy: (BOOL (^)(ObjectType _Nonnull))condition;
@end

@interface NSObject(Cast)
+ (instancetype _Nullable)castFrom:(id _Nullable)obj;
@end

