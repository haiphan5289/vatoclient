//
//  TripMapsViewController.m
//  FaceCar
//
//  Created by Vu Dang on 8/21/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "TripMapsViewController.h"
#import "FirebaseHelper.h"
#import "CLLocation+Bearing.h"
#import "UserDataHelper.h"
#import "FCMapViewModel.h"
#import "FCTripInfoView.h"
#import <FCChatHeads/FCChatHeads.h>
#import "FCChatView.h"
#import "FCBookingService.h"
#import "AppDelegate.h"
#import "FCBooking.h"
#import "FCTripViewModel.h"
#import "FCBookViewModel.h"
#import "TripTrackingManager.h"
#import "TripMapsViewController+PrefetchDataApi.h"

#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

@interface TripMapsViewController () <GMSMapViewDelegate, FCChatHeadsControllerDatasource, FCChatHeadsControllerDelegate, FCTripInfoViewDelegate>

@property (strong, nonatomic) IBOutlet FCGGMapView *mapView;
@property (weak, nonatomic) IBOutlet FCView *bgInfoView;
@property (weak, nonatomic) IBOutlet FCButton *btnLocation;
@property (strong, nonatomic) TripTrackingManager *trackManager;

@property (strong, nonatomic) FCMapViewModel* mapViewModel;
@property (strong, nonatomic) GMSMarker* driverMarker;
@property (strong, nonatomic) GMSMarker* receiveMarker;
@property (strong, nonatomic) UIViewController* alertCancelView;
@property (strong, nonatomic) FCTripViewModel* viewModel;
@property (strong, nonatomic) FCBookingService* bookingService;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UIView *viewVersion;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintButtonCurrentLocation;

@end

@implementation TripMapsViewController {
    BOOL finishedTrip;
    BOOL sentNotifyToCustomer;
    FCTripInfoView* _infoView;
    FCChatView* _chatView;
    FCChatViewModel* _chatViewModel;
    CGFloat _originInfoViewY;
    NSInteger _minDistanceUpdate; // minimum distance for driver marker update on maps
    RACDisposable* _driverMarkerHandler;
    NSTimer* vibrateTimer;
    NSInteger vibrateCount;
    FCMapMarker* marker;
    
    BOOL isShowPopup;
}

- (instancetype) init {
    id vc = [self initWithNibName:@"TripMapsViewController" bundle:nil];
    return vc;
}
- (instancetype) initViewController:(FCTripViewModel *)viewModel {
    id vc = [self initWithNibName:@"TripMapsViewController" bundle:nil];
    self.viewModel = viewModel;
    return vc;
}

- (BOOL) isDeliveryMode {
    if (!self.book) {
        return NO;
    }
    return self.book.info.serviceId == VatoServiceDelivery;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self listenChangeMethod];
    self.bookingService = [FCBookingService shareInstance];
    if (self.bookSnapshot) {
        self.book = [[FCBooking alloc] initWithDictionary:self.bookSnapshot
                                                    error:nil];
        self.bookingService.book = self.book;
        self.viewModel = [[FCTripViewModel alloc] initViewModel:self.book
                                                        cartype:self.book.info.serviceId
                                                    fromManager:NO];
    }
    
    self.mapViewModel = [[FCMapViewModel alloc] init:self.mapView];
    self.mapViewModel.bookingService = self.bookingService;
    [self.mapView moveCameraToCurrentLocation];
    
    self.btnLocation.backgroundColor = [UIColor whiteColor];
    
    [self.mapView setPadding:UIEdgeInsetsMake(0, 0, kFooterHeight, 0)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppEnterBackground)
                                                 name:NOTIFICATION_ENTER_BACKGROUND
                                               object:nil];
    
    FCClient *client = [[UserDataHelper shareInstance] getCurrentUser];
    NSString *tripId = _bookingService.book.info.tripId.length > 0 ? _bookingService.book.info.tripId : @"";
    [self.lblVersion setText:[NSString stringWithFormat:@"%li | %@ | %@", (long)client.user.id, APP_VERSION_STRING, tripId]];
    
    [self checkingNetwork];
}

- (void)listenChangeMethod {
    AppDelegate *delegate = [AppDelegate castFrom:[UIApplication sharedApplication].delegate];
    if (!delegate) { return; }
    @weakify(self);
    [delegate handlerChangeMethodPayment:^{
        @strongify(self);
        // Show alert
        self.book.info.payment = PaymentMethodCash;
        FCTripInfoView *inforView = self -> _infoView;
        if (inforView) {
            [inforView changeMethodToHardCash];
        }
        [self alertChangeHardCash];
    }];
}

- (void)alertChangeHardCash {
    AlertActionObjC *actionOK = [[AlertActionObjC alloc] initFrom:@"Xác nhận" style:UIAlertActionStyleDefault handler:nil];
    [AlertVC showObjcOn:self title:@"Xác nhận thanh toán tiền mặt" message:@"Số dư tài khoản VATO Pay của bạn không đủ để thực hiện thanh toán chuyến đi. Hãy thanh toán chuyến đi bằng tiền mặt." orderType:UILayoutConstraintAxisHorizontal from:@[actionOK]];
}

- (void)cleanupListenChangeMethod {
    AppDelegate *delegate = [AppDelegate castFrom:[UIApplication sharedApplication].delegate];
    if (!delegate) { return; }
    
    [delegate cleanUpListenChangeMethod];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mapView addLocationButton:self.btnLocation];
    self.mapView.myLocationEnabled = NO;
    
    if (!_infoView) {
        // trip info view
        [self setupInfoView];
        
        // markers
        [self addDriverMarker];
        if ([_bookingService isTripStarted]) {
            [self addMarkerStart];
        }
        
        // load lastest trip status
        FCBookCommand* last = [_bookingService getLastBookStatus];
        [self loadCurrentTripStatus:last.status];
        
        [self initChat];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cleanupListenChangeMethod];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[GoogleMapsHelper shareInstance] stopUpdateLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_ENTER_BACKGROUND object:nil];
}

- (void) onAppEnterBackground {
    [[GoogleMapsHelper shareInstance] startUpdateLocation];
}

- (void) setupInfoView {
    HeaderCornerView *headerCornerView = [[HeaderCornerView alloc] initWith:14];
    headerCornerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kFooterHeight -14, [UIScreen mainScreen].bounds.size.width, kFooterHeight);
    headerCornerView.containerColor = [UIColor whiteColor];
    [self.view addSubview:headerCornerView];
    
    TripShowType tripShowType = TripShowTypeBooking;
    if ([self.bookingService isTaxi]) {
        tripShowType = TripShowTypeTaxi;
    } else if ([self.bookingService isDelivery]) {
        tripShowType = TripShowTypeExpress;
    }
    
    _infoView = [[FCTripInfoView alloc] initTripShowType:tripShowType];
    _infoView.delegate = self;
    [_infoView setMarginTop:0];
//    [_infoView setMarginTop:kInfoMarginTop];
    [_infoView setMarginBottom:kFooterHeight];
    self.constraintButtonCurrentLocation.constant = kFooterHeight + 20;
    [_infoView setSuperView:self.view
              withBackgound:self.bgInfoView];
    _infoView.viewController = self;
    [self.view addSubview:_infoView];

    
    // add view version | User id | trip Id |
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    }
    CGFloat heightViewVersion = 18 + bottomPadding / 2;
    self.viewVersion.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - heightViewVersion, UIScreen.mainScreen.bounds.size.width, heightViewVersion);
    [self.view addSubview:self.viewVersion];
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onInfoClicked:)];
    [_infoView addGestureRecognizer:tap];
    
    [self bindingData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self onInfoClicked:nil];
    });
}

- (void) onBookCanceled {
    // notify
    if ([self.delegate respondsToSelector:@selector(onTripClientCancel)]) {
        [self.delegate onTripClientCancel];
    }
}

- (void) didCompleteTrip {
    if (self.delegate && [_delegate respondsToSelector:@selector(dissmissTripMap)]) {
        [self.delegate dissmissTripMap];
    }
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) dismissView {
   // [[UserDataHelper shareInstance] removeLastestTripbook];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void) popViewWithComplete: (void (^) (void)) complete {
   //  [[UserDataHelper shareInstance] removeLastestTripbook];
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:true completion:nil];
    complete();
}

- (UIImage *)loadMarkerDriverFromTheme:(NSInteger)serviceId {
    NSString *name = [NSString stringWithFormat:@"ic_car_marker_%ld", (long)serviceId];
    return [[ThemeManager instance] loadPDFImageWithName:name];
}

- (void) addDriverMarker {
    // marker driver car
    __block FCLocation* lastLocation = nil;
    [RACObserve(self.viewModel, lastDriverLocation) subscribeNext:^(FCLocation* x) {
        if (x) {
            if (!self.driverMarker) {
                lastLocation = x;
                FCPlace* end = [[FCPlace alloc] init]; // for temp
                end.location = x;
                
                self.driverMarker = [self.mapViewModel addStartMarker:end];
                FCMapMarker* carIconView = (FCMapMarker*)self.driverMarker.iconView;
                [carIconView setMarkerStyle:FCMarkerStyleDefault];
                UIImage *image = [self loadMarkerDriverFromTheme:(long)self.book.info.serviceId];
                if (image == nil) {
                    carIconView.iconMarkerDefaule.image = [UIImage imageNamed:[NSString stringWithFormat:@"m-car-%ld-15", (long)self.book.info.serviceId]];
                } else {
                    carIconView.iconMarkerDefaule.image = image;
                }
            }
            else {
                if (!lastLocation) {
                    lastLocation = x;
                }
                
                NSInteger distance = [self getDistance:[[CLLocation alloc] initWithLatitude:x.lat longitude:x.lon]
                                                fromMe:[[CLLocation alloc] initWithLatitude:lastLocation.lat longitude:lastLocation.lon]];
                // realtime driver marker on maps
                if (_minDistanceUpdate == 0) {
                    _minDistanceUpdate = 100;
                }
                
                if (distance > _minDistanceUpdate) {
                    [self.mapViewModel startMarkerUpdate:[[CLLocation alloc] initWithLatitude:x.lat longitude:x.lon]
                                               forMarker:self.driverMarker];
                    
                    lastLocation = x;
                }
                
                // draw real polyline if digital trip
                if (self.viewModel.booking.info.tripType == BookTypeOneTouch &&
                    [_bookingService isTripStarted]) {
                    [self.mapViewModel updateRealPolyline:[[CLLocation alloc] initWithLatitude:x.lat
                                                                                     longitude:x.lon]
                                                  forTrip:self.viewModel.booking.info];
                }
            }
            
            [self checkDriverGoingto:[[CLLocation alloc] initWithLatitude:x.lat longitude:x.lon]];
        }
    }];
}

/**
 Kiểm tra xem lái xe gần đến điểm đón khách chưa, nếu gần thì báo cho khách hàng
 */
- (void) checkDriverGoingto: (CLLocation*) driverLocation {
    if (sentNotifyToCustomer) {
        return;
    }
    
    FCBookInfo* info = self.viewModel.booking.info;
    CLLocation* clientLocation = [[CLLocation alloc] initWithLatitude:info.startLat longitude:info.startLon];
    double dis = [driverLocation distanceFromLocation:clientLocation];
    if (dis < 100) {
        sentNotifyToCustomer = YES;
        
        vibrateCount = 0;
        vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(vibrateNotifyDriverGoingto) userInfo:nil repeats:YES];
    }
}

- (void) vibrateNotifyDriverGoingto {
    vibrateCount = vibrateCount + 1;
    
    if(vibrateCount <= 5) {
        AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, ^{
            
        });
    }
    else {
        [vibrateTimer invalidate];
    }
}

#pragma mark - Binding Data
- (void) bindingData {
    __block RACDisposable* handler = [RACObserve(self.viewModel, booking) subscribeNext:^(FCBooking* book) {
        if (book) {
            [self loadBookingInfo: book];
            [handler dispose];
        }
    }];
    
    [RACObserve(self.viewModel, cartypeSelected) subscribeNext:^(NSNumber* carType) {
        if (carType) {
            NSString* driverMakerImageName = [NSString stringWithFormat:@"m-car-%ld-15", (long)carType.integerValue];
            self.driverMarker.icon = [UIImage imageNamed:driverMakerImageName];
        }
    }];
    
    [RACObserve(self.viewModel, status) subscribeNext:^(FCBookCommand* status) {
         if (status) {
            [self loadCurrentTripStatus: status.status];
        }
    }];
    
    [RACObserve(self.viewModel, bookIsDeteleted) subscribeNext:^(id x) {
        __weak typeof(self) weakSelf = self;
        if ([x boolValue]) {
            [weakSelf shopPopupTripDelete];
        }
    }];
}

- (void)shopPopupTripDelete {
    if (!isShowPopup) {
        NSString *message = localizedFor(@"Chuyến đi của bạn đã kết thúc. Bạn vui lòng quay lại màn hình chính để tiếp tục chuyến xe mới.");
        if ([self isDeliveryMode]) {
            message = localizedFor(@"Đơn hàng của bạn đã kết thúc. Bạn vui lòng quay lại màn hình chính để tiếp tục chuyến xe mới.");
        }
        [AlertVC showAlertObjcOn:self
                           title:localizedFor(@"Thông báo")
                         message:message
                        actionOk:localizedFor(@"Đồng ý")
                    actionCancel:nil
                      callbackOK:^{
            [self dismissView];
        }
                  callbackCancel:^{
        }];
        
        isShowPopup = NO;
    }
}

- (void) updateTripStatusView: (FCMapMarker*) marker {
    [_infoView updateStatus];
    
    FCBookEstimate* estimate = [FCBookingService shareInstance].book.estimate;
    if (estimate.receiveDuration) {
        NSInteger mins = MAX(self.viewModel.booking.estimate.receiveDuration/60, 1);
        marker.lblStartIntrip.text = [NSString stringWithFormat:@"%ld", (long)mins];
    } else {
        __block RACDisposable* handler = [RACObserve(self.mapViewModel, router) subscribeNext:^(FCRouter* x) {
            if (x) {
                NSInteger mins = MAX(x.duration/60, 1);
                marker.lblStartIntrip.text = [NSString stringWithFormat:@"%ld", (long)mins];
                _infoView.lblRequestConnecting.text = [NSString stringWithFormat:localizedFor(@"Đang đến đón: %ld Phút"), (long)mins];
                [handler dispose];
            }
        }];
    }
}

- (void) driverReceiveVisitor {
    // polyline
    if (_bookingService.book.extra.polylineReceive.length > 0) {
        [self.mapViewModel drawPath:_bookingService.book.extra.polylineReceive];
    }
    else {
        @weakify(self);
        [self.bookingService listenerBookingEstimateNotifyChange:^(FCBookEstimate *estimateChange) {
            if ([self_weak_.bookingService isInToPickup]){
                [self_weak_ updateTripStatusView:marker];
            }
        }];
        
        [self.bookingService listenerBookingExtraNotifyChange:^(FCBookExtra *extra) {
            if ([self_weak_.bookingService isInToPickup]){
                [self_weak_.mapViewModel checkDrawPolyline];
            }
        }];
        
        _driverMarkerHandler = [RACObserve(self.mapViewModel, markerMainDriver) subscribeNext:^(GMSMarker* x) {
            [self.mapViewModel checkDrawPolyline];
        }];
    }
    
    // marker start
    _minDistanceUpdate = 10; //m
    
    marker = [self addMarkerReceive];
    [self updateTripStatusView:marker];
}

- (FCMapMarker*) addMarkerReceive {
    FCPlace* start = [[FCPlace alloc] init];
    start.name = self.book.info.startName;
    start.location = [[FCLocation alloc] initWithLat:self.book.info.startLat
                                                 lon:self.book.info.startLon];
    GMSMarker* startMarker = [self.mapViewModel addEndMarker:start];
    FCMapMarker* startIconView = (FCMapMarker*)startMarker.iconView;
    [startIconView setMarkerStyle:FCMarkerStyleStartInTrip];
    _receiveMarker = startMarker;
    
    return startIconView;
}

- (void) addMarkerStart {
    FCLocation* location = [[FCLocation alloc] initWithLat:self.book.info.startLat
                                                       lon:self.book.info.startLon];
    if (location.lat != 0 && location.lon != 0) {
        [self.mapViewModel addMarker:CLLocationCoordinate2DMake(location.lat, location.lon)
                                icon:[UIImage imageNamed:@"marker-start"]];
        
        if (_bookingService.book.extra.polylineIntrip.length > 0) {
            [self.mapViewModel drawPath:_bookingService.book.extra.polylineIntrip];
        }
        else {
            [self.mapViewModel checkDrawPolyline];
        }
        [_driverMarkerHandler dispose]; // stop marker driver change to draw polyline
    }
}

- (void) tripStart {
    // marker target
    _minDistanceUpdate = 50;
    [self addMarkerStart];
    
    // hide chat
    [self dismissChat];
    
    // hide cancel btn
    [_infoView hideCancelButton];
    
    [_infoView updateStatus];
    
    // marker end
    if (self.book.info.endLat != 0 && self.book.info.endLon != 0) {
        FCPlace* end = [[FCPlace alloc] init];
        end.name = self.book.info.endName;
        end.location = [[FCLocation alloc] initWithLat:self.book.info.endLat
                                                   lon:self.book.info.endLon];
        GMSMarker* startMarker = [self.mapViewModel addEndMarker:end];
        FCMapMarker* startIconView = (FCMapMarker*)startMarker.iconView;
        [startIconView setMarkerStyle:FCMarkerStyleEndInTrip];
        
        // status view
        if (self.viewModel.booking.info.duration > 0) {
            double curr = [self getCurrentTimeStamp];
            double targetTime = self.viewModel.booking.info.duration*1000 + curr;
            NSString* timeStr = [self getTimeString:targetTime
                                         withFormat:@"HH:mm"];
            
            startIconView.lblEndIntrip.text = timeStr;
        }
    }
    else {
        [self.mapViewModel.mapView clearPolyline];
        _receiveMarker.map = nil;
    }
}

- (void) tripCancel {
    if (self.alertCancelView) {
        return;
    }
    
    // hide chat view
    [self dismissChat];
    
    [_infoView hideAnyPopup:^{
        __weak typeof(self) weakSelf = self;
         [weakSelf checkShowPopupCancel];
    }];
}

- (void)checkDissmisViewReason {
    if (self.presentedViewController
        && [self.presentedViewController isKindOfClass:[ReasonCancelVC class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)checkShowPopupCancel {
    __weak typeof(self) weakSelf = self;
    if (self.fromHistory) {
        if ([self isDeliveryMode]) {
            NSString *message = [NSString stringWithFormat:@"%@,\n%@: %@\n%@", localizedFor(@"Đơn hàng của bạn giao thất bại"), localizedFor(@"Lí do"), self.book.info.end_reason_value.length > 0 ? self.book.info.end_reason_value : @"", localizedFor(@"Vui lòng liên hệ với lái xe hoặc bộ phận hỗ trợ của VATO để trợ giúp.")];
            [AlertVC showAlertObjcOn:self
                               title:localizedFor(@"Giao hàng thất bại")
                             message:message
                            actionOk:localizedFor(@"Đồng ý")
                        actionCancel:nil
                          callbackOK:^{
                              [weakSelf dismissView];
                          }
                      callbackCancel:^{
                      }];
            return;
        }
        
        [AlertVC showAlertObjcOn:self
                           title:localizedFor(@"Thông báo")
                         message:localizedFor(@"Chuyến đi của bạn đã bị huỷ. Xin lỗi vì sự bất tiện này.\n\nBạn vui lòng trở về màn hình chính để tiếp tục đặt chuyến xe mới.")
                        actionOk:localizedFor(@"Đồng ý")
                    actionCancel:nil
                      callbackOK:^{
                          [weakSelf dismissView];
                      }
                  callbackCancel:^{
                  }];
    } else if ([self isDeliveryMode]) {
        NSString *message = [NSString stringWithFormat:@"%@,\n%@: %@\n%@", localizedFor(@"Đơn hàng của bạn giao thất bại"), localizedFor(@"Lí do"), self.book.info.end_reason_value.length > 0 ? self.book.info.end_reason_value : @"", localizedFor(@"Vui lòng liên hệ với lái xe hoặc bộ phận hỗ trợ của VATO để trợ giúp.")];
        [AlertVC showAlertObjcOn:self
                           title:localizedFor(@"Giao hàng thất bại")
                         message:message
                        actionOk:localizedFor(@"Đồng ý")
                    actionCancel:nil
                      callbackOK:^{
                          [weakSelf dismissView];
                      }
                  callbackCancel:^{
                  }];
        
    } else {
        [AlertVC showAlertObjcOn:self
                           title:localizedFor(@"Thông báo")
                         message:localizedFor(@"Chuyến đi của bạn đã bị huỷ. Xin lỗi vì sự bất tiện này.\n\nBạn vui lòng trở về màn hình chính để tiếp tục đặt chuyến xe mới.")
                        actionOk:localizedFor(@"Đồng ý")
                    actionCancel:nil
                      callbackOK:^{
                          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CANCEL_BOOKING
                                                                              object:nil];
                          
                          [weakSelf dismissView];
                      }
                  callbackCancel:^{
                  }];
    }
}

- (void) tripFinished {
    if (_infoView.currentType == FCTripInfoViewTypeInvoice) {
        return;
    }
    
    // hide chat view
    [self dismissChat];
    
    [_infoView updateStatus];
    _infoView.currentType = [_infoView loadInvoiceInfo:self.viewModel.booking
                                             bookModel:nil]; // load info data
    
    [self onInfoClicked:nil]; // show view
    _infoView.btnChat.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_TRIP
                                                        object:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(onTripCompleted)]) {
        [_delegate onTripCompleted];
    }
    
    [self showReceiptView];
}

- (void)newTrip {
    if (_delegate && [_delegate respondsToSelector:@selector(newTrip)]) {
        [_bookingService removeBookingListener];
        [_delegate newTrip];
    }
}

- (void) loadBookingInfo : (FCBooking*) book {
    [_infoView setBookData:book];
}

- (void) removeBookingListener {
    [_bookingService removeBookingListener];
}

- (void) loadCurrentTripStatus: (NSInteger) status {
    [self checkDissmisViewReason];
    [_infoView isShowNewTripButton:YES];
    if ([_bookingService isTripCompleted]) {
        [self tripFinished];
        finishedTrip = true;
    }
    else if ([_bookingService isTripStarted]) {
        [self tripStart];
        [_infoView hideAnyPopup: nil];
    }else if ([_bookingService isDeliveryFail]) {
        isShowPopup = YES;
        NSString *message = [NSString stringWithFormat:@"%@,\n%@: %@\n%@", localizedFor(@"Đơn hàng của bạn giao thất bại"), localizedFor(@"Lí do"), self.book.info.end_reason_value.length > 0 ? self.book.info.end_reason_value : @"", localizedFor(@"Vui lòng liên hệ với lái xe hoặc bộ phận hỗ trợ của VATO để trợ giúp.")];
        __weak typeof(self) weakSelf = self;
        [AlertVC showAlertObjcOn:self
                           title:localizedFor(@"Giao hàng thất bại")
                         message:message
                        actionOk:localizedFor(@"Đồng ý")
                    actionCancel:nil
                      callbackOK:^{
                          [weakSelf tripFinished];
                          
//                                                                if ([self.delegate respondsToSelector:@selector(dissmissTripMap)]) {
//                                                                    [self.delegate dissmissTripMap];
//                                                                }
//
//                                                                [self dismissViewControllerAnimated:YES
//                                                                                         completion:nil];
                      }
                  callbackCancel:^{
                  }];

    } else if ([_bookingService isInTrip]) {
        [_infoView isShowNewTripButton:NO];
        [self driverReceiveVisitor];
    }
    else if ([_bookingService isAdminCanceled] || [_bookingService isDriverCanceled]) {
        [_infoView hideAnyPopup:^{
            [self tripCancel];
        }];
        finishedTrip = true;
        
        // notify
        if ([self.delegate respondsToSelector:@selector(onTripFailed)]) {
            [self.delegate onTripFailed];
        }
    } else if ([_bookingService isContactDriver]) {
        [_infoView isShowNewTripButton:NO];
        [_infoView updateStatus];
        [self checkTimoutReceiveFromDriver];
        
    } else {
        [_infoView updateStatus];
    }
}

- (void)showReceiptView {
    ReceiptVC *vc = [[ReceiptVC alloc] initWithNibName:@"ReceiptVC" bundle:nil];
    vc.delegate = self;
    [vc setBookInfoWithBook:self.book];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navi.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:navi animated:true completion:nil];
}

- (void)checkTimoutReceiveFromDriver {
    double time = TIMEOUT_SENDING;
    
    FCAppConfigure* appConfigure = [FirebaseHelper shareInstance].appConfigure;
    if (appConfigure.booking_configure.request_booking_timeout > 0) {
        time = appConfigure.booking_configure.request_booking_timeout;
    }
    
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_bookingService isContactDriver]) {
                @weakify(self);
                [AlertVC showAlertObjcOn:self
                                   title:localizedFor(@"Thông báo")
                                 message:localizedFor(@"Hiện tại các xe đều đang bận. Quý khách vui lòng chọn dịch vụ khác của VATO hoặc thử lại sau ít phút.")
                                actionOk:localizedFor(@"Đồng ý")
                            actionCancel:nil
                              callbackOK:^{
                                  @strongify(self);
                                  [_bookingService updateBookStatus:BookStatusClientTimeout];
                                  [self dismissView];
                              }
                          callbackCancel:^{
                          }];
            }
        });
    });
}

#pragma mark - Action Handler

- (IBAction)closeInfoViewClicked:(id)sender {
    if (![_bookingService isFinishedTrip]) {
        CGRect frame = _infoView.frame;
        frame.origin.y = self.view.bounds.size.height - kFooterHeight;
        [_infoView setTargetFrame:frame];
        [_infoView setTargetAlpha:0.0f];
    }
    else {
        [_infoView showRatingView];
    }
}

- (void) onInfoClicked : (id) sender {
    self.bgInfoView.hidden = NO;
    CGRect frame = _infoView.frame;
//    frame.origin.y = kInfoMarginTop;
    frame.origin.y = 0;
    [_infoView setTargetFrame:frame];
    [_infoView setTargetAlpha:1.0f];
}

#pragma mark - Chats
- (void) initChat {
    _chatViewModel = [[FCChatViewModel alloc] init];
    _chatViewModel.booking = self.viewModel.booking.info;
    [_chatViewModel startChat];
    [self listenerNewChats];
    
    _chatView = [[FCChatView alloc] init];
    _chatView.chatViewModel = _chatViewModel;
    _chatView.ishidden = YES;
    [_chatView bindingData];
    [_infoView showChatBadge:0]; // for hide
}

- (void) showChatView {
    // load driver avatar
    FCImageView* avatarView = [[FCImageView alloc] initWithImage:[UIImage imageNamed:@"avatar-holder"]];
    
//    [[FirebaseHelper shareInstance] getDriver:self.viewModel.booking.info.driverFirebaseId
//                                      handler:^(FCDriver * driver) {
//                                          _chatView.driver = driver;
//                                          [avatarView setImageWithURL:[NSURL URLWithString:driver.user.avatarUrl]
//                                                     placeholderImage:[UIImage imageNamed:@"avatar-holder"]];
//                                      }];
    [ChatHeadsController presentChatHeadWithView:avatarView
                                          chatID:self.viewModel.booking.info.tripId];
    ChatHeadsController.datasource = self;
    ChatHeadsController.delegate = self;
    [ChatHeadsController expandChatHeadsWithActiveChatID:self.viewModel.booking.info.tripId];
    
    [avatarView circleView];
}

- (void) dismissChat {
    [ChatHeadsController collapseChatHeads];
    [ChatHeadsController dismissAllChatHeads:YES];
}

- (void) listenerNewChats {
    [RACObserve(_chatViewModel, chat) subscribeNext:^(FCChat* x) {
        if (x) {
            if (!_chatView || _chatView.ishidden) {
                _chatViewModel.noChats ++;
                [self notifyNewChat:x];
            }
            else {
                _chatViewModel.noChats = 0;
            }
            
            [ChatHeadsController setUnreadCount:_chatViewModel.noChats
                          forChatHeadWithChatID:self.viewModel.booking.info.tripId];
            [_infoView showChatBadge:_chatViewModel.noChats];
        }
    }];
}

- (void) notifyNewChat: (FCChat*) chat {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertTitle:localizedFor(@"Tin nhắn từ lái xe")];
        NSString* body = chat.message;
        [notification setAlertBody:body];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        [notification setSoundName:@"message.wav"];
        
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
    else {
        [self playsound:@"message"
                 ofType:@"wav"
             withVolume:1.0f
                 isLoop:NO];
    }
}

- (UIView*) chatHeadsController:(FCChatHeadsController *)chatHeadsController viewForPopoverForChatHeadWithChatID:(NSString *)chatID {
    return _chatView;
}

- (void) chatHeadsControllerDidDisplayChatView:(FCChatHeadsController *)chatHeadsController {
    if (_chatView) {
        _chatViewModel.noChats = 0;
        [ChatHeadsController setUnreadCount:_chatViewModel.noChats
                      forChatHeadWithChatID:self.viewModel.booking.info.tripId];
        _chatView.ishidden = NO;
        [_infoView showChatBadge:0];
    }
}

- (void) chatHeadsController:(FCChatHeadsController *)chController didDismissPopoverForChatID:(NSString*) chatID {
    if (_chatView) {
        _chatView.ishidden = YES;
        [self dismissChat];
    }
}

- (void) chatHeadsController:(FCChatHeadsController *)chController didRemoveChatHeadWithChatID:(NSString*) chatID {
    if (_chatView) {
        _chatView.ishidden = YES;
    }
}

#pragma mark - ReceiptVCDelegate
-(void) dismissTrip {
    [self didCompleteTrip];
}

@end
