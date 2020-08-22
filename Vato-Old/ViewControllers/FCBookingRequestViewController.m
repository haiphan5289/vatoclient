//
//  FCBookingRequestViewController.m
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCBookingRequestViewController.h"
#import "FCTripViewModel.h"
#import "TripMapsViewController.h"
#import "FCBookingService.h"
#import "FCHomeViewModel.h"
#import "FCTripInfoView.h"
#import "FCDriverSearch.h"
#import "FCSearchDriverModel.h"
#import "APICall.h"
#import "FirebasePushHelper.h"
#import "UserDataHelper.h"
#import "AppDelegate.h"
#import "NSArray+Extension.h"
#import "AFNetworkReachabilityManager.h"

@interface FCBookingRequestViewController () <FCTripInfoViewDelegate, FCTripMapViewControllerDelegate>

@property (weak, nonatomic) IBOutlet FCGGMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet FCImageView *imgDriverAvatar;
@property (weak, nonatomic) IBOutlet FCView *bgInfoView;

@property (strong, nonatomic) FCBookInfo* bookData;
@property (strong, nonatomic) FCBooking* booking;
@property (strong, nonatomic) NSTimer* sendingBookingTimeout;
@property (strong, nonatomic) NSMutableArray* listDriverForRequest;
@property (strong, nonatomic) FCTripInfoView* infoView;
@end

@implementation FCBookingRequestViewController {
    UIViewController* _popup;
    FCBookingService* _bookingService;
    BOOL _isFavoriteDriver;
    BOOL _isNotifiedBookResult;
}

- (id) init {
    self = [self initWithNibName:@"FCBookingRequestViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    _bookingService = [FCBookingService shareInstance];
    _isFavoriteDriver = [[self.bookInfo objectForKey:@"favDriver"] boolValue];
    NSDictionary *json = [self.bookInfo copy];
    self.bookData = [[FCBookInfo alloc] initWithDictionary:json error:nil];
    [self.imgDriverAvatar circleView:ORANGE_COLOR];
    self.mapView.myLocationEnabled = NO;
    
    [self.mapView moveCameraTo:[[CLLocation alloc] initWithLatitude: self.bookData.startLat
                                                          longitude: self.bookData.startLon] zoom:18];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onEnterBackground)
                                                 name:NOTIFICATION_ENTER_BACKGROUND
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCompleteBook)
                                                 name:NOTIFICATION_COMPLETE_BOOKING
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRetryBook)
                                                 name:NOTIFICATION_RETRY_BOOK
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCancelBook)
                                                 name:NOTIFICATION_CANCEL_BOOKING
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppWillTermial)
                                                 name:NOTIFICATION_APP_WILL_TERMINAL
                                               object:nil];
    
    [self findDriver];
    
    [self checkingNetwork];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_infoView) {
        [self initRequestInfoView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAllTimers];
    [_mapView removeFromSuperview];
    if (!_infoView) {
        return;
    }
    NSArray <UIGestureRecognizer *> *gestures = [_infoView gestureRecognizers];
    [gestures forEach:^(UIGestureRecognizer * _Nonnull gesture) {
        [_infoView removeGestureRecognizer:gesture];
    }];
    [_infoView removeFromSuperview];
    self.infoView = nil;
}

- (void) onAppWillTermial {
    DLog(@"RequestBooking -> app will terminal")
    [[FCBookingService shareInstance] updateBookStatus:BookStatusClientCancelInBook];
    [self onBookCanceled];
}

- (void) removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_COMPLETE_BOOKING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RETRY_BOOK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CANCEL_BOOKING object:nil];
}

- (void) checkingNetwork {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        if (status == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_DISCONNECTED
                                                                object:nil];
            
            AppDelegate* appdelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            UIViewController* vc = [appdelegate visibleViewController:appdelegate.window.rootViewController];
            if (![vc isKindOfClass:[AlertVC class]]) {
                AlertActionObjC* actionOk = [[AlertActionObjC alloc] initFrom:@"Đồng ý" style:UIAlertActionStyleDefault handler:^{
                    [self dismissView:^{
                        
                    }];
                }];
                [AlertVC showObjcOn:self title:localizedFor(@"Mất kết nối")
                            message:localizedFor(@"Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra và thử lại.")
                          orderType:UILayoutConstraintAxisHorizontal from:@[actionOk]];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWOTK_CONNECTED
                                                                object:nil];
            
            [[FCNotifyBannerView banner] hide];
        }
    }];
}

- (void) onEnterBackground {
    
}

- (void) onCompleteBook {
    [self.delegate onBookingCompleted];
    @weakify(self);
    [self dismissView:^{
        @strongify(self);
        [self removeNotifications];
    }];
}

- (void) onCancelBook {
    
}

- (void) onRetryBook {
    // reset view load driver current
    _isNotifiedBookResult = NO;
    
    [self loadStatusView:nil];
    
    [self findDriver];
}

- (void) loadStatusView: (FCDriverSearch*) driver {
    if (driver) {
//        [self.lblStatus setText:[NSString stringWithFormat:@"Đang liên hệ với lái xe %@.", driver.name]];
//        [self.imgDriverAvatar setImageWithUrl:driver.avatarUrl];
        [self.lblStatus setText:@"Đang tìm lái xe tốt nhất cho bạn"];
        [self.imgDriverAvatar setImage:[UIImage imageNamed:@"splashscreen_logo_vato"]];
        
        [self showRequestInfoView: driver];
    }
    else {
//        [self.lblStatus setText:@"Đang liên hệ với lái xe ..."];
//        [self.imgDriverAvatar setImageWithUrl:nil];
        [self.lblStatus setText:@"Đang tìm lái xe tốt nhất cho bạn"];
        [self.imgDriverAvatar setImage:[UIImage imageNamed:@"splashscreen_logo_vato"]];
        
        [self showRequestInfoView: nil];
    }
}

- (void) dismissView: (void (^ __nullable)(void))completion {
    [self cancelRequestBooking];
    
    [self.infoView hideAnyPopup:^{
        [self hidePopup:^{
            [self dismissViewControllerAnimated:YES
                                     completion:completion];
        }];
    }];
}

- (void) hidePopup: (void (^) (void)) completed {
    if (_popup) {
        [_popup dismissViewControllerAnimated:YES
                                   completion:^{
                                       completed ();
                                   }];
    }
    else {
        completed ();
    }
}

- (void) notifySuccess {
    [self playsound:@"success"];
}

- (void) notifyFailed : (BOOL) noDriverAccept {
    @weakify(self);
    [self dismissVisialeView:^{
        NSString* message = nil;
        if (noDriverAccept) {
            message = @"Rất tiếc, chưa tìm được xe nào cho bạn. Hãy dùng thử tính năng Chủ động cước phí.";
        }
        else {
            message = @"Hiện tại các xe đều đang bận. Quý khách vui lòng chọn dịch vụ khác của VATO hoặc thử lại sau ít phút.";
        }
        
        [AlertVC showObjcOn:self title:@"Phản hồi đặt xe" message: message callback:^{
            @strongify(self);
            [self dismissView:^{
                
            }];
        }];
    }];
}

- (void) dismissVisialeView:(void (^)(void)) block {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES
                                                         completion:^{
                                                             block();
                                                         }];
    }
    else {
        block();
    }
}

#pragma mark - Info view
- (void) initRequestInfoView {
    _infoView = [[FCTripInfoView alloc] initTripShowType:(TripShowTypeBooking)];
    _infoView.delegate = self;
    [_infoView setMarginTop:kInfoMarginTop];
    [_infoView setMarginBottom:130];
    [_infoView setSuperView:self.view
              withBackgound:self.bgInfoView];
    _infoView.viewController = self;
    [_infoView initForRequestBooking];
    [self.view addSubview:_infoView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onInfoClicked:)];
    [_infoView addGestureRecognizer:tap];
}

- (void) showRequestInfoView: (FCDriverSearch*) driver {
    if (driver) {
        FCBooking* book = self.booking;
        book.info.driverFirebaseId = driver.firebaseId;
        [_infoView loadRequestView: book];
    }
    else {
        [_infoView.imgDriverAvatar setImageWithUrl:nil];
        [_infoView.lblRequestConnecting setText:@"Đang liên hệ với lái xe ..."];
    }
}

- (IBAction)closeInfoViewClicked:(id)sender {
    CGRect frame = _infoView.frame;
    frame.origin.y = self.view.bounds.size.height - 130;
    [_infoView setTargetFrame:frame];
    [_infoView setTargetAlpha:0.0f];
}

- (void) onInfoClicked : (id) sender {
    if (_infoView.bookData) {
        self.bgInfoView.hidden = NO;
        CGRect frame = _infoView.frame;
        frame.origin.y = kInfoMarginTop;
        [_infoView setTargetFrame:frame];
        [_infoView setTargetAlpha:1.0f];
    }
}

- (void) onBookCanceled {
    [[UserDataHelper shareInstance] removeLastestTripbook];
    [self dismissView:^{
        
    }];
}



#pragma mark - Booking Logic
- (void) stopAllTimers {
    [_sendingBookingTimeout invalidate];
}

- (FCSearchDriverModel*) getSearchModel {
    FCSearchDriverModel* result = [[FCSearchDriverModel alloc] init];
    
    result.lat = self.bookData.startLat;
    result.lon = self.bookData.startLon;
    result.service = self.bookData.serviceId;
    result.isFavorite = _isFavoriteDriver;
    result.size = 10;
    
    return result;
}


- (void) findDriver {
    FCSearchDriverModel* params = [self getSearchModel];
    [params setRadiusRequest:[self getBookingRadius]];
    double fare = [self.bookData getBookPrice];
    params.fare = fare > 0 ? fare : 30000;
    [self crateBookingData:self.bookData];
    
    @weakify(self);
    [[APICall shareInstance] apiSearchDriverForBooking:[params toDictionary]
                                       completeHandler:^(NSMutableArray * listDriver) {
                                           @strongify(self);
                                           [self requestBooking:listDriver];
                                       }];
}

- (void) crateBookingData: (FCBookInfo*) info {
    // extra info
    FCBookExtra* extra = [[FCBookExtra alloc] init];
    extra.polylineIntrip = [self.bookInfo objectForKey:@"polyline"];
    
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
        if (radius.zoneId == self.bookData.zoneId) {
            choose = radius;
            break;
        }
    }
    
    if (choose) {
        if (self.bookData.distance < choose.minDistance*1000) {
            result = choose.min;
        }
        else {
            result = choose.min + (self.bookData.distance/1000 - choose.minDistance) * choose.percent/100.0f;
            result = MIN(result, choose.max);
        }
    }
    NSString* res = [NSString stringWithFormat:@"%.02f", result];
    return [res floatValue];
}


- (void) requestBooking:(NSMutableArray *)listDriverForRequest {
    self.listDriverForRequest = listDriverForRequest;
    if (listDriverForRequest.count > 0) {
        [self sendNextBook];
    }
    else {
        DLog(@"requestBooking: dont have any driver")
        [self notifyFailed:NO];
        [self notifyBookingFailed];
    }
}

- (void) cancelRequestBooking {
    // cancel current book timeout
    [self stopAllTimers];
    
    // remove listener
    [_bookingService removeBookingListener];
}

- (void) sendNextBook {
    
    // sent all driver
    if (self.listDriverForRequest.count == 0) {
        DLog(@"requestBooking: no any one accept")
        [self notifyFailed:YES];
        [self notifyBookingFailed];
        return;
    }
    
    // sending next book
    FCDriverSearch* nextDriver = [self.listDriverForRequest firstObject];
    
    // pop first
    [self.listDriverForRequest removeObjectAtIndex:0];
    
    // send next
    self.booking.info.driverFirebaseId = nextDriver.firebaseId;
    self.booking.info.driverUserId = nextDriver.id;
    self.booking.extra.driverCash = nextDriver.cash;
    self.booking.extra.driverCoin = nextDriver.coin;
    self.booking.extra.satisfied = @(nextDriver.satisfied);
    
    // version
    self.booking.info.clientVersion = [NSString stringWithFormat:@"%@I", [self getAppVersion]];
    
    // clear old
    self.booking.command = nil;
    self.booking.tracking = nil;
    self.booking.estimate = nil;
    
    @weakify(self);
    [[FirebaseHelper shareInstance] getDriver:nextDriver.firebaseId handler:^(FCDriver * driver) {
        // driver version
        @strongify(self);
        if ([driver.deviceInfo.model containsString:@"iPhone"] || [driver.deviceInfo.model containsString:@"iPad"]) {
            self.booking.info.driverVersion = [NSString stringWithFormat:@"%@I", driver.currentVersion];
        }
        else {
            self.booking.info.driverVersion = [NSString stringWithFormat:@"%@A", driver.currentVersion];
        }
        
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
    }];
    
    /*
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
     */
}

- (void) onSent: (FCDriverSearch*) driver {
    
    // send push notification
    [self pushBookInfoToDriver];
    
    NSInteger timer = TIMEOUT_SENDING;
    FCAppConfigure* appConfigure = [FirebaseHelper shareInstance].appConfigure;
    if (appConfigure.booking_configure.request_booking_timeout > 0) {
        timer = appConfigure.booking_configure.request_booking_timeout;
    }

    
    // start booking timeout: 30s for each
    self.sendingBookingTimeout = [NSTimer scheduledTimerWithTimeInterval:timer
                                                                  target:self
                                                                selector:@selector(onSendingBookTimeout)
                                                                userInfo:nil
                                                                 repeats:NO];
    
    // cache book to local for checking if quit app when requesting
    [[UserDataHelper shareInstance] saveLastestTripbook: self.booking.info
                                             currentCar: self.booking.info.serviceId];
    
    // show "Đang liên hệ với lái xe ABC.."
    [self loadStatusView:driver];
    
    // listener
    [self listenerBookingChange];
}

- (void) onSendingBookTimeout {
    [_bookingService updateBookStatus:BookStatusClientTimeout];
    [self notifyBookingFailed];
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
    @weakify(self);
    [_bookingService listenerBookingStatusChange:^(FCBookCommand *stt) {
        @strongify(self);
        NSInteger status = stt.status;
        
        if (status == BookStatusDriverAccepted) {
            // stop sending
            [self.sendingBookingTimeout invalidate];
            
            // clear all
            [self.listDriverForRequest removeAllObjects];
            
            // notify agree accept
            [_bookingService updateBookStatus:BookStatusClientAgreed];
            
            [self notifySuccess];
            
            [self loadMapsTripView];
        }
        else if ([_bookingService isAdminCanceled] ||
                 [_bookingService isDriverCanceled]) {
            
            // cancel current timer
            [self.sendingBookingTimeout invalidate];
            
            // send next book
            [self sendNextBook];
            
            [[UserDataHelper shareInstance] removeLastestTripbook];
        }
        else if (status == BookStatusClientTimeout) {
            // send next book
            [self sendNextBook];
            
            [[UserDataHelper shareInstance] removeLastestTripbook];
        }
        else if (status == BookStatusClientCancelInBook) {
            [[UserDataHelper shareInstance] removeLastestTripbook];
            
            [self dismissView:^{
                
            }];
        }
    }];
}


- (void) loadMapsTripView {
    if ([self.presentedViewController isKindOfClass:[AlertVC class]]) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    FCTripViewModel* model = [[FCTripViewModel alloc] initViewModel:self.booking
                                                            cartype:self.booking.info.serviceId
                                                        fromManager:NO];
    
    TripMapsViewController* mapsTrip = [[TripMapsViewController alloc] initViewController:model];
    mapsTrip.book = self.booking;
    mapsTrip.delegate = self;
    [self.navigationController pushViewController:mapsTrip animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_APP_WILL_TERMINAL object:nil];
}

// tripmap delegate
- (void) onTripFailed {
    [self notifyBookingFailed];
}

//
- (void) notifyBookingFailed {
    if (!_isNotifiedBookResult && [self.delegate respondsToSelector:@selector(onBookingFailed)]) {
        _isNotifiedBookResult = TRUE;
        [self.delegate onBookingFailed];
    }
}

- (void)dealloc {
    NSLog(@"Dealloc");
}

@end
