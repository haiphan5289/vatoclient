//
//  FCBookingRequestViewController.h
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FCHomeViewModel;
@class FCTripInfoView;
@class FCDriverSearch;

/*
 @property(nonatomic, assign) NSInteger  price;
 @property(nonatomic, assign) NSInteger  additionPrice;
 @property(nonatomic, assign) NSInteger  promotionValue;
 @property(nonatomic, strong) NSString*  promotionCode;
 @property(nonatomic, strong) NSString*  clientFirebaseId;
 @property(nonatomic, assign) NSInteger  clientUserId;
 @property(nonatomic, strong) NSString*  driverFirebaseId;
 @property(nonatomic, assign) NSInteger  driverUserId;
 @property(nonatomic, strong) NSString*  contactPhone;
 @property(nonatomic, assign) NSInteger  tripType;
 @property(nonatomic, assign) NSInteger  distance;
 @property(nonatomic, assign) NSInteger  duration;
 @property(nonatomic, assign) PaymentMethod  payment;
 @property(strong, nonatomic) NSString* note;
 
 // start place
 @property(strong, nonatomic) NSString* startName;
 @property(strong, nonatomic) NSString* startAddress;
 @property(assign, nonatomic) double startLat;
 @property(assign, nonatomic) double startLon;
 @property(assign, nonatomic) NSInteger zoneId;
 
 // end place
 @property(strong, nonatomic) NSString* endName;
 @property(strong, nonatomic) NSString* endAddress;
 @property(assign, nonatomic) double endLat;
 @property(assign, nonatomic) double endLon;
 
 // service
 @property(assign, nonatomic) NSInteger serviceId;
 @property(strong, nonatomic) NSString* serviceName;
 
 // promotion
 @property(assign, nonatomic) NSInteger modifierId;
 @property(assign, nonatomic) NSInteger farePrice;
 @property(assign, nonatomic) NSInteger fareClientSupport;
 @property(assign, nonatomic) NSInteger fareDriverSupport;
 */

/*
MISSING
 - polyline
 - clientFirebaseId
 - clientUserId
 */

@protocol FCBookingRequestViewControllerDelegate <NSObject>
- (void) onBookingCompleted;
- (void) onBookingFailed;
@end

@interface FCBookingRequestViewController : UIViewController
@property (strong, nonatomic) NSDictionary* bookInfo;
@property (weak, nonatomic) id<FCBookingRequestViewControllerDelegate> delegate;

- (void) loadStatusView: (FCDriverSearch*) driver;
- (void) dismissView: (void (^ __nullable)(void))completion;
@end

