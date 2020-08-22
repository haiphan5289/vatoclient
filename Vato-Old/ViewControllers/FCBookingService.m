//
//  FCBookViewModel.m
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCBookingService.h"
#import "FCHomeViewModel.h"
#import "AppDelegate.h"
#import "UserDataHelper.h"
#import "GoogleMapsHelper.h"
#import "NSData+CRC32.h"
#import "TripTrackingManager.h"

#define kBookStatus @"command"
#define kBookInfo @"info"
#define kBookTracking @"tracking"
#define kBookEstimate @"estimate"
#define kBookExtra @"extra"

#define kBookingTimeout 25

@interface FCBookingService ()
@property (strong, nonatomic) NSTimer* timerBookingTimeout;
@property (strong, nonatomic) TripTrackingManager *trackManager;
@end

@implementation FCBookingService {
    FIRDatabaseHandle _newBookingHandler;
    FIRDatabaseHandle _bookingStatusHandler;
    FIRDatabaseHandle _bookingInfoHandler;
    FIRDatabaseHandle _bookingDetailHandler;
    FIRDatabaseHandle _bookingExtraHandler;
    FIRDatabaseHandle _bookingEstimateHandler;
    FIRDatabaseHandle _bookingEstimateNotifyHandler;
    FIRDatabaseHandle _bookingExtraNotifyHandler;
    FIRDatabaseHandle _bookingNotifyHandler;
    AppDelegate* _appDelegate;
    UIAlertController* _popup;
}

static FCBookingService* instance = nil;
+ (FCBookingService*) shareInstance {
    if (instance == nil) {
        instance = [[FCBookingService alloc] init];
    }
    
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return self;
}

- (void)setBook:(FCBooking *)book {
    _book = book;
    if (!_trackManager) {
        self.trackManager = [[TripTrackingManager alloc] init:self.book.info.tripId];
        [[FireBaseTimeHelper default] startUpdate];
    }
}

- (void) showErrorRequestBooking {
    AppDelegate* delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    UIViewController* vc = [delegate visibleViewController:delegate.window.rootViewController];
    [AlertVC showAlertObjcOn: vc
                       title:localizedFor(@"Thông báo")
                     message:localizedFor(@"Hiện tại bạn chưa thể tiếp tục đặt xe, vui lòng thử lại sau.")
                    actionOk:localizedFor(@"Đóng")
                actionCancel:nil
                  callbackOK:^{
                      [[UserDataHelper shareInstance] removeLastestTripbook];
                      [[FCHomeViewModel getInstace] hideRequestBookingView:nil];
                  }
              callbackCancel:^{
              }];
}

- (void) getDriverCurrentTrip: (NSString*) driverFirebaseId
                      handler: (void (^) (NSString* tripid)) block {
    @try {
        FIRDatabaseReference* bookRef = [[[FirebaseHelper shareInstance].ref child:TABLE_DRIVER_TRIP] child:driverFirebaseId];
        [bookRef keepSynced:YES];
        [bookRef observeSingleEventOfType:FIRDataEventTypeValue
                                withBlock:^(FIRDataSnapshot * snapshot) {
                                    block (snapshot.value);
                                }];
        
    }
    @catch (NSException* e) {}
}

/**
 Kiểm tra book vẫn đang xử lý đúng hay không.

 @param book
 @return YES : nếu book vẫn đang được xử lý
 */
- (BOOL) bookIsAvailable: (FCBooking*) book {
    if (!book || !book.info || book.command.count == 0) {
        return NO;
    }
    
    if (book && book.info && book.command.count > 0) {
        for (FCBookCommand* stt in book.command) {
            if (stt.status == BookStatusDriverCancelInBook ||
                stt.status == BookStatusDriverCancelIntrip ||
                stt.status == BookStatusDriverDontEnoughMoney ||
                stt.status == BookStatusDriverMissing ||
                stt.status == BookStatusClientTimeout ||
                stt.status == BookStatusDriverBusyInAnotherTrip ||
                stt.status == BookStatusClientCancelInBook ||
                stt.status == BookStatusClientCancelIntrip ||
                stt.status == BookStatusCompleted) {
                return NO;
            }
        }
    }
    
    FCBookCommand* last = [self getLastBookStatus:book];
    if (last) {
        NSInteger detal = [self getCurrentTimeStamp] - last.time;
        if (detal > 30) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Booking listener

/**
 Listener trạng thái mới được ghi nhận từ cả 2 bên.
 Nếu trạng thái mới nhận chưa tồn tại thì xử lý. Ngược lại thì bỏ qua
 - Check status để confirm với backend
 - Check list status hiện tại
 
 @param handler : callback trạng thái mới được add đúng (như mô tả ở trên) để tiếp tục xử lý
 */
- (void) listenerBookingStatusChange: (void (^) (FCBookCommand* status)) handler {
    @try {
        [[_trackManager commandSignal] subscribeNext:^(FCBookCommand *stt) {
            NSMutableArray* lst_status = [NSMutableArray arrayWithArray:self.book.command];
            if (lst_status == nil) {
                lst_status = [[NSMutableArray alloc] init];
            }
            if (stt && ![self existStatus:stt]) {
                [lst_status addObject:stt];
                NSArray* array = [lst_status sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
                    return obj1.status > obj2.status;
                }];
                
                self.book.command = [array copy];
                
                [self trackingBookInfo:stt];
                
                if ([self isFinishedTrip]) {
                    [self removeBookingListener];
                }
                
                handler(stt);
            }
        }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
    }
}

- (void)listenerBookDelete: (void (^)(void))handler {
    [[_trackManager errorSignal] subscribeNext:^(NSError* e) {
        if (handler) { handler(); }
    }];
}

- (void) listenerBookingInfoChange:(void (^)(FCBookInfo*))handler {
    @try {
        @weakify(self);
        [[_trackManager bookInfoSignal] subscribeNext:^(FCBookInfo* book_info) {
            @strongify(self);
            if (book_info) {
                self.book.info = book_info;
                handler(book_info);
            }
        }];
    }
    @catch (NSException* e) {
    }
}

- (void) listenerBookingExtraChange:(void (^)(FCBookExtra*))handler {
    @try {
        @weakify(self)
        [[_trackManager bookExtraSignal] subscribeNext:^(FCBookExtra *extra) {
            @strongify(self);
            if (extra) {
                self.book.extra = extra;
            }
            if (handler) {
                handler(extra);
            }
        }];
    }
    @catch (NSException* e) {
    }
}

- (void) listenerBookingExtraNotifyChange:(void (^)(FCBookExtra*))handler {
    @try {
        @weakify(self)
        [[_trackManager bookExtraSignal] subscribeNext:^(FCBookExtra *extra) {
            @strongify(self);
            if (extra) {
                self.book.extra = extra;
            }
            if (handler) {
                handler(extra);
            }
        }];
    }
    @catch (NSException* e) {
    }
}

- (void) listenerBookingEstimateChange:(void (^)(FCBookEstimate*))handler {
    @try {
        @weakify(self)
        [[_trackManager bookEstimateSignal] subscribeNext:^(FCBookEstimate *estimate) {
            @strongify(self);
            if (estimate) {
                self.book.estimate = estimate;
            }
            if (handler) {
                handler(estimate);
            }
        }];
    }
    @catch (NSException* e) {
    }
}

- (void) listenerBookingEstimateNotifyChange:(void (^)(FCBookEstimate*))handler {
    @try {
        @weakify(self)
        [[_trackManager bookEstimateSignal] subscribeNext:^(FCBookEstimate *estimate) {
            @strongify(self);
            if (estimate) {
                self.book.estimate = estimate;
            }
            if (handler) {
                handler(estimate);
            }
        }];
    }
    @catch (NSException* e) {
    }
}

- (void) getBookingDetail: (FCBookInfo*) booking
                  handler: (void (^)(FCBooking*))completed {
    @try {
        if ([booking.tripId length] == 0) {
            completed(nil);
            return;
        }
        
        @weakify(self);
         [[TripTrackingManager loadTrip:booking.tripId] subscribeNext:^(FCBooking *booking) {
             @strongify(self);
             if (booking && booking.info.tripId != 0) {
                 self.book = booking;
                 if ([self isInTrip] || [self isTripStarted] || [self isContactDriver]) {
                     completed(booking);
                     return;
                 }
             }
             completed(nil);
         } error:^(NSError *error) {
             completed(nil);
         }];
    }
    @catch (NSException* e) {
        DLog(@"Error: %@", e)
        
        completed(nil);
    }
}

- (void) removeBookingListener {
    @try {
        self.trackManager = nil;
        [[FireBaseTimeHelper default] stopUpdate];
    }
    @catch (NSException* e) {
        
    }
}

#pragma mark - Handler Booking data

/**
 Hàm lấy trạng thái cuối cùng được add vào list status
 Trang thái cuối cùng là trạng thái có time lớn nhất
 
 @param book: booking cần check status
 @return FCBookCommand nếu tôn tại list status, ngược lại return nil
 */
- (FCBookCommand*) getLastBookStatus {
    if (self.book.command.count > 0) {
        FCBookCommand* last = [self.book.command objectAtIndex:self.book.command.count-1];
        return last;
    }
    
    return nil;
}

- (FCBookCommand*) getLastBookStatus: (FCBooking*) book {
    if (book.command.count == 0) {
        return nil;
    }
    
    if (book.command.count == 1) {
        return book.command.firstObject;
    }
    
    NSArray* array = [book.command sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
        return obj1.status > obj2.status;
    }];
    
    return [array objectAtIndex:array.count - 1];
}


/*
 * Một booking hợp lệ phải thoả các điều kiện sau:
 * 1. Chưa có trạng thái kết thúc
 * 2. Thời gian tạo của booking (client write) không quá 5mins (tranh trường hợp khách book xong huỷ kết nối với app)
 */
- (BOOL) isBookingAvailable: (FCBooking*) book {
    if (book.info.timestamp > 0) {
        long long current = (long long) [self getCurrentTimeStamp];
        if (current - book.info.timestamp > 10*60*1000) {
            return NO;
        }
    }
    
    if ([self isFinishedTrip]) {
        return NO;
    }
    
    return YES;
}

- (BOOL) isNewBook {
    FCBookCommand* stt = [self getLastBookStatus];
    return stt.status == BookStatusClientCreateBook;
}

/**
 Trạng thái được xác đinh là đang trong chuyến đi thuộc danh sach sau:
 (chuyến đi đã bắt đầu (BookStatusStarted), lái xe đã chấp nhận chuyến và vào chuyến đi (BookStatusDriverAccepted),
 khách hàng đồng ý vào chuyến (BookStatusClientAgreed)
 
 @return YES nếu thoả mãn điều kiện trên.
 */
- (BOOL) isInTrip {
    FCBookCommand* currCmd = [self getLastBookStatus];
    if (currCmd) {
        if ( currCmd.status == BookStatusStarted ||
            currCmd.status == BookStatusDriverAccepted ||
            currCmd.status == BookStatusClientAgreed) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) isInToPickup {
    FCBookCommand* currCmd = [self getLastBookStatus];
    if (currCmd) {
        if (currCmd.status == BookStatusDriverAccepted ||
            currCmd.status == BookStatusClientAgreed) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) isDeliveryFail {
    FCBookCommand* currCmd = [self getLastBookStatus];
    if (currCmd) {
        if (currCmd.status == BookStatuDeliveryFail) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) isContactDriver {
    FCBookCommand* stt = [self getLastBookStatus];
    return stt.status == BookStatusClientCreateBook;
}

- (BOOL) isTripStarted {
    FCBookCommand* stt = [self getLastBookStatus];
    return stt.status == BookStatusStarted
    || stt.status == BookStatusDeliveryReceivePackageSuccess;
}

- (BOOL) isTripCompleted {
    FCBookCommand* stt = [self getLastBookStatus];
    return stt.status == BookStatusCompleted;
}

- (BOOL)isAllowCancelTrip {
    FCBookCommand* currCmd = [self getLastBookStatus];
    if (currCmd) {
        if ( currCmd.status == BookStatusClientCreateBook ||
            currCmd.status == BookStatusDriverAccepted ||
            currCmd.status == BookStatusClientAgreed) {
            return YES;
        }
    }
    return NO;
}

/**
 Trang thái được xác định là kết thúc một book phải thoả mãn trong danh sách sau:
 {hoan thanh, tai xe huy, khach hang huy, admin huy}
 
 @param status: trạng thái cần kiểm tra
 @return YES nếu thuộc danh sách trên. Ngược lại NO
 */
- (BOOL) isFinishedTrip {
    if ([self isDriverCanceled] || [self isClientCanceled] || [self isTripCompleted] || [self isAdminCanceled])
        return YES;
    
    return NO;
}

- (BOOL) isClientCancelInbook {
    FCBookCommand* stt = [self getLastBookStatus];
    if (stt.status == BookStatusClientTimeout ||
        stt.status == BookStatusClientCancelInBook ) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isClientCancelIntrip {
    FCBookCommand* stt = [self getLastBookStatus];
    return stt.status == BookStatusClientCancelIntrip;
}

- (BOOL) isClientCanceled {
    if ([self isClientCancelInbook] ||
        [self isClientCancelIntrip]) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isDriverCanceled {
    FCBookCommand* stt = [self getLastBookStatus];
    if (stt.status == BookStatusDriverCancelInBook ||
        stt.status == BookStatusDriverCancelIntrip ||
        stt.status == BookStatusDriverDontEnoughMoney ||
        stt.status == BookStatusDriverBusyInAnotherTrip ||
        stt.status == BookStatusDriverMissing) {
        return YES;
    }
    
    return NO;
}

- (BOOL) isAdminCanceled {
    FCBookCommand* stt = [self getLastBookStatus];
    return stt.status == BookStatusAdminCancel;
}

/*
 * Kiểm tra trạng thái "status" đã tồn tại trong list status của booking chưa
 * return:
 *  - YES nếu có
 *  - NO nếu không có
 */
- (BOOL) isExistStatus: (NSInteger) status {
    if (self.book.command.count > 0) {
        for (FCBookCommand* s in self.book.command) {
            if (s.status == status) {
                return YES;
            }
        }
    }
    
    return NO;
}

/*
 * Booking status được ghi theo cấu trúc:
 * Booking/<driver_firebase_id>/<booking_id>/booking_status
 * [
 *    D-10: {
 *       time: <firebase_server_time>,
 *       status: 10
 *    }
 * ]
 */

- (void) updateBookStatus: (NSInteger) status {
    if ([self isExistStatus:status]) {
        return;
    }
    
    if (status == BookStatusDriverAccepted) {
        if ([self isClientCanceled]) {
            return;
        }
    }
    
    // Tài xế hết thơi gian nhận chuyến -> nếu đã vào chuyến đi thành công || khách đã huỷ -> BỎ QUA
    if (status == BookStatusDriverMissing) {
        if ([self isInTrip] || [self isClientCanceled]) {
            return;
        }
    }
    
    // Nếu khách huỷ trong khi book -> kiểm tra nếu đã vào chuyến rồi -> BỎ QUA
    if (status == BookStatusClientTimeout || status == BookStatusClientCancelInBook) {
        if ([self isTripStarted] || [self isInTrip]) {
            return;
        }
    }
    
    // Nếu khách huỷ trong chuyến đi -> kiểm tra nếu đã bắt đầu rồi hoặc đã kết thúc rồi -> BỎ QUA
    if (status == BookStatusClientCancelIntrip) {
        if ([self isTripStarted] || [self isFinishedTrip]) {
            return;
        }
    }
    
    [self processUpdateStatus:status];
}

- (void) processUpdateStatus: (NSInteger) status {
    
    FCBookCommand* stt = [[FCBookCommand alloc] init];
    stt.status = status;
    NSMutableDictionary* data = [[NSMutableDictionary alloc] initWithDictionary:[stt toDictionary]];
    NSTimeInterval value = [[FireBaseTimeHelper default] currentTime];
    NSDictionary* time = @{@"time": @(value) };
    [data addEntriesFromDictionary:time];
    NSString* key = [NSString stringWithFormat:@"C-%ld", status];
    
    // tracking
    NSString* keyTracking = [NSString stringWithFormat:@"%ld", (long) status];
    CLLocation* lo = [[GoogleMapsHelper shareInstance] currentLocation];
    if (!lo) {
        lo = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    }
    
    FCBookTracking* tracking = [[FCBookTracking alloc] init];
    tracking.command = status;
    tracking.c_localTime = [self getTimeString:[self getCurrentTimeStamp] withFormat:@"yyyyMMdd HH:mm:ss"];
    tracking.c_location = [[FCLocation alloc] initWithLat:lo.coordinate.latitude lon:lo.coordinate.longitude];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[tracking toDictionary]];
    [dict addEntriesFromDictionary:@{@"c_timestamp": @(value)}];
    
    
    // set to firestore
    NSDictionary *dic = @{
                          @"command": @{ key: data },
                          @"last_command": key,
                          @"tracking": @{ keyTracking: dict }
                          };
    [_trackManager setMutipleDataToDatabase:dic update:YES];
    
//    [_trackManager setDataToDatabase:[NSString stringWithFormat:@"command/%@", key] json:data update:YES];
//    [_trackManager setDataToDatabase:@"" json:@{@"last_command": key} update:YES];
}

- (void)updateBookReasonCancel: (NSDictionary*) endReason {
    self.book.info.end_reason_id = [endReason[@"end_reason_id"] integerValue];
    self.book.info.end_reason_value = endReason[@"end_reason_value"];
}

- (void) updateLastestBookingInfo: (FCBooking*) booking {
    NSAssert(_trackManager, @"Check logic");
    NSDictionary *dic = [booking.info toDictionary];
    if (!_trackManager) {
        return;
    }
    [_trackManager setDataToDatabase:kBookInfo json:dic update:YES];
}

/**
 Lấy danh sách status hiện tại đang có trên booking Firebase để kiểm tra cho next status sẽ được ghi
 
 @param currentData : data hiện tại trên firebase booking
 @return List status parsed từ currentData
 */
- (NSArray*) getCurrentListStatus: (FIRMutableData*) currentData {
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (FIRDataSnapshot* data in currentData.children) {
        FCBookCommand* stt = [[FCBookCommand alloc] initWithDictionary:data.value
                                                                 error:nil];
        if (stt) {
            [list addObject:stt];
        }
    }
    
    if (list.count > 1) {
        NSArray* array = [list sortedArrayUsingComparator:^NSComparisonResult(FCBookCommand* obj1,FCBookCommand* obj2) {
            return obj1.status > obj2.status;
        }];
        
        return array;
    }
    return list;
}


/*
 * Kiểm tra trạng thái "status" đã tồn tại trong list status của booking chưa
 * return:
 *  - YES nếu có
 *  - NO nếu không có
 */
- (BOOL) existStatus: (FCBookCommand*) status {
    if (self.book.command.count > 0) {
        for (FCBookCommand* s in self.book.command) {
            if (s.status == status.status) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Book Tracking

- (void) trackingBookInfo: (FCBookCommand*) forStatus {
    @try {
        /*
         This function call from
         - (void) listenerBookingStatusChange: (void (^) (FCBookCommand* status)) handler
          ==> only track for status driver
         status client will track together update command function (- (void) processUpdateStatus: (NSInteger) status {)
         */
        if ([forStatus isClientStatus]) {
            return;
        }
        
        NSString* status = [NSString stringWithFormat:@"%ld", (long) forStatus.status];
        CLLocation* lo = [[GoogleMapsHelper shareInstance] currentLocation];
        if (!lo) {
            lo = [[CLLocation alloc] initWithLatitude:0 longitude:0];
        }
        
        FCBookTracking* tracking = [[FCBookTracking alloc] init];
        tracking.command = forStatus.status;
        tracking.c_localTime = [self getTimeString:[self getCurrentTimeStamp] withFormat:@"yyyyMMdd HH:mm:ss"];
        tracking.c_location = [[FCLocation alloc] initWithLat:lo.coordinate.latitude lon:lo.coordinate.longitude];
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[tracking toDictionary]];
        NSTimeInterval value = [[FireBaseTimeHelper default] currentTime];
        [dict addEntriesFromDictionary:@{@"c_timestamp": @(value)}];
        [_trackManager setDataToDatabase:[NSString stringWithFormat:@"tracking/%@", status] json:dict update:YES];
        
        if (forStatus.status == BookStatusClientTimeout ||
            forStatus.status == BookStatusDriverDontEnoughMoney ||
            forStatus.status == BookStatusDriverBusyInAnotherTrip) {
            return;
        }
    }
    @catch (NSException* e) {
    }
    @finally {}
}

- (NSString *)getPolyline {
    FCBookCommand* currCmd = [self getLastBookStatus];
    if (currCmd) {
        if (currCmd.status == BookStatusDriverAccepted ||
            currCmd.status == BookStatusClientAgreed) {
            return self.book.extra.polylineReceive;
        } else if (currCmd.status == BookStatusStarted ||
                   currCmd.status == BookStatusDeliveryReceivePackageSuccess) {
            return self.book.extra.polylineIntrip;
        }
    }
    return  @"";
}

- (BOOL)isDelivery {
    if (!self.book) {
        return NO;
    }
    return self.book.info.serviceId == VatoServiceDelivery;
}

- (BOOL)isTaxi {
    if (!self.book) {
        return NO;
    }
    return (self.book.info.serviceId == VatoServiceTaxi
            || self.book.info.serviceId == VatoServiceTaxi7);
}

- (NSString *)getStatusStr {
    if ([self isContactDriver]) {
        NSString *msg = localizedFor(@"Đang liên hệ với lái xe");
        return msg;
    } else if ([self isTripStarted]) {
        NSString *msg = localizedFor(@"Đang trong chuyến đi");
        if ([self isDelivery]) {
            msg = localizedFor(@"Đang trên đường giao hàng");
        }
        return msg;
    } else if ([self isInTrip]) {
        if ([self isDelivery]) {
            return localizedFor(@"Lái xe đang đến lấy hàng");
        } else {
            return localizedFor(@"Tài xế đang đến đón");
        }
    } else if ([self isTripCompleted]) {
        return localizedFor(@"Hoá đơn thanh toán");
    }
    return @"";
}

- (NSString *)getSubStatusStr {
    if ([self isContactDriver]) {
        return @"";
    } else if ([self isTripStarted]) {
        NSString *msg = localizedFor(@"Đang trong chuyến đi");
        if (self.book.info.endLat != 0 && self.book.info.endLon != 0) {
            if (self.book.info.duration > 0) {
                double curr = [self getCurrentTimeStamp];
                double targetTime = self.book.info.duration*1000 + curr;
                NSString* timeStr = [self getTimeString:targetTime
                                             withFormat:@"HH:mm"];
                msg = [NSString stringWithFormat:localizedFor(@"Dự kiến %@ sẽ đến nơi"), timeStr];
                if ([self isDelivery]) {
                    msg = localizedFor(@"Đang trên đường giao hàng");
                }
            }
        }
        return msg;
    } else if ([self isInTrip]) {
        if ([self isDelivery]) {
            return localizedFor(@"Lái xe đang đến lấy hàng");
        } else {
            NSString *msg = localizedFor(@"Tài xế đang đến đón");
            FCBookEstimate* estimate = self.book.estimate;
            if (estimate.receiveDuration) {
                NSInteger mins = MAX(estimate.receiveDuration/60, 1);
                msg = [NSString stringWithFormat:localizedFor(@"Đang đến đón: %ld Phút"), (long)mins];
            }
            return msg;
        }
    } else if ([self isTripCompleted]) {
        return localizedFor(@"Hoá đơn thanh toán");
    }
    return @"";
}

@end
