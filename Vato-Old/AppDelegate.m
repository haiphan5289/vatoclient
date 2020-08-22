//
//  AppDelegate.m
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "AppDelegate.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NavigatorHelper.h"
#import "GoogleMapsHelper.h"
#import "IndicatorUtils.h"
#import "LoginViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "APICall.h"
#import "FCNotifyViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCInvoiceManagerViewController.h"
#import "FCGiftDetailViewController.h"
#import "UserDataHelper.h"
#import <zpdk/zpdk/ZaloPaySDK.h>
#import <Realm/Realm.h>
#import <VatoNetwork/VatoNetwork-Swift.h>
#import <SMSVatoAuthen/SMSVatoAuthen-Swift.h>
#import "FCHomeViewModel.h"
#import "ApplicationDelegateProtocol.h"
#import <FirebaseStorage/FirebaseStorage.h>
#import "AppDelegate+ForceUpdate.h"
#import "AFNetworkReachabilityManager.h"
#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

@import SDWebImage;
@import Crashlytics;
@import Fabric;

NSString * const UserNotificationTap = @"UserNotificationTap";
NSString * const zpTransactionUpdateNotification = @"zpTransactionUpdateNotification";

@import Firebase;
@import FirebaseAuth;

@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate, LoggedOutWrapperDelegate>

@property BOOL isIntrip;
@property (nonatomic, strong) PopupForceUpdateViewController *forePopup;
@property (assign, nonatomic) BOOL needCheckVersion;

@property (strong, nonatomic) RACBehaviorSubject *subjectOutOfMoney;
@property (nonatomic, strong) LoggedOutWrapper *wrapper;
@property (nonatomic, strong) VatoHomeNewRouting *routeHome;
@property (nonatomic, strong) RACDisposable * diposeFetchRequest;
@property (copy, nonatomic, nullable) BlockHandlerTaskDelegate completeTaskHandler;
@end

@implementation AppDelegate {
    NSInteger lastimeOpenApp;

}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//    [AppLogger setupFile];
    [[GoogleMapsHelper shareInstance] startUpdateLocation];

    BOOL debug;
#if DEV
    debug = YES;
    NSString* firPath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info-test" ofType:@"plist"];
    FIROptions* options = [[FIROptions alloc] initWithContentsOfFile:firPath];
    [FIRApp configureWithOptions:options];
    [VatoFoodApiSettingEnvironment setWithEnvironment: VatoFoodEnvironmentDevelopment];
#elif STG
    debug = NO;
    NSString* firPath = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info-stg" ofType:@"plist"];
    FIROptions* options = [[FIROptions alloc] initWithContentsOfFile:firPath];
    [FIRApp configureWithOptions:options];
    [VatoFoodApiSettingEnvironment setWithEnvironment: VatoFoodEnvironmentStaging];
#else
    debug = NO;
    [API logApiWithUse:YES];
    [FIRApp configure];
    [VatoFoodApiSettingEnvironment setWithEnvironment: VatoFoodEnvironmentProduction];
#endif
    if (debug) {
        [[FIRConfiguration sharedInstance] setLoggerLevel: FIRLoggerLevelDebug];
    }
    
    FIRFirestore *db = [FIRFirestore firestore];
    FIRFirestoreSettings *settings = db.settings;
    settings.persistenceEnabled = YES;
    settings.timestampsInSnapshotsEnabled = YES;
    db.settings = settings;
    
    [API configWithUse:debug];
    self.routeHome = [VatoHomeNewRouting new];
    [RealmManager setupConfig];
    SDImageCacheConfig.defaultCacheConfig.diskCacheClass = [ImageVatoDiskCache class];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[[Crashlytics class]]];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    // get push data
    self.pushData = [[UserDataHelper shareInstance] getPushData];
    
    [[ZaloPaySDK sharedInstance] initWithAppId:ZALOPAY_APPID]; // khởi tạo ZPDK

    // init maps
    [FIROptions defaultOptions].deepLinkURLScheme = APP_URL_SCHEME;
    [FIRDatabase database].persistenceEnabled = YES; // local capture
    
    [SMSVatoAuthenInterface configureWithDependency:[FirebaseHelper shareInstance]];
    [ProgressHUDRegister registerLoading];
    // google sign in cofig
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    
    // register notification
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].delegate = self;
#endif
    }
    
    [[VatoManageDeepLink instance] trackLaunchOption:launchOptions];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
    
    [[ShortcutItemManager instance] addShortcutItemWithShortcutItemToProcess:shortcutItem];
    [self connectToFcm];
    
    // checking receive notification

    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *new = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
        new[UserNotificationTap] = @(YES);
        [self onReceivePush: userInfo];
    }

    [[AVAudioSession sharedInstance] setActive:YES
                                         error:nil];

    if (!_wrapper) {
        self.wrapper = [[LoggedOutWrapper alloc] init];
        self.wrapper.delegate = self;
    }

    [self loadSplashView];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

- (BlockHandlerTaskDelegate)getTaskHandler {
    return self.completeTaskHandler;
}

- (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSDate *new = [[NSDate date] dateByAddingTimeInterval:1800];
    self.diposeFetchRequest = [[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh] after:new schedule:^{
        completionHandler(UIBackgroundFetchResultNewData);
    }];


    DLog(@"performFetchWithCompletionHandler ....")
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTER_BACKGROUND
                                                        object:nil];
    
    #if STG
    application.shortcutItems = [[ShortcutItemManager instance] createShortcutManual];
    #endif
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    if (_diposeFetchRequest) {
        [_diposeFetchRequest dispose];
    }
    [center removeAllDeliveredNotifications];
    [center removeAllPendingNotificationRequests];
    
    [self checkingLastestBooking];
    [self checkLockAccount];
//    [FBSDKAppEvents activateApp];
    
    [[APICall shareInstance] checkingNetwork];

//    [self checkUserAvailable];

    // checking 30s then notify resume to home to reset "lo trinh"
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESUME_APP
                                                        object:nil
                                                      userInfo:nil];
    
    // check location service enable
    NSInteger stt = [CLLocationManager authorizationStatus];
    BOOL enable = (stt == kCLAuthorizationStatusAuthorizedWhenInUse
                   || stt == kCLAuthorizationStatusAuthorizedAlways);
    [GoogleMapsHelper shareInstance].locationError = enable ? nil : [NSError errorWithDomain:@"Location disabled" code:1000 userInfo:nil];
    if (enable) {
        [[GoogleMapsHelper shareInstance] startUpdateLocation];
    }
    
    [[ShortcutItemManager instance] processShortcutItem];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"applicationWillTerminate");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_APP_WILL_TERMINAL object:nil];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *))restorationHandler {
    // [START_EXCLUDE silent]
    NSLog(@"%@", userActivity.webpageURL);
    __weak AppDelegate *weakSelf = self;
    // [END_EXCLUDE]
    
    BOOL handled = [[FIRDynamicLinks dynamicLinks]
                    handleUniversalLink:userActivity.webpageURL
                    completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                 NSError * _Nullable error) {
                        // [START_EXCLUDE]
                        AppDelegate *strongSelf = weakSelf;
                        NSString *link = dynamicLink.url.absoluteString;
                        [[VatoManageDeepLink instance] handlerDeepLink:dynamicLink.url];
                        [strongSelf verifyInviteCode:link];
                        // [END_EXCLUDE]
                    }];
    
    // [START_EXCLUDE silent]
    if (!handled) {
        // Show the deep link URL from userActivity.
        NSString *link = userActivity.webpageURL.absoluteString;
        [self verifyInviteCode:link];
    }
    // [END_EXCLUDE]
    
    return handled;
}

- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
        
    if ([[url absoluteString] containsString:@"zp-redirect"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:zpTransactionUpdateNotification object:[url copy]];
        return YES;
    }
    
    if ([[FIRAuth auth] canHandleURL:url]) {
        return YES;
    }
    
    FIRDynamicLink *result = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (result) {
        [[VatoManageDeepLink instance] handlerDeepLink:result.url];
        return YES;
    }
    
//    if ([url.absoluteString hasPrefix:@"fb"]) {
//        return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                              openURL:url
//                                                    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                                           annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
//                ];
//
//    } else
    if ([url.absoluteString hasPrefix:@"momo"]) {
        [MomoBridge handleOpenUrlWithOpen:url sourceApplication:@""];
    }
    return [[GIDSignIn sharedInstance] handleURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[FIRAuth auth] canHandleURL:url]) {
        return YES;
    }
    
    
//    if ([url.absoluteString hasPrefix:@"fb"]) {
//        return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                              openURL:url
//                                                    sourceApplication:sourceApplication
//                                                           annotation:annotation
//                ];
//
//    } else
    if ([url.absoluteString hasPrefix:@"momo"]) {
        [MomoBridge handleOpenUrlWithOpen:url sourceApplication:sourceApplication];
    }

    
    if ([[url absoluteString] containsString:@"zp-redirect"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:zpTransactionUpdateNotification object:url];
        return YES;
    }

    
    FIRDynamicLink *dynamicLink =
    [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    if (dynamicLink) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // [START_EXCLUDE]
        // In this sample, we just open an alert.
        NSString *link = [[dynamicLink url] absoluteString];
        [self verifyInviteCode:link];
        // [END_EXCLUDE]
        return YES;
    }
    
    return [[GIDSignIn sharedInstance] handleURL:url];
}

- (void) verifyInviteCode: (NSString*) inviteUrl {
    self.inviteUrl = inviteUrl;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deepLink" object:inviteUrl];

    if (![[FIRAuth auth] currentUser]) {
        AppLogCurrentUser()
        return;
    }
    
    if (self.homeViewModel) {
        [self.homeViewModel checkInviteDynamicLink];
    }

}

- (NSString*) getInviteCode : (NSString*) inviteLink {
    NSString* codeInvite;
    
    NSArray *comp1 = [inviteLink componentsSeparatedByString:@"?"];
    NSString *query = [comp1 lastObject];
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        if (keyVal.count > 0) {
            NSString *variableKey = [keyVal objectAtIndex:0];
            NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : nil;
            if ([variableKey isEqualToString:@"invitecode"]) {
                codeInvite = value;
                break;
            }
        }
    }
    
    return codeInvite;
}

- (void) checkAlert:(UIViewController *)vc handler: (void (^)(void))handler {
    if ([vc isKindOfClass:[AlertVC class]]) {
        [vc dismissViewControllerAnimated:NO completion:handler];
        return;
    }

    UIViewController *presentedVC = [vc presentedViewController];
    if ([presentedVC isKindOfClass:[AlertVC class]]) {
        [presentedVC dismissViewControllerAnimated:NO completion:handler];
        return;
    }
    
    if (handler) {
        handler();
    }
    
}

- (void) checkUserAvailable {
////    @try {
//        if ([self isNetworkAvailable]) {
//            FIRUser* user = [[FIRAuth auth] currentUser];
//            if (user) {
//                [user getIDTokenForcingRefresh:YES
//                                    completion:^(NSString* token, NSError* error) {
//                                        if (error && error.code != FIRAuthErrorCodeNetworkError) {
//                                            [[FIRAuth auth] signOut:nil];
//                                            [self loadSplashView];
//                                        }
//                                    }];
//            }
//        }
////    }
////    @catch (NSException* e) {
////
////    }
}

- (void) loadSplashView {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:@"SplashViewController" inStoryboard:STORYBOARD_LOGIN];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void) loadTutorialStartup {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:@"FCTutorialStartupPageViewController" inStoryboard:STORYBOARD_TUTORIAL];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
    {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        
        return [self visibleViewController:lastViewController];
    }
    if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
        UIViewController *selectedViewController = tabBarController.selectedViewController;
        
        return [self visibleViewController:selectedViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    
    return [self visibleViewController:presentedViewController];
}

#pragma mark - Push notification settings
- (void)connectToFcm {
    // Won't connect since there is no token
//    if (![[FIRInstanceID instanceID] token]) {
//        return;
//    }
    
    // Disconnect previous FCM connection if it exists.
//    [[FIRMessaging messaging] setShouldEstablishDirectChannel:YES];
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FIRMessaging messaging].APNSToken = deviceToken;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self checkingLastestBooking];
    DLog(@"Disconnected from FCM");
    
//    [[FIRMessaging messaging] setShouldEstablishDirectChannel:NO];
    lastimeOpenApp = [self getCurrentTimeStamp];
    
//    [application beginBackgroundTaskWithExpirationHandler:^{
//        DLog(@"beginBackgroundTaskWithExpirationHandler")
//    }];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Print full message.
    DLog(@"%@", userInfo);
    
    [self onReceivePush:userInfo];
    [self increaseBadge];
}

- (void) increaseBadge {
    FCHomeViewModel *model = [FCHomeViewModel getInstace];
    if (model) {
        NSInteger current = model.totalUnreadNotify;
        [model setNotifyBadge:current + 1];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Print full message.
    NSLog(@"%@", userInfo);
    [self increaseBadge];
    completionHandler(UIBackgroundFetchResultNewData);
    
    [self onReceivePush:userInfo];
    
    if ([[FIRAuth auth] canHandleNotification:userInfo]) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message
    NSLog(@"%@", remoteMessage.appData);
    
    [self onReceivePush:remoteMessage.appData];
}
#endif


- (void) onReceivePush: (NSDictionary*) dict {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Vato otify" message:[dict description] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [alertView show];
//    });
    
    if ([self changeMethod:dict]) {
        return;
    }

    self.pushData = dict;
    [[UserDataHelper shareInstance] cacheCurrentPushData:dict];
    [[NotificationPushService instance] updateWithPush:dict];
}

- (void)finishLoggedIn {
    [[FirebaseHelper shareInstance] updateDeviceInfo];
    if ([ConfigManager shared].useNewHome) {
//        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//        UIViewController *presentVC = [rootVC presentedViewController];
//        if (presentVC) {
//            [presentVC dismissViewControllerAnimated:NO completion: nil];
//        } else {
//            [self moveToHomeNew];
//        }
        
    } else {
        UIViewController *controller = [[NavigatorHelper shareInstance] getViewControllerById:MAIN_VIEW_CONTROLLER
                                                                                 inStoryboard:STORYBOARD_MAIN];
        
        //    __weak AppDelegate *delegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
        self.window.rootViewController = controller;
    }
    self.needCheckVersion = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkLockAccount];
    });
}

- (BOOL)changeMethod:(NSDictionary *)json {
    if (!json) {
        return NO;
    }
    
    NSNumber *type = (NSNumber *)[json objectForKey:@"type"];
    
    if (!type || [type integerValue] != NotifyNotEnoughVatoPay) {
        return NO;
    }
    
    if (_subjectOutOfMoney) {
        [_subjectOutOfMoney sendNext:@(YES)];
    }
    
    return YES;
}

- (void)handlerChangeMethodPayment:(void (^)(void))handler {
    if (!_subjectOutOfMoney) {
        self.subjectOutOfMoney = [RACBehaviorSubject behaviorSubjectWithDefaultValue:nil];
    }
    
    [[self.subjectOutOfMoney deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        NSNumber *number = [NSNumber castFrom:x];
        if (!number) {
            return;
        }
        
        if (handler) {
            handler();
        }
    }];
}

- (void)cleanUpListenChangeMethod {
    if (!_subjectOutOfMoney) {
        return;
    }
    
    [self.subjectOutOfMoney sendCompleted];
    self.subjectOutOfMoney = nil;
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    
}


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    UNNotificationRequest *request = notification.request;
    if (request) {
        NSDictionary *userInfor = request.content.userInfo ?: @{};
        
        DLog(@"!!!!!Information : %@", userInfor);
        [self onReceivePush:userInfor];
        
    }
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    UNNotificationRequest *request = response.notification.request;
    if (request) {
        NSDictionary *userInfor = request.content.userInfo ?: @{};
        DLog(@"!!!!!Information D : %@", userInfor);
        NSMutableDictionary *new = [[NSMutableDictionary alloc] initWithDictionary:userInfor];
        new[UserNotificationTap] = @(YES);
        [self onReceivePush:new];

    }

    completionHandler();
}

- (void)moveToHomeNew {
    UIViewController *controllerVC = [self.routeHome presentMain];
    controllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    controllerVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    @weakify(self);
    [self.window.rootViewController presentViewController:controllerVC animated:YES completion:^{
        @strongify(self);
        self.needCheckVersion = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkLockAccount];
        });
    }];
//    self.window.rootViewController = controllerVC;
    
}

- (void)signOut {
    [[UserManager instance] removeInfo];
    void(^signOut)(void) = ^{
        LoggedOutWrapper *wrapper = self.wrapper;
        UIViewController* startview = [wrapper presentLoggedOut];
        startview.modalPresentationStyle = UIModalPresentationFullScreen;
        startview.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        UIViewController *rootVC = self.window.rootViewController;
        void(^moveToLogin)(void) = ^{
            [rootVC presentViewController:startview animated:YES completion:nil];
        };
        UIViewController *presentVC = [rootVC presentedViewController];
        if (presentVC) {
            [presentVC dismissViewControllerAnimated:NO completion: nil];
        } else {
            moveToLogin();
        }
    };
    if (_routeHome) {
        [_routeHome deactive];
        signOut();
    } else {
        signOut();
    }
}

- (void)cleanUp {
    [[APICall shareInstance] apiSigOut];
    [[TicketLocalStore shared] resetDataLocalTicket];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    // fb
//    [[FBSDKLoginManager new] logOut];
    
    [[GIDSignIn sharedInstance] signOut];
    
    NSError* err;
    [[FIRAuth auth] signOut:&err];
    
    AppLog(@"User had been logged out.")
    if (err) {
        AppError(err)
    }
    [[UserDataHelper shareInstance] clearUserData];
}

#endif


#pragma mark Shortcut handler
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler API_AVAILABLE(ios(9.0)) API_UNAVAILABLE(tvos) {
    [[ShortcutItemManager instance] addShortcutItemWithShortcutItemToProcess:shortcutItem];
}
@end

