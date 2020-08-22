//
//  FCBookViewModel.h
//  FaceCar
//
//  Created by facecar on 12/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCFareModifier.h"
#import "Enums.h"

typedef NS_ENUM(NSInteger, FCBookingResultCode) {
    FCBookingResultCodeCompleted = -1, // finished book
    FCBookingResultCodeSuccess = 1, // driver and client ready connected together (status book = 30)
    
    FCBookingResultCodeReset = 0, // reset book
    
    FCBookingResultCodeClientCancelInBook = 2,
    FCBookingResultCodeClientCancelInTrip = 21,
    
    FCBookingResultCodeDontHaveDriver = 4,
    FCBookingResultCodeNoDriverAccept = 5,
    
    FCBookingResultCodeTimeout = 6,
    
    FCBookingResultCodeRetryBook = 7 // driver cancel intrip and client want to retry another
};


@interface FCBookViewModel : NSObject

@property (strong, nonatomic) FCPlace* start;
@property (strong, nonatomic) FCPlace* end;
@property (assign, nonatomic) NSInteger distance; // khoang cach lo trinh
@property (assign, nonatomic) NSInteger duration; // thoi gian lo trinh
@property (strong, nonatomic) FCClient* client;
@property (strong, nonatomic) FCGift* stationEvent; // event cho station dang applied
@property (assign, nonatomic) PaymentMethod paymentMethod;

@property (strong, nonatomic) FCMCarType* serviceSelected;
@property (assign, nonatomic) BOOL favDriver; // tx rieng
//@property (assign, nonatomic) NSInteger additonPrice;
@property (strong, nonatomic) NSString* contactPhone;
@property (strong, nonatomic) NSString* polyline;

// list price for each service when choose full trip directions
@property (strong, nonatomic) NSMutableDictionary* priceDict;

// for booking
@property (strong, nonatomic) FCBooking* booking; // data for booking request
@property (strong, nonatomic) NSMutableArray* listDriverForRequest; // list driver online for booking
@property (assign, nonatomic) FCBookingResultCode bookResult;
@property (strong, nonatomic) UIViewController* viewController;


- (void) setBookingData: (FCBooking*) book; // for current booking
- (NSInteger) getPriceForSerivce:(NSInteger) serivceid;
- (NSInteger) getPriceAfterDiscountForService:(NSInteger) serviceId;
- (void) findDefaultService : (NSMutableArray*) listProduct;
- (void) saveModifier: (FCFareModifier*) modifier service: (NSInteger) service;
- (FCFareModifier*) getMofdifierForService: (NSInteger) service;

- (FCBookInfo*) createTempBookInfo; // for temptrip
- (FCBookInfo*) crateBookingData; // for full trip
- (void) cancelRequestBooking;
- (CGFloat) getBookingRadius;
- (void) loadMapsTripView; // trip maps view
- (void) getPrices; // get list price for all service
- (void) clear;
- (void) stopAllTimers;

- (void) crateBookingData: (FCBookInfo*) info;

@end
