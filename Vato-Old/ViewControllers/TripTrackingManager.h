//  File name   : TripTrackingManager.h
//
//  Author      : Dung Vu
//  Created date: 10/3/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

@import Foundation;

@class RACSignal;
NS_ASSUME_NONNULL_BEGIN
@interface TripTrackingManager : NSObject
@property (strong, nonatomic) RACSignal *errorSignal;
@property (strong, nonatomic) RACSignal *bookingSignal;
@property (strong, nonatomic) RACSignal *commandSignal;
@property (strong, nonatomic) RACSignal *bookInfoSignal;
@property (strong, nonatomic) RACSignal *bookExtraSignal;
@property (strong, nonatomic) RACSignal *bookEstimateSignal;
- (instancetype)init:(NSString *)tripId;
+ (RACSignal *)loadTrip:(NSString *)tripId;
/**
 Set data to database

 @param path path to set value
 @param json value need to update
 @param update override / update
 */
- (void)setDataToDatabase:(NSString *)path json:(NSDictionary *)json update:(BOOL)update;

- (void)setMutipleDataToDatabase:(NSDictionary *)jsons
                          update:(BOOL)update;
@end
NS_ASSUME_NONNULL_END

