//
//  FCHomeViewModel.h
//  FaceCar
//
//  Created by vudang on 5/24/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FCSearchDriverModel;
@class FCBookViewModel;
@class FCFareModifier;
@class FCClient;
@class FCMCarType;

@interface FCHomeViewModel : NSObject

@property (weak, nonatomic) UIViewController* viewController;
@property (assign, nonatomic) NSInteger totalUnreadNotify;
@property (assign, nonatomic) NSInteger countGift;
@property (strong, nonatomic) NSMutableArray* listProduct;
@property (strong, nonatomic) NSMutableArray* listDriverOnline;
@property (strong, nonatomic) NSMutableArray* listPartner;

@property (strong, nonatomic) FCClient* client;
@property (strong, nonatomic) FCBookViewModel* bookViewModel;
@property (strong, nonatomic) FCSearchDriverModel* currentSearchData; // data for search driver online
@property (strong, nonatomic) FCPlace* lastestStart;

- (instancetype) initViewModle: (UIViewController*) rootVC;
+ (FCHomeViewModel*) getInstace;

- (void) checkingLastestBooking;
- (void) checkInviteDynamicLink;
- (void) checkingValidAuth;
- (void) checkingStartChanged: (FCPlace*) start;
- (void) checkingServiceSelected: (FCMCarType*) serice;
- (void) checkOverBalance: (void (^)(BOOL)) block;
- (void) updatePaymentMethod:(PaymentMethod)methodSelected;

- (FCSearchDriverModel*) getSearchModel;
- (void) getListDriverOnline: (FCSearchDriverModel*) params
                       block: (void (^)(NSMutableArray* list)) block;

- (void) loadSearchPlaceView: (NSInteger) type
                      inView: (UIView*) inView
                       block: (void (^) (BOOL cancelView, BOOL completedView)) block;

- (void) setNotifyBadge: (NSInteger) badge;

// layout
- (void) loadMainBookView;
- (void) loadListPromotionView: (BOOL) fromLaucher;
- (void) loadListTaxiView: (CGPoint) from;
- (void) loadConfirmBookingView;
- (void) loadConfirmShipInfoView;
- (void) loadLocationServiceNotifyView: (BOOL) serviceEnable; // notify enable location serivice view
- (void) loadBookingRequestView: (void (^) (void)) completed;
- (void) hideRequestBookingView: (void (^) (void)) completed;
- (void) loadPaymentMethodOptionView;
@end
