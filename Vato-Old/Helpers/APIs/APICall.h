//
//  AFNetworkingHelper.h
//  FaceCar
//
//  Created by Vu Dang on 7/10/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCBalance.h"

@interface APICall : NSObject

+ (APICall*_Nonnull) shareInstance;

- (void) apiSearchDriver:(NSDictionary*_Nonnull) params  completeHandler:(void (^_Nonnull)(NSMutableArray*_Nonnull)) completed;
- (void) apiSearchDriverForBooking:(NSDictionary*__nonnull) params  completeHandler:(void (^_Nonnull)(NSMutableArray*_Nonnull)) completed;
- (void) apiGetRefferalCodeWithComplete:(void (^__nullable)(NSString*__nullable)) completed;
- (void) apiVerifyRefferalCode :(NSString*_Nonnull) code withComplete:(void (^__nullable)(NSString*__nullable, BOOL)) completed;
- (void) apiGetInvoicesList:(NSDictionary*__nullable) params block:(void (^__nullable)(NSArray*__nullable, BOOL)) completed;
- (void) checkingNetwork;
- (void) apiGetBalance: (void (^)(FCBalance* balance)) block;
- (void) apiUpdateProfile:(NSString*) email
                 nickname:(NSString*) nickname
                 fullname:(NSString*) fullname
                   avatar:(NSString*) avatar
                  handler:(void (^)(NSError * error)) block;
- (void) apiSigOut;
@end
