//
//  FCBookViewModel.h
//  FC
//
//  Created by facecar on 4/24/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCBooking.h"
#import "FCHomeViewModel.h"
#import "FCBookNotify.h"

@interface FCBookingService : NSObject
@property (strong, nonatomic) FCBooking* book;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCBookCommand* currentStatus;

+ (FCBookingService*) shareInstance;

- (void) sendingBooking: (FCBooking*) request
               complete: (void (^)(NSError* error, FIRDatabaseReference * ref))block ;
- (void) getBookingDetail: (FCBookInfo*) booking
                  handler: (void (^)(FCBooking*))completed;

#pragma mark - Book Tracking
- (void) trackingBookInfo: (FCBookCommand*) forStatus;

/**
 Listener trạng thái mới được ghi nhận từ cả 2 bên.
 Nếu trạng thái mới nhận chưa tồn tại thì xử lý. Ngược lại thì bỏ qua
 
 @param handler : callback trạng thái mới được add đúng (như mô tả ở trên) để tiếp tục xử lý
 */
- (void) listenerBookingStatusChange: (void (^) (FCBookCommand* status)) handler;
- (void) listenerBookingInfoChange:(void (^)(FCBookInfo*))handler;
- (void) removeBookingListener;
- (void) listenerBookingEstimateNotifyChange:(void (^)(FCBookEstimate*))handler;
- (void) listenerBookingExtraNotifyChange:(void (^)(FCBookExtra*))handler;
- (void) listenerBookDelete: (void (^)(void))handler;
/**
 Hàm lấy trạng thái cuối cùng được add vào list status
 Trang thái cuối cùng là trạng thái có time lớn nhất
 
 @param book: booking cần check status
 @return FCBookStatus nếu tôn tại list status, ngược lại return nil
 */
- (FCBookCommand*) getLastBookStatus;

/*
 * Một booking hợp lệ phải thoả các điều kiện sau:
 * 1. Chưa có trạng thái kết thúc
 * 2. Thời gian tạo của booking (client write) không quá 5mins (tranh trường hợp khách book xong huỷ kết nối với app)
 */
- (BOOL) isBookingAvailable: (FCBooking*) book;


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
- (void) updateBookStatus: (NSInteger) status;
/*
 * Kiểm tra trạng thái "status" đã tồn tại trong list status của booking chưa
 * return:
 *  - YES nếu có
 *  - NO nếu không có
 */

- (void)updateBookReasonCancel: (NSDictionary*) endReason;
/*
 * reason cancel booking: 
 * end_reason_id
 *  end_reason_value
 */

- (void) updateLastestBookingInfo: (FCBooking*) booking;


- (BOOL) existStatus: (FCBookCommand*) status;
- (BOOL) isInTrip;
- (BOOL) isTripStarted;
- (BOOL) isClientCanceled;
- (BOOL) isDriverCanceled;
- (BOOL) isAdminCanceled;
- (BOOL) isFinishedTrip;
- (BOOL) isTripCompleted;
- (NSString *)getPolyline;
- (BOOL) isInToPickup;
- (BOOL) isDeliveryFail;
- (NSString *)getStatusStr;
- (NSString *)getSubStatusStr;
- (BOOL)isTaxi;
- (BOOL)isDelivery;
- (BOOL) isContactDriver;
- (BOOL)isAllowCancelTrip;
- (BOOL)isAllowCancelTrip;
@end
