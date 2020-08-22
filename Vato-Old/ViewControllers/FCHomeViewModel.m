//
//  FCHomeViewModel.m
//  FaceCar
//
//  Created by vudang on 5/24/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCSearchDriverModel.h"
#import "FCBookViewModel.h"
#import "FCFareModifier.h"
#import "FCHomeViewModel.h"
#import "FirebaseHelper.h"
#import "AppDelegate.h"
#import "APIHelper.h"
#import "FacecarNavigationViewController.h"
#import "FCNotifyViewController.h"
#import "FCInvoiceManagerViewController.h"
#import "FCWebViewModel.h"
#import "FCWebViewController.h"
#import "FCGiftDetailViewController.h"
#import "FCPromotionDialogView.h"
#import "FCGiftDetailViewController.h"
#import "FCGiftViewModel.h"
#import "ProfileViewController.h"
#import "FCWalletViewController.h"
#import "FCGift.h"
#import "APICall.h"
#import "FCHomeViewController.h"
#import "FCChoosePlaceView.h"
#import "FCGiftViewController.h"
#import "FCBookingRequestViewController.h"
#import "FCConfirmBookViewController.h"
#import "FCMainHomeView.h"
#import "FCHomeViewController.h"
#import "UserDataHelper.h"
#import "FCWarningNofifycationView.h"
#import "FCPopupListView.h"
#import "FCShipConfirmViewController.h"
#import "FCWarningNofifycationView.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "FCBookingService.h"
#import "FCFareService.h"
#import "FCPaymentOptionViewController.h"
#import "FCMCarType.h"
#import "AppDelegate+ForceUpdate.h"

#define kClientID @""
#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

@interface AppDelegate(Login)
@property (nonatomic, strong) LoggedOutWrapper *wrapper;
@end

@interface FCHomeViewModel ()
@end

__weak static FCHomeViewModel* instace;

@implementation FCHomeViewModel {
    AppDelegate* appdelegate;
    FCPromotionDialogView* _promoDialogView;
    FCGiftViewModel* giftViewModel;
    BOOL hadCheckingPromotionEvent;
    FCMainHomeView* _mainBookView;
    FCWarningNofifycationView* _blockView;
    FCWarningNofifycationView* _locationSerivceNotifyView;
    FCPartner* _currentPartnerSelected;
    FCWarningNofifycationView* _maintenaceView;
    FCBookingRequestViewController* _requestBookingView;
    
    
    NSMutableDictionary* _listDriverOnlineCache;
    NSTimer* _timerDelaySearchDriver;
    FCSearchDriverModel* _currentSearchData;
    void (^_searchDriverOnlineCallback)(NSMutableArray*);
    UIAlertController* _alertSignout;
}

+ (FCHomeViewModel*) getInstace {
    return instace;
}

- (instancetype) initViewModle:(UIViewController *)vc {
    self = [super init];
    if (self) {
        instace = self;
        
        self.viewController = vc;
        _listDriverOnlineCache = [[NSMutableDictionary alloc] init];
        [self initBookViewModel];
        
//        appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        [appdelegate checkUpdateVersion];
        
        [self addClientInfoChangedListener];
        
        [self checkInviteDynamicLink];
        
        [self getTotalUnreadNotification];
        
        [self checkingPushNotification];
        
        [self checkSystemMaintance];
        
        [self checkAvatar];
        
        [[FirebaseHelper shareInstance] updatePlatfom];
//        [[FirebaseHelper shareInstance] updateDeviceToken:[FIRInstanceID instanceID].token];
    }
    
    return self;
}

- (void) initBookViewModel {
    self.bookViewModel = [[FCBookViewModel alloc] init];
    self.bookViewModel.viewController = self.viewController;
    [self bindingData];
}

- (void) bindingData {
    @weakify(self);
    [RACObserve(self.bookViewModel, start) subscribeNext:^(FCPlace* x) {
        @strongify(self);
        if (x) {
            [self checkingStartChanged:x];
        }
    }];
    
    __block RACDisposable* handler = [RACObserve(self.bookViewModel, serviceSelected) subscribeNext:^(FCMCarType* x) {
        @strongify(self);
        if (x) {
            [self checkingServiceSelected:x];
            [handler dispose];
        }
    }];
    
    [RACObserve(self.bookViewModel, favDriver) subscribeNext:^(id x) {
        @strongify(self);
        if (x) {
            FCSearchDriverModel* searchModel = [self getSearchModel];
            [self getListDriverOnline:searchModel
                                force:TRUE
                                block:nil];
        }
    }];
}

- (void) checkAvatar {
    AppLog([FIRAuth auth].currentUser.uid)

    @try {
        if (self.client.user.avatarUrl.length == 0) {
            if ([FIRAuth auth].currentUser.photoURL.absoluteString.length > 0) {
                [[FirebaseHelper shareInstance] updateUserAvatar:[FIRAuth auth].currentUser.photoURL];
            } else {
                AppLogCurrentUser()
            }
        }
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

- (void) checkingStartChanged: (FCPlace*) start {
    if (_lastestStart && _lastestStart.location.lat > 0 && _lastestStart.location.lon > 0) {
        CLLocation* last = [[CLLocation alloc] initWithLatitude:_lastestStart.location.lat
                                                      longitude:_lastestStart.location.lon];
        CLLocation* now = [[CLLocation alloc] initWithLatitude:start.location.lat
                                                     longitude:start.location.lon];
        if ([now distanceFromLocation:last] < 250) {
            return;
        }
    }
    
    _lastestStart = start;
    
    // get footer service
    [self getVivuProduct];
    
    // get driver online
    FCSearchDriverModel* searchModel = [self getSearchModel];
    [self getListDriverOnline:searchModel
                        force:NO
                        block:nil];
    
    // get promotion
    [self getListPromotion:nil];
}

- (void) checkingServiceSelected: (FCMCarType*) serice {
    FCSearchDriverModel* searchModel = [self getSearchModel];
    if (serice.id != 1 && serice.id != 2 && serice.id != 3) { // neu ko phai chon dong car thi bo qua gia tri hang xe khi search
        searchModel.partners = nil;
    }
    else if (_currentPartnerSelected){
        searchModel.partners = @[@(_currentPartnerSelected.id)];
    }
    
    [self getListDriverOnline:searchModel
                        force:NO
                        block:nil];
}

- (void) addClientInfoChangedListener {//driver info
    return;
    // check in app delegate
    __weak FCHomeViewModel* weakSelf = self;
    [[FirebaseHelper shareInstance] addClientInfoChangedListener:^(FIRDataSnapshot * snapshot) {
        FCHomeViewModel *strongSelf = weakSelf;
        FCClient *client = [[FCClient alloc] initWithDictionary:snapshot.value error:nil];
        if (client != nil) {
            if ([strongSelf checkWantToSigOut:client] == false) {
                [strongSelf checkAccountActivated:[client.active boolValue]];
            }
        }
    }];
    
    [[FirebaseHelper shareInstance] getClient:^(FCClient* client) {
        self.client = client;
        self.bookViewModel.client = client;
    }];
}

- (void) checkInviteDynamicLink {
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // get invite code
    NSString* codeInvite = [delegate getInviteCode:delegate.inviteUrl];
    
    // goto verify view
    if (codeInvite.length > 0) {
    }
}

- (void) getTotalUnreadNotification {
    long long to = (long long)[self getCurrentTimeStamp];
    long long from = (long long) (to - limitdays);
    NSDictionary* body = @{@"from":@(from),
                           @"to" : @(to),
                           @"page":@(0),
                           @"size":@(10)};
    @weakify(self);
    [[APIHelper shareInstance] get:API_GET_LIST_NOTIFY
                               params:body
                           complete:^(FCResponse *response, NSError *error) {
                               @try {
                                   NSInteger totalUnread = 0;
                                   if (response.data) {
                                       NSArray* array = [response.data objectForKey:@"notifications"];
                                       long long lastNotify = [[UserDataHelper shareInstance] getLastestNotification];
                                       if (lastNotify == 0) {
                                           totalUnread = array.count;
                                       }
                                       else {
                                           for (NSDictionary* dict in array) {
                                               long long time = [[dict objectForKey:@"createdAt"] longLongValue];
                                               if (time > lastNotify) {
                                                   totalUnread ++;
                                               }
                                           }
                                       }
                                       @strongify(self);
                                       [self setNotifyBadge:totalUnread];
                                   }
                               }
                               @catch (NSException* e) {
                                   DLog(@"Error: %@", e)
                               }
                               
                           }];
}

- (void) setNotifyBadge: (NSInteger) badge {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    self.totalUnreadNotify = badge;
}

- (void) listenerBookingResult {
    @weakify(self);
    __block RACDisposable* block = [RACObserve(self.bookViewModel, bookResult) subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == FCBookingResultCodeRetryBook) {
            self.bookViewModel.bookResult = FCBookingResultCodeReset;
            [block dispose];
            
            [self loadBookingRequestView:nil];
        }
        else if ([x integerValue] == FCBookingResultCodeCompleted) {
            self.bookViewModel.bookResult = FCBookingResultCodeReset;
            [block dispose];
            
            [self dismissMainBookView];
        }
    }];
}

// block or actived
- (void) checkAccountActivated: (BOOL) active {
    // was checked lock account in app deleage
    return;
    if (!active) {
        @weakify(self);
        FCWarningNofifycationView* blockView = [[FCWarningNofifycationView alloc] initView];
        [blockView show:((UIViewController*) self.viewController).view
                  image:[UIImage imageNamed:@"block"]
                  title:@"Tài khoản của bạn tạm thời bị khoá"
                message:@"Để biết thêm chi tiết hoặc để được hỗ trợ bạn vui lòng liên hệ ban quản trị"
               buttonOK:@"Liên hệ ban quản trị"
           buttonCancel:nil
               callback:^(NSInteger buttonIndex) {
                   @strongify(self);
                   if (buttonIndex == FCFCWarningActionOK) {
                       [self callPhone:PHONE_CENTER];
                   }
               }];
        
        _blockView = blockView;
    }
    else if (_blockView) {
        [_blockView hide];
        _blockView = nil;
    }
}
    
// check expire tocken
    
- (BOOL) checkWantToSigOut: (FCClient*) client {
    if (!_alertSignout
        && (client.deviceInfo == nil
            || (client.deviceInfo.id.length > 0 && [self getDeviceId].length > 0 && ![client.deviceInfo.id isEqualToString:[self getDeviceId]]))) {
            _alertSignout = [UIAlertController showAlertInViewController:self.viewController
                                                               withTitle:@"Thông báo"
                                                                 message:@"Tài khoản của bạn đã được đăng nhập bởi một thiết bị khác."
                                                       cancelButtonTitle:@"Đóng"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil
                                                                tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                                    _alertSignout = nil;
                                                                    [self logout];
                                                                }];
            return true;
        }
    return false;
}

- (void) logout {
    [[APICall shareInstance] apiSigOut];
    [[TicketLocalStore shared] resetDataLocalTicket];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    // fb
    [[FBSDKLoginManager new] logOut];

    [[GIDSignIn sharedInstance] signOut];
    
    NSError* err;
    [[FIRAuth auth] signOut:&err];
    
    AppLog(@"User had been logged out.")
    if (err) {
        AppError(err)
    }
    
    [[UserDataHelper shareInstance] clearUserData];
    // load login
    
    AppDelegate *delegate = (AppDelegate *) UIApplication.sharedApplication.delegate;
    LoggedOutWrapper *wrapper = delegate.wrapper;
    UIViewController* startview = [wrapper presentLoggedOut];
    UIViewController *rootVC = delegate.window.rootViewController;
    void(^moveToLogin)(void) = ^{
        [UIView transitionFromView:delegate.window.rootViewController.view toView:startview.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            if (finished) {
                delegate.window.rootViewController = startview;
            }
        }];
    };
    UIViewController *presentVC = [rootVC presentedViewController];
    if (presentVC) {
        [presentVC dismissViewControllerAnimated:NO completion:moveToLogin];
    } else {
        moveToLogin();
    }
}
    
- (void) checkSystemMaintance {
    @weakify(self);
    [[FirebaseHelper shareInstance] getAppConfigure:^(FCAppConfigure * _Nullable appconfigure) {
        @strongify(self);
        if (appconfigure.maintenance.active) {
            _maintenaceView = [[FCWarningNofifycationView alloc] init];
            _maintenaceView.bgColor = [UIColor whiteColor];
            _maintenaceView.messColor = [UIColor darkGrayColor];
            [_maintenaceView show:self.viewController.view
                            image:[UIImage imageNamed:@"maintenance"]
                            title:@"Thông báo"
                          message:appconfigure.maintenance.message
                         buttonOK:nil
                     buttonCancel:nil
                         callback:nil];
            [self.viewController.view addSubview:_maintenaceView];
        }
        else if (_maintenaceView) {
            [_maintenaceView removeFromSuperview];
        }
    }];
}

/*
 - Checking old account that  not login via phone provider
 */
- (void) checkingValidAuth {
    AppLog(@"Checking valid authentication.")

    NSString* email = [FIRAuth auth].currentUser.email;
    if ([email isEqualToString:[NSString stringWithFormat:@"%@@vato.vn",PHONE_TEST]]) {
        return;
    }
         
    BOOL valid = NO;
    if ([FIRAuth auth].currentUser) {
        for (id<FIRUserInfo> provider in [FIRAuth auth].currentUser.providerData) {
            if ([provider.providerID isEqualToString:FIRPhoneAuthProviderID]) {
                valid = YES;
                break;
            }
        }
    } else {
        AppLogCurrentUser()
    }
    
    if (!valid) {
        // fb
        [[FBSDKLoginManager new] logOut];
        
        [[GIDSignIn sharedInstance] signOut];

        NSError* err;
        [[FIRAuth auth] signOut:&err];
        AppLog(@"User had been logged out.")
        if (err) {
            AppError(err)
        }


        [[UserDataHelper shareInstance] clearUserData];
        
        // load login
        UIViewController* startview = [[NavigatorHelper shareInstance] getViewControllerById:LOGIN_VIEW_CONTROLLER
                                                                                inStoryboard:STORYBOARD_LOGIN];
        
        [self.viewController presentViewController:startview
                                          animated:YES
                                        completion:nil];
    }
}

#pragma mark - Payment
- (void) checkOverBalance:(void (^)(BOOL)) block {
    NSInteger amountRequire = 30*1000; // 30k default
    FCPlace* endPlace = self.bookViewModel.end;
    FCMCarType* service = self.bookViewModel.serviceSelected;
    if (endPlace) {
        amountRequire = [self.bookViewModel getPriceAfterDiscountForService:service.id];
    }
    
    [[APICall shareInstance] apiGetBalance:^(FCBalance *balance) {
        if (block) {
            self.client.user.cash = balance.cash;
            self.client.user.coin = balance.coin;
            block(balance.cash >= amountRequire);
        }
    }];
}

- (void) updatePaymentMethod:(PaymentMethod)methodSelected {
    self.client.paymentMethod = methodSelected;
    self.bookViewModel.paymentMethod = methodSelected;
    [[FirebaseHelper shareInstance] updatePaymentMethod:methodSelected];
}

#pragma mark - Old Booking
- (void) checkingLastestBooking {
    if ([[UserDataHelper shareInstance] getLastestTripbook]) {
        FCBookingService* service = [FCBookingService shareInstance];
        @try {
            [service getBookingDetail:[[UserDataHelper shareInstance] getLastestTripbook]
                              handler:^(FCBooking * book) {
                                  if (book && [[FCBookingService shareInstance] isInTrip]) {
                                      [self.bookViewModel setBookingData:book];
                                      [self.bookViewModel loadMapsTripView];
                                      
                                      [self listenerBookingResult];
                                  }
                                  else {
                                      // [[UserDataHelper shareInstance] removeLastestTripbook];
                                  }
                              }];
        }
        @catch (NSException* e) {
           // [[UserDataHelper shareInstance] removeLastestTripbook];
        }
    }
}

#pragma mark - Handler layout perform
- (void) loadMainBookView {
    // load main
    if (self.bookViewModel.end) {
        [self showMainBookView];
    }
    else {
        if ([self isCompletedTutorial]) {
            [self loadSearchPlaceView:FCPlaceSearchTypeStart
                               inView:((UIViewController*) self.viewController).view
                                block:^(BOOL cancelView, BOOL completedView) {
                                    if (completedView) {
                                        [self showMainBookView];
                                    }
                                }];
        }
        else {
            FCWarningNofifycationView* confirmView = [[FCWarningNofifycationView alloc] initView];
            [confirmView show:((UIViewController*)self.viewController).view
                        image:[UIImage imageNamed:@"warn-r"]
                        title:@"Gọi xe nhanh không cần điểm đến"
                      message:@"Với tính năng này, cước phí chuyến đi của bạn sẽ được tính theo lộ trình thực tế!"
                     buttonOK:@"Đồng ý"
                 buttonCancel:@"Bỏ qua"
                     callback:^(NSInteger buttonIndex) {
                         if (buttonIndex == FCFCWarningActionOK) {
                             [self loadSearchPlaceView:FCPlaceSearchTypeStart
                                                inView:((UIViewController*) self.viewController).view
                                                 block:^(BOOL cancelView, BOOL completedView) {
                                                     if (completedView) {
                                                         [self showMainBookView];
                                                     }
                                                 }];
                             [self saveTutorialStatus];
                         }
                         
                         [confirmView hide];
                     }];
        }
    }
}

- (void) showMainBookView {
    _mainBookView = [[FCMainHomeView alloc] init];
    _mainBookView.homeViewModel = self;
    _mainBookView.viewController = self.viewController;
    [self.viewController.view addSubview:_mainBookView];
    
    __block RACDisposable* handler = [RACObserve(_mainBookView, hideView) subscribeNext:^(id x) {
        if (x && [x boolValue] == TRUE) {
            [self.bookViewModel clear];
            
            [(FCHomeViewController*) self.viewController clearHome];
            [(FCHomeViewController*) self.viewController forceAnimationReloadMenus];
            
            [handler dispose];
        }
    }];
}

- (void) dismissMainBookView {
    if (_mainBookView) {
        [_mainBookView hide];
    }
}

- (void) loadSearchPlaceView: (NSInteger) type
                      inView: (UIView*) inView
                       block: (void (^) (BOOL cancelView, BOOL completedView)) block {
    FCChoosePlaceView* view = (FCChoosePlaceView*)[[[NSBundle mainBundle] loadNibNamed:@"FCChoosePlaceView" owner:self options:nil] firstObject];
    view.searchType = type;
    [view setHomeViewModel:self];
    [inView addSubview:view];
    
    [RACObserve(view, isFinishedView) subscribeNext:^(id x) {
        if ([x boolValue] == TRUE) {
            block (YES, NO);
        }
    }];
    
    [RACObserve(view, isDone) subscribeNext:^(id x) {
        if ([x boolValue] == TRUE) {
            block (NO, YES);
        }
    }];
}

- (void) loadConfirmBookingView {
    FCConfirmBookViewController* vc = (FCConfirmBookViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"FCConfirmBookViewController" inStoryboard:@"FCConfirmBookViewController"];
    vc.homeViewModel = self;
    [self.viewController presentViewController:vc
                                      animated:TRUE
                                    completion:nil];
}

- (void) loadConfirmShipInfoView {
    FCShipConfirmViewController* vc = (FCShipConfirmViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"FCShipConfirmViewController" inStoryboard:@"FCShipConfirmViewController"];
    vc.homeViewModel = self;
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    [nav setNavigationBarHidden:YES];
    [self.viewController presentViewController:nav
                                      animated:TRUE
                                    completion:nil];
}

- (void) loadBookingRequestView: (void (^) (void)) completed {
    _requestBookingView = [[FCBookingRequestViewController alloc] init];
//    _requestBookingView.homeViewModel = self;
    [self.viewController presentViewController:_requestBookingView
                                      animated:YES
                                    completion:completed];
    
    // get list driver for booking
    FCSearchDriverModel* params = [self getSearchModel];
    params.size = 10;
    [params setRadiusRequest:[self.bookViewModel getBookingRadius]];
    
    [self getListDriverOnline:params
                        force:TRUE
                        block:^(NSMutableArray *list) {
//                            _requestBookingView.listDriverForRequest = list;
                            self.bookViewModel.listDriverForRequest = list;
                        }];
    
    [self listenerBookingResult];
}

- (void) hideRequestBookingView: (void (^) (void)) completed {
    if (_requestBookingView) {
        [_requestBookingView dismissView:^{
            _requestBookingView = nil;
            if (completed)
                completed();
        }];
    }
    else {
        if (completed)
            completed();
    }
}

- (void) loadLocationServiceNotifyView: (BOOL) serviceEnable {
    if (serviceEnable) {
        if (_locationSerivceNotifyView) {
            [_locationSerivceNotifyView hide];
            _locationSerivceNotifyView = nil;
        }
    }
    else if (!_locationSerivceNotifyView) {
        FCWarningNofifycationView* confirmView = [[FCWarningNofifycationView alloc] initView];
        [confirmView show:((UIViewController*)self.viewController).view
                    image:[UIImage imageNamed:@"location-service"]
                    title:@"Kết nối định vị bị gián đoạn"
                  message:@"Cho phép VATO cập nhật vị trí của bạn để có thể tìm chính xác vị trí mà bạn muốn."
                 buttonOK:@"Mở định vị của thiết bị"
             buttonCancel:@"Hoặc tìm kiếm địa chỉ"
                 callback:^(NSInteger buttonIndex) {
                     if (buttonIndex == FCFCWarningActionOK) {
                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                     }
                     else if (buttonIndex == FCFCWarningActionCancel) {
                        [self loadSearchPlaceView:FCPlaceSearchTypeFullWithStartFirst
                                           inView:((UIViewController*) self.viewController).view
                                            block:^(BOOL cancelView, BOOL completedView) {
                                                if (completedView) {
                                                    [self loadMainBookView];
                                                }
                                            }];
                     };
                 }];
        
        _locationSerivceNotifyView = confirmView;
    }
}

- (void) loadPaymentMethodOptionView {
    FCPaymentOptionViewController* vc = (FCPaymentOptionViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"FCPaymentOptionViewController" inStoryboard:@"FCPaymentOptionViewController"];
    
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [self.viewController presentViewController:navController
                                      animated:TRUE
                                    completion:nil];
}

#pragma mark - Get Driver Handler
- (FCSearchDriverModel*) getSearchModel {
    if (!self.currentSearchData)
        self.currentSearchData = [[FCSearchDriverModel alloc] init];
    
    self.currentSearchData.lat = self.bookViewModel.start.location.lat;
    self.currentSearchData.lon = self.bookViewModel.start.location.lon;
    self.currentSearchData.service = self.bookViewModel.serviceSelected.id;
    self.currentSearchData.isFavorite = self.bookViewModel.favDriver;
    
    return self.currentSearchData;
}

- (void) getListDriverOnline: (FCSearchDriverModel*) searchModel
                       force: (BOOL) force
                       block: (void (^)(NSMutableArray* list)) block {
    
    if (searchModel.lon == 0 || searchModel.service == 0) {
        return;
    }
    
    DLog(@"getListDriverOnline: %@", [searchModel toJSONString])
    _currentSearchData = searchModel;
    _searchDriverOnlineCallback = block;
    self.listDriverOnline = nil; // clear
    
    // cancel current request to backend if exist
    [[APIHelper shareInstance] cancelCurrentRequest];
    if (_timerDelaySearchDriver) {
        [_timerDelaySearchDriver invalidate];
    }
    
    // get from cache first
    if (!force) {
        NSMutableArray* arr = [self getListDriverOnlineFromCache:searchModel];
        if (arr.count > 0) {
            if (block) {
                block(arr);
            }
            self.listDriverOnline = arr;
            return;
        }
        
        _timerDelaySearchDriver = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                   target:self
                                                                 selector:@selector(onSearchDriverOnline)
                                                                 userInfo:nil
                                                                  repeats:NO];
    }
    else {
        if (_timerDelaySearchDriver) {
            [_timerDelaySearchDriver invalidate];
        }
        
        [self onSearchDriverOnline];
    }
}

- (void) onSearchDriverOnline {
    _timerDelaySearchDriver = nil;
    [[APICall shareInstance] apiSearchDriver:[_currentSearchData toDictionary]
                             completeHandler:^(NSMutableArray * listDriver) {
                                 if (_searchDriverOnlineCallback) {
                                     _searchDriverOnlineCallback(listDriver);
                                 }
                                 
                                 self.listDriverOnline = listDriver;
                                 [self cacheListDriverOnline:listDriver
                                                      forKey:_currentSearchData];
                             }];
}

- (NSMutableArray*) getListDriverOnlineFromCache: (FCSearchDriverModel*) searchModel {
    if (_listDriverOnlineCache.count > 0) {
        CLLocation* atLocation = [[CLLocation alloc] initWithLatitude:searchModel.lat
                                                            longitude:searchModel.lon];
        for (NSString* key in _listDriverOnlineCache.allKeys) {
            @try {
                NSArray* params = [key componentsSeparatedByString:@"-"];
                NSInteger service = [[params objectAtIndex:0] integerValue];
                long long time = [[params objectAtIndex:3] longLongValue];
                long detalTime = [self getCurrentTimeStamp] - time;
                if (service == searchModel.service && detalTime < 15*60*1000) {
                    double lat = [[params objectAtIndex:1] doubleValue];
                    double lon = [[params objectAtIndex:2] doubleValue];
                    CLLocation* cacheLocation = [[CLLocation alloc] initWithLatitude:lat
                                                                           longitude:lon];
                    long distance = [atLocation distanceFromLocation:cacheLocation];
                    if (distance < 1000) {
                        return [_listDriverOnlineCache valueForKey:key];
                    }
                    
                    [_listDriverOnlineCache removeObjectForKey:key]; // clear
                    return nil;
                }
            }
            @catch (NSException* e) {
                DLog(@"Error: %@", e)
            }
        }
    }
    return nil;
    
}

- (void) cacheListDriverOnline: (NSMutableArray*) list
                        forKey: (FCSearchDriverModel*) searchModel {
    if (list.count > 0) {
        NSString* key = [NSString stringWithFormat:@"%ld-%f-%f-%lld",
                         searchModel.service,
                         searchModel.lat,
                         searchModel.lon,
                         (long long)[self getCurrentTimeStamp]];
        [_listDriverOnlineCache setObject:list forKey:key];
    }
}

#pragma mark - Service on Footer
- (void) getVivuProduct {
    CLLocation* atLocation = [[CLLocation alloc] initWithLatitude:self.bookViewModel.start.location.lat
                                                        longitude:self.bookViewModel.start.location.lon];
    [[FirebaseHelper shareInstance] getServices:atLocation
                                        handler:^(NSMutableArray * listProduct) {
                                            self.listProduct = listProduct;
                                            [self.bookViewModel findDefaultService:listProduct];
                                        }];
    
    [[FirebaseHelper shareInstance] getPartners:atLocation
                                        handler:^(NSMutableArray * lst) {
                                            self.listPartner = lst;
                                        }];
}

#pragma mark - Push Handlers
- (void) checkingPushNotification {
    if (appdelegate.pushData) {
        [self onReceivePush:appdelegate.pushData shouldShowBanner:YES];
    }
    
    
    [RACObserve(appdelegate, pushData) subscribeNext:^(NSDictionary* dict) {
        if (dict) {
            [self onReceivePush:dict shouldShowBanner:NO];
        }
    }];
}

- (void) onReceivePush: (NSDictionary*) dict shouldShowBanner: (BOOL) showBanner {
    NSString* debug = @"0";
    
    @try {
        if (dict) {
            debug = [debug stringByAppendingString:@" >> 1"];
            NSInteger type = [[dict valueForKey:@"type"] integerValue];
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateActive) {
                NSString* body = [[[dict valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"body"];
                [[FCNotifyBannerView banner] show:nil
                                          forType:FCNotifyBannerTypeSuccess
                                         autoHide:YES
                                          message:body
                                       closeClick:nil
                                      bannerClick:nil];
            }
            else {
                UIViewController* vc = nil;
                if (type == NotifyTypeDefault) {
                    vc = [[FCNotifyViewController alloc] initView];
                }
                else if (type == NotifyTypeReferal) {
                    vc = [[FCInvoiceManagerViewController alloc] initViewForPresent];
                }
                else if (type == NotifyTypeLink) {
                    NSString* link = [dict valueForKey:@"url"];
                    if (link.length > 0) {
                        FCWebViewModel* model = [[FCWebViewModel alloc] initWithUrl:link];
                        vc = [[FCWebViewController alloc] initViewWithViewModel:model];
                    }
                }
                else if (type == NotifyTypePrmotion) {
                    debug = [debug stringByAppendingString:@" >> 2"];
                    NSInteger eventId = [[dict valueForKey:@"refer_id"] integerValue];
                    vc = [[FCGiftDetailViewController alloc] initView];
                    ((FCGiftDetailViewController*) vc).eventId = eventId;
                    ((FCGiftDetailViewController*) vc).homeViewModel = self;
                }
                else if (type == NotifyTypeBalance) {
                    vc = [[NavigatorHelper shareInstance] getViewControllerById:@"ProfileViewController"
                                                                   inStoryboard:STORYBOARD_PROFILE];
                    [(ProfileViewController*) vc setHomeViewmodel:self];
                }
                else if (type == NotifyTypeTranferMoney) {
                    vc = [[FCWalletViewController alloc] initView:self];
                }
                else if (type == NotifyTypeUpdateApp) {
                    id currVC = [appdelegate visibleViewController:self.viewController];
                    if ([currVC isKindOfClass:[FCHomeViewController class]]) {
                    
                    }
                    [appdelegate checkUpdateVersion];
                }
                
                
                if (vc) {
                    debug = [debug stringByAppendingString:@" >> 3"];
                    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
                    UIViewController* rootVC = [appdelegate visibleViewController:appdelegate.window.rootViewController];
                    debug = [debug stringByAppendingString:[NSString stringWithFormat:@" >> root:%@", NSStringFromClass([rootVC class])]];
                    [rootVC  presentViewController:navController
                                                                                                             animated:TRUE
                                                                                                           completion:nil];
                }
            }
        }
        
    } @catch (NSException *exception) {
        debug = [debug stringByAppendingString:[NSString stringWithFormat:@">> %@", exception.description]];
    } @finally {
    }
}

#pragma mark - Promotion Handler
- (void) closePromotionView {
    if (_promoDialogView) {
        [_promoDialogView hide];
        _promoDialogView = nil;
    }
}

- (void) usingPromotionView: (FCGift*) gift {
}

- (void) detailPromotion: (FCFareManifest*) gift {
    FCGiftDetailViewController* detailVC = [[FCGiftDetailViewController alloc] initView];
    detailVC.gift = gift;
    detailVC.homeViewModel = self;
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:detailVC];
    [self.viewController presentViewController:nav
                                      animated:YES
                                    completion:nil];
}

- (void) loadListPromotionView: (BOOL) launcher {
    @try {
        FCPromotionDialogView* vc = [[FCPromotionDialogView alloc] init];
        vc.originPoint = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        vc.homeViewModel = self;
        [vc setSelectDetail:^(FCFareManifest *farePredicate) {
            [self detailPromotion:farePredicate];
        } selectUsing:^(FCFareManifest *farePredicate) {
            
        }];
        
        if (!launcher) {
            [self.viewController.view addSubview:vc];
            [self.viewController.view bringSubviewToFront:vc];
        }
        
        _promoDialogView = vc;
        
        [self getListPromotion:^(NSArray *list) {
            self.countGift = list.count;
            [vc setListGifts:list];
            [vc show];
            
            if (launcher && list.count > 0) {
                [self.viewController.view addSubview:vc];
                [self.viewController.view bringSubviewToFront:vc];
            }
        }];
    }
    @catch (NSException* e) {}
}

- (void) getListPromotion: (void (^) (NSArray*)) block {
    FCBooking* book = [[FCBooking alloc] init];
    book.info = [self.bookViewModel createTempBookInfo];
    [[FCFareService shareInstance] getListFareManifest:book completed:^(NSMutableDictionary * list) {
        self.countGift = list.count;
        if (block) {
            block(list.allValues);
        }
    }];
}

#pragma mark - Taxi Handler
- (void)extracted:(FCPopupListView *)vc {
    ;
}

- (void) loadListTaxiView: (CGPoint) from {
    FCPopupListView* vc = [[FCPopupListView alloc] init];
    vc.originPoint = from;
    vc.homeViewModel = self;
    __block RACDisposable* handler = [RACObserve(self, listPartner) subscribeNext:^(id x) {
        if (x) {
            [vc show];
            [handler dispose];
        }
    }];
    
    __block BOOL fisrt = YES;
    [RACObserve(vc, partnerSelected) subscribeNext:^(FCPartner* x) {
        if (fisrt) {
            fisrt = NO;
            return;
        }
        
        FCSearchDriverModel* searchModel = [self getSearchModel];
        _currentPartnerSelected = x;
        if (x) {
            searchModel.partners = @[@(x.id)];
        }
        else {
            searchModel.partners = nil;
        }
        
        [self getListDriverOnline:searchModel
                            block:nil];
    }];
    
    [self.viewController.view addSubview:vc];
    [self.viewController.view bringSubviewToFront:vc];
}

#pragma mark - Tutorial Cache
- (void) saveTutorialStatus {
    NSInteger res = [[[NSUserDefaults standardUserDefaults] valueForKey:@"finished-tutorial-booking"] integerValue];
    res ++;
    [[NSUserDefaults standardUserDefaults] setObject:@(res)
                                              forKey:@"finished-tutorial-booking"];
}

- (BOOL) isCompletedTutorial {
     NSInteger res = [[[NSUserDefaults standardUserDefaults] valueForKey:@"finished-tutorial-booking"] integerValue];
    return res > 1;
}
@end
