//
//  FCBookViewModel.m
//  FaceCar
//
//  Created by facecar on 12/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCBookViewModel.h"
#import "FCTripViewModel.h"
#import "TripMapsViewController.h"
#import "FirebasePushHelper.h"
#import "GoogleMapsHelper.h"
#import "FCBookingService.h"
#import "UserDataHelper.h"
#import "FCBookingRequestViewController.h"
#import "AppDelegate.h"
#import "FCHomeViewController.h"
#import "FCFareService.h"

#define TIMEOUT_SENDING 30
#define TIMEOUT_CAPTURE_BOOK 20

@interface FCBookViewModel ()
@property (strong, nonatomic) NSTimer* sendingBookingTimeout;
@end

@implementation FCBookViewModel {
    FCBookingService* _bookingService;
    AppDelegate* _appdelegate;
    FCBookingRequestViewController* _requestView;
    NSMutableDictionary* _listModifier;
}

- (id) init {
    self = [super init];
    if (self) {
        self.priceDict = [[NSMutableDictionary alloc] init];
        
//        self.serviceSelected = [self getLastestService]; // from local
        _bookingService = [FCBookingService shareInstance];
        _appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        
        [RACObserve(self, distance) subscribeNext:^(id x) {
        }];
        
        [RACObserve(self, serviceSelected) subscribeNext:^(id x) {
            if (x) {
                [self saveLastService:x]; // cache to local
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNerworkConnected)
                                                     name:NOTIFICATION_NETWOTK_CONNECTED
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNerworkDisConnected)
                                                     name:NOTIFICATION_NETWORK_DISCONNECTED
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onEnterBackground)
                                                     name:NOTIFICATION_ENTER_BACKGROUND
                                                   object:nil];
    }
    
    return self;
}

- (void) onNerworkConnected {
}

- (void) onNerworkDisConnected {
    [self stopAllTimers];
}

- (void) onEnterBackground {

}

- (void) setClient:(FCClient *)client {
    _client = client;
    self.paymentMethod = client.paymentMethod;
}

- (void) stopAllTimers {
    [_sendingBookingTimeout invalidate];
}

- (void) setBookingData:(FCBooking*) booking {
    self.booking = booking;
    FCBookInfo* bookInfo = booking.info;
    
    {
        FCPlace* start = [[FCPlace alloc] init];
        start.name = bookInfo.startName;
        start.address = bookInfo.startAddress;
        start.location = [[FCLocation alloc] initWithLat:bookInfo.startLat
                                                     lon:bookInfo.startLon];
        start.zoneId = bookInfo.zoneId;
        self.start = start;
    }
    
    
    if (bookInfo.endLat != 0 && bookInfo.endLon != 0) {
        FCPlace* end = [[FCPlace alloc] init];
        end.name = bookInfo.endName;
        end.address = bookInfo.endAddress;
        end.location = [[FCLocation alloc] initWithLat:bookInfo.endLat
                                                   lon:bookInfo.endLon];
        self.end = end;
    }
    
    {
        FCMCarType* service = [[FCMCarType alloc] init];
        service.id = bookInfo.serviceId;
        service.name = bookInfo.serviceName;
        self.serviceSelected = service;
    }
    
    
    self.distance = bookInfo.distance;
    self.duration = bookInfo.duration;
}

- (void) clear {
    self.start = nil;
    self.end = nil;
    self.priceDict = nil;
    self.distance = 0;
    self.duration = 0;
    self.contactPhone = nil;
//    self.additonPrice = 0;
}

- (void) loadMapsTripView {
    [self hideRequestBookingView:^{
        // load map trip
        FCTripViewModel* model = [[FCTripViewModel alloc] initViewModel:self.booking
                                                                cartype:self.booking.info.serviceId
                                                            fromManager:NO];
        
        TripMapsViewController* mapsTrip = [[TripMapsViewController alloc] initViewController:model];
//        mapsTrip.bookViewModel = self;
        [self.viewController presentViewController:mapsTrip
                                          animated:YES
                                        completion:^{
                                        }];
    }];
}

- (void) hideRequestBookingView: (void (^) (void)) completed {
    if ([self.viewController isKindOfClass:[FCHomeViewController class]]) {
        [((FCHomeViewController*) self.viewController).homeViewModel hideRequestBookingView: completed];
    }
    
    _requestView = nil;
}

#pragma mark - Price Calculate
- (void) getPrices {
    if (self.distance > 0) {
        CLLocation* location = [[CLLocation alloc] initWithLatitude:_start.location.lat longitude:_start.location.lon] ;
        [[FirebaseHelper shareInstance] getListFareByLocation:location handler:^(NSArray * receipts) {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            for (FCFareSetting* r in receipts) {
                if (r) {
                    NSInteger price = [self caculatePrice:r
                                                 distance:self.distance
                                                 duration:self.duration
                                                 timeWait:0];
                    [dict setValue:@(price)
                            forKey:[NSString stringWithFormat:@"%ld", r.service]];
                }
            }
            
            self.priceDict = dict;
        }];
    }
    else {
        self.priceDict = nil;
    }
}

- (NSInteger) getPriceForSerivce: (NSInteger) serivceid {
    if (!self.priceDict) {
        return 0;
    }
    
    return [[self.priceDict valueForKey:[NSString stringWithFormat:@"%ld", (long)serivceid]] integerValue];
}

- (NSInteger) getPriceAfterDiscountForService:(NSInteger) serviceId {
    FCFareModifier* modifier = [self getMofdifierForService:serviceId];
    NSInteger originPrice =  [self getPriceForSerivce:serviceId];
    if (modifier) {
        NSArray* fare = [FCFareService getFareAddition:originPrice additionFare:0 modifier:modifier];
        NSInteger newPrice = [[fare objectAtIndex:0] integerValue];
        NSInteger clientSupport = 0;//[[fare objectAtIndex:2] integerValue];
        return MAX(newPrice-clientSupport, 0);
    }
    else {
        return originPrice;
    }
}

- (void) saveModifier: (FCFareModifier*) modifier service: (NSInteger) service {
    if (modifier) {
        if (!_listModifier) {
            _listModifier = [[NSMutableDictionary alloc] init];
        }
        
        [_listModifier setObject:modifier forKey:@(service)];
    }
    else {
        if ([_listModifier objectForKey:@(service)]) {
            [_listModifier removeObjectForKey:@(service)];
        }
    }
}

- (FCFareModifier*) getMofdifierForService: (NSInteger) service {
    if (_listModifier) {
        return [_listModifier objectForKey:@(service)];
    }
    return nil;
}

#pragma mark - Booking Progress
- (FCBookInfo*) createTempBookInfo {
    AppLog([FIRAuth auth].currentUser.uid)
    
    FCMCarType* forService = self.serviceSelected;
    FCBookInfo* book = [[FCBookInfo alloc] init];
    book.clientFirebaseId = [FIRAuth auth].currentUser.uid;
    book.clientUserId = self.client.user.id;
    
    // start info
    book.startName = self.start.name;
    book.startAddress = self.start.address;
    book.startLat = self.start.location.lat;
    book.startLon = self.start.location.lon;
    book.zoneId = self.start.zoneId;
    
    // end info
    if (self.end) {
        book.endName = self.end.name;
        book.endAddress = self.end.address;
        book.endLat = self.end.location.lat;
        book.endLon = self.end.location.lon;
    }
    
    // service
    book.serviceName = forService.name;
    book.serviceId = forService.id;
    
    // payment method
    book.payment = self.paymentMethod;
    
    NSInteger originPrice = [self getPriceForSerivce:forService.id];
    book.price = originPrice;
    //    book.additionPrice = self.additonPrice;
    book.contactPhone = self.contactPhone.length > 0 ? self.contactPhone : self.client.user.phone;
    book.duration = self.duration; // second
    book.distance = self.distance;
    
    if (self.end) {
        book.tripType = BookTypeFixed;
    }
    else {
        book.tripType = BookTypeOneTouch;
    }
    
    return book;
}

- (FCBookInfo*) crateBookingData {
    FCBookInfo* info = [self createTempBookInfo];
    
    // extra info
    FCBookExtra* extra = [[FCBookExtra alloc] init];
    extra.polylineIntrip = self.polyline;
    
    self.booking = [[FCBooking alloc] init];
    self.booking.info = info;
    self.booking.extra = extra;
    
    return info;
}

- (void) crateBookingData: (FCBookInfo*) info {
    // extra info
    FCBookExtra* extra = [[FCBookExtra alloc] init];
    extra.polylineIntrip = self.polyline;
    
    self.booking = [[FCBooking alloc] init];
    self.booking.info = info;
    self.booking.extra = extra;
}

- (CGFloat) getBookingRadius {
    float result = 2.0f;
    NSArray* bookRadius = [FirebaseHelper shareInstance].appConfigure.booking_radius;
    FCBookRadius* choose = nil;
    
    for (FCBookRadius* radius in bookRadius) {
        if (radius.zoneId == ZONE_VN) {
            choose = radius;
        }
        if (radius.zoneId == self.start.zoneId) {
            choose = radius;
            break;
        }
    }
    
    if (choose) {
        if (self.distance < choose.minDistance*1000) {
            result = choose.min;
        }
        else {
            result = choose.min + (self.distance/1000 - choose.minDistance) * choose.percent/100.0f;
            result = MIN(result, choose.max);
        }
    }
    NSString* res = [NSString stringWithFormat:@"%.02f", result];
    return [res floatValue];
}

- (void) setListDriverForRequest:(NSMutableArray *)listDriverForRequest {
    _listDriverForRequest = listDriverForRequest;
    
    if (listDriverForRequest.count > 0) {
        [self sendNextBook];
    }
    else {
        self.bookResult = FCBookingResultCodeDontHaveDriver;
    }
    
}

- (void) cancelRequestBooking {
    // cancel current book timeout
    [self stopAllTimers];
    
    // remove listener
    [_bookingService removeBookingListener];
    
    self.bookResult = FCBookingResultCodeReset;
}

- (void) sendNextBook {
    
    // sent all driver
    if (self.listDriverForRequest.count == 0) {
        self.bookResult = FCBookingResultCodeNoDriverAccept;
        _requestView = nil;
        return;
    }
    
    // sending next book
    FCDriverSearch* nextDriver = [self.listDriverForRequest firstObject];
    
    // pop first
    [self.listDriverForRequest removeObjectAtIndex:0];
    
    // checking lastest driver info
    // status == READY
    // lastime online minimun is 5 mins
    [[FirebaseHelper shareInstance] getDriverKeepalive:nextDriver.firebaseId
                                               handler:^(FCOnlineStatus * keepaliveInfo) {
        
        CLLocation* driverLo = [[CLLocation alloc] initWithLatitude:keepaliveInfo.location.lat
                                                          longitude:keepaliveInfo.location.lon];
        if (driverLo.coordinate.latitude == 0 || driverLo.coordinate.longitude == 0) {
            driverLo = [[CLLocation alloc] initWithLatitude:nextDriver.location.lat
                                                  longitude:nextDriver.location.lon];
        }
        
                                                   
        NSInteger dis = 0;
                                                   
        if (self.booking.info.startLat != 0) {
            CLLocation* myLo = [[CLLocation alloc] initWithLatitude:self.booking.info.startLat
                                                          longitude:self.booking.info.startLon];
            dis = [myLo distanceFromLocation:driverLo];
        }
        
        BOOL isValidRadius =  dis < [self getBookingRadius] * 1000;
        BOOL isOnline = keepaliveInfo.status == DRIVER_READY;
        long long time = [self getCurrentTimeStamp];
        BOOL isValidTimeOnline = keepaliveInfo.lastOnline > 0 && (time - keepaliveInfo.lastOnline) < 10*60*1000;
        if (keepaliveInfo &&
            isOnline &&
            isValidTimeOnline &&
            isValidRadius) {
            
            self.booking.info.driverFirebaseId = nextDriver.firebaseId;
            self.booking.info.driverUserId = nextDriver.id;
            self.booking.extra.driverCash = nextDriver.cash;
            self.booking.extra.driverCoin = nextDriver.coin;
            
            // clear old
            self.booking.command = nil;
            self.booking.tracking = nil;
            self.booking.estimate = nil;
            
            // write booking to firebase for realtime
            [_bookingService sendingBooking:self.booking
                                   complete:^(NSError *error, FIRDatabaseReference *ref) {
                                       if (!error) {
                                           [self onSent:nextDriver];
                                       }
                                       else {
                                           [self sendNextBook];
                                       }
                                   }];
        }
        else {
            [self sendNextBook];
        }
    }];
}

- (void) onSent: (FCDriverSearch*) driver {
    
    // send push notification
    [self pushBookInfoToDriver];
    
    // start booking timeout: 30s for each
    self.sendingBookingTimeout = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_SENDING
                                                                  target:self
                                                                selector:@selector(onSendingBookTimeout)
                                                                userInfo:nil
                                                                 repeats:NO];
    
    // cache book to local for checking if quit app when requesting
    [[UserDataHelper shareInstance] saveLastestTripbook: self.booking.info
                                             currentCar: self.booking.info.serviceId];
    
    // show "Đang liên hệ với lái xe ABC.."
    [NSTimer scheduledTimerWithTimeInterval:0.35f
                                     target:self
                                   selector:@selector(showConnectingStatus:)
                                   userInfo:driver
                                    repeats:NO];
    
    [self listenerBookingChange];
}

- (void) showConnectingStatus: (NSTimer*) sender {
    FCDriverSearch* nextDriver = sender.userInfo;
    if (_requestView) {
        [_requestView loadStatusView:nextDriver];
    }
    else {
        UIViewController* topvc = [_appdelegate visibleViewController:self.viewController];
        if ([topvc isKindOfClass:[FCBookingRequestViewController class]]) {
            _requestView = (FCBookingRequestViewController*) topvc;
            [_requestView loadStatusView:nextDriver];
        }
    }
}

- (void) onSendingBookTimeout {
    [_bookingService updateBookStatus:BookStatusClientTimeout];
}

- (void) pushBookInfoToDriver {
    [[FirebaseHelper shareInstance] getDriver:self.booking.info.driverFirebaseId
                                      handler:^(FCDriver * driver) {
                                          if (driver.deviceToken.length > 0) {
                                              [FirebasePushHelper sendPushTo:driver.deviceToken
                                                                        type:NotifyTypeNewBooking
                                                                       title:@"Bạn có chuyến xe mới"
                                                                     message:[NSString stringWithFormat:@"Đón tại: %@", self.booking.info.startName]];
                                          }
                                      }];
    
}

- (void) listenerBookingChange {
    [_bookingService listenerBookingStatusChange:^(FCBookCommand *stt) {
        NSInteger status = stt.status;
        
        if (status == BookStatusDriverAccepted) {
            // stop sending
            [self.sendingBookingTimeout invalidate];
            
            // clear all
            [self.listDriverForRequest removeAllObjects];
            
            // notify agree accept
            [_bookingService updateBookStatus:BookStatusClientAgreed];
            
            self.bookResult = FCBookingResultCodeSuccess;
            
            [self loadMapsTripView];
        }
        else if ([_bookingService isAdminCanceled] ||
                 [_bookingService isDriverCanceled]) {
            
            // cancel current timer
            [self.sendingBookingTimeout invalidate];
            
            // send next book
            [self sendNextBook];
        }
        else if (status == BookStatusClientTimeout) {
            // send next book
            [self sendNextBook];
        }
        else if (status == BookStatusClientCancelInBook) {
            [self hideRequestBookingView: nil];
        }
    }];
}


#pragma mark - Booking Handler

- (void) onHandlerNewBookStatus: (FCBookCommand*) newStatus {
    if (newStatus.status == BookStatusClientCreateBook) {
        
    }
    else if (newStatus.status == BookStatusDriverAccepted) {
        
    }
    else if (newStatus.status == BookStatusStarted) {
        
    }
    else if (newStatus.status == BookStatusCompleted) {
        
    }
    else if (newStatus.status == BookStatusDriverCancelInBook) {
        
    }
    else if (newStatus.status == BookStatusDriverCancelIntrip) {
        
    }
    else if (newStatus.status == BookStatusDriverMissing) {
        
    }
    else if (newStatus.status == BookStatusDriverDontEnoughMoney) {
        
    }
    else if (newStatus.status == BookStatusClientCancelIntrip) {
        
    }
    else if (newStatus.status == BookStatusAdminCancel) {
        
    }
}

#pragma mark - Cache
- (void) saveLastService: (FCMCarType*) service {
    if (service) {
        [[NSUserDefaults standardUserDefaults] setObject:[service toJSONString]
                                                  forKey:@"lastest-service-selected"];
    }
}

- (FCMCarType*) getLastestService {
    NSString* service = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastest-service-selected"];
    return [[FCMCarType alloc] initWithString:service
                                        error:nil];
}

- (void) findDefaultService : (NSMutableArray*) listProduct {
    if (self.serviceSelected) {
        return;
    }
    
//    FCMCarType* first = [self getLastestService];
//    if (first) {
//        return;
//    }
    
    FCMCarType* first =  nil;
    for (FCService* prod in listProduct) {
        for (FCMCarType* ser in prod.cartypes) {
            if (!first) {
                first = ser;
            }
            
            if (ser.choose) {
                self.serviceSelected = ser;
                return;
            }
        }
    }
    
    if (first) {
        self.serviceSelected = first;
    }
}

@end
