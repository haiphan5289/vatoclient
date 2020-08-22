//
//  SplashViewController.m
//  FaceCar
//
//  Created by facecar on 4/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "SplashViewController.h"
#import "FacecarNavigationViewController.h"
#import "AppDelegate.h"
#import "UserDataHelper.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImagePDFCoder/SDWebImagePDFCoder.h>

@interface AppDelegate(CheckVersion)
@property (assign, nonatomic) BOOL needCheckVersion;
@property (nonatomic, strong) LoggedOutWrapper *wrapper;
@end

@interface SplashViewController()<ThemeManagerHandlerProtocol>
@property (assign, nonatomic) NSInteger maxRetry;
@property (weak, nonatomic) IBOutlet UIImageView *topBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBgImageView;

@end

@implementation SplashViewController

- (void)dealloc {
    DLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [self themeUpdateUI];

    if ([ValidateDeviceJailBreak isJailBreak]) {
        exit(0);
    }
    [super viewDidLoad];

    self.maxRetry = 3;
    [LoadingManager dismissProgress];
    [AppLoadConfigure applyConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self beginLoad];
    });
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (RACSignal *) currentUser {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        FIRAuthStateDidChangeListenerHandle handler = [[FIRAuth auth]
                                                       addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
                                                           [subscriber sendNext:user];
                                                           [subscriber sendCompleted];
                                                       }];
        return [RACDisposable disposableWithBlock:^{
            [[FIRAuth auth] removeAuthStateDidChangeListener:handler];
        }];
    }];
    @weakify(self);
    return [[signal try:^BOOL(FIRUser *user, NSError *__autoreleasing *errorPtr) {
        // Make the code for retry
         NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:345123 userInfo:nil];
         *errorPtr = e;
         return user != nil;
    }] catch:^RACSignal *(NSError *error) {
        // Check if it needs retry
        @strongify(self);
        if (self.maxRetry <= 0) {
            return [RACSignal error:error];
        }
        self.maxRetry -= 1;
        return error.code == 345123 ? [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] take:1] flattenMap:^RACStream *(id value) {
            @strongify(self);
            return [self currentUser];
        }] : [RACSignal error:error];
    }];
}

- (void)checkAuthenticatedFromFirebase {
    @weakify(self);
    RACSignal *currentUser = [[self currentUser] catch:^RACSignal *(NSError *error) {
        DLog(@"Not Found User , Error : %@ !!!!!!!", error);
        return [RACSignal return:nil];
    }];
    
    [currentUser subscribeNext:^(FIRUser *user) {
        // Old logic check
        [[user rac_willDeallocSignal] subscribeNext:^(id x) {
            NSLog(@"Check!!!!");
        }];
        if (user) {
            [user getIDTokenForcingRefresh:YES
                                completion:^(NSString * _Nullable token, NSError * _Nullable error) {
                                    @strongify(self);
                                    if (error && error.code != FIRAuthErrorCodeNetworkError) {
                                        [[UserDataHelper shareInstance] clearUserData];
                                    }
                                    
                                    [self checkUserAuthen];
                                }];
        }
        else {
            @strongify(self);
            [[UserDataHelper shareInstance] clearUserData];
            [self checkUserAuthen];
        }
    }];
}

- (void) beginLoad {
    @weakify(self);
    AppDelegate *delegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
    void (^recheck)(void) = ^ {
        @strongify(self);
        [self checkAuthenticatedFromFirebase];
    };
    
    if (![delegate isNetworkAvailable]) {
        [[[self checkNework] take:1] subscribeNext:^(id x) {
            @strongify(self);
            [self dismissCurrentVC:recheck];
        }];
    } else { recheck(); }
}

- (void) loadLoginView {
    __weak AppDelegate *delegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
    __weak LoggedOutWrapper *wrapper = delegate.wrapper;
    UIViewController* vc = [wrapper presentLoggedOut];
    [self moveTo:vc completion:nil];
}

- (void) moveTo:(UIViewController *)vc completion:(void(^)(void))handler {
    AppDelegate *delegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void) privateLoadHome {
    AppDelegate *delegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
    if (![delegate isNetworkAvailable]) {
        @weakify(self);
        [[[self checkNework] take:1] subscribeNext:^(id x) {
            @strongify(self);
            [self loadHome];
        }];
        return;
    }
    if ([ConfigManager shared].useNewHome) {
        [delegate moveToHomeNew];
    } else {
        UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:MAIN_VIEW_CONTROLLER
                                                                                     inStoryboard:STORYBOARD_MAIN];
        
        
        //    [self moveTo:viewController completion:^{
        //        @strongify(delegate);
        //        // should check
        //        delegate.needCheckVersion = YES;
        //        [delegate checkUpdateVersion];
        //    }];
        
        delegate.window.rootViewController = viewController;

    }
    
}

- (void) alertNoNetwork {
    @weakify(self);
    void (^ShowAlert)(void) = ^ {
        AlertActionObjC* actionOk = [[AlertActionObjC alloc] initFrom:localizedFor(@"Đồng ý") style:UIAlertActionStyleDefault handler:^{
            @strongify(self);
            [self openWifiSettings];
        }];
        
        [AlertVC showObjcOn:self title:localizedFor(@"Mất kết nối")
                    message:localizedFor(@"Đường truyền mạng trên thiết bị đã mất kết nối. Vui lòng kiểm tra và thử lại.")
                  orderType:UILayoutConstraintAxisHorizontal from:@[actionOk]];
    };
    [self dismissCurrentVC:ShowAlert];
}

- (RACSignal *) observerHadNetwork {
    return  [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:NOTIFICATION_NETWOTK_CONNECTED object:nil] takeUntil:self.rac_willDeallocSignal] map:^NSNumber *(id value) {
        return @(YES);
    }];
}

- (RACSignal *) observerBecomeActive {
    return [[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) dismissCurrentVC: (void(^)(void)) handler {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:handler];
    } else {
        if (handler) {
            handler();
        }
    }
}

- (void) loadHome {
    @weakify(self);
    void (^LoadHome)(void) = ^{
        @strongify(self);
        [self privateLoadHome];
    };
    [self dismissCurrentVC:LoadHome];
}

- (void)moveToLogin {
    @weakify(self);
    void (^Login)(void) = ^{
        @strongify(self)
        [self loadLoginView];
    };
    [self dismissCurrentVC:Login];
}
    

- (RACSignal *)checkNework {
    [self alertNoNetwork];
    RACSignal *network = [self observerHadNetwork];
    RACSignal *finish = [[RACSignal merge:@[network, self.rac_willDeallocSignal]] take:1];
    RACSignal *becomeActive = [[self observerBecomeActive] takeUntil: finish];
    @weakify(self);
    [becomeActive subscribeNext:^(id x) {
        @strongify(self);
        [self alertNoNetwork];
    }];
    
    return network;
}

- (void) loadHomeView {
    @weakify(self);
    LocationHelper *helper = [[LocationHelper alloc] init:^{
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self privateLoadHome];
        });
    } error:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self privateLoadHome];
        });
    }];
    
    [helper checkLocation];
}

#pragma mark - Check Settings

- (IBAction)outClicked:(id)sender {
//    [[FIRAuth auth] signOut:nil];
}

- (RACSignal *) loadClient {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[FirebaseHelper shareInstance] getClient:^(FCClient* client) {
            if (client && client.user.firebaseId.length > 0 && client.user.phone.length > 0) {
                [subscriber sendNext:client];
                [subscriber sendCompleted];
            }
            else {
                NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{ NSLocalizedDescriptionKey : @"Need to login again"}];
                [subscriber sendError:e];
            }
        }];
        return nil;
    }];
}

- (void) checkUserAuthen {
    @weakify(self);
    [[[self loadClient] take:1]
     subscribeNext:^(FCClient *client) {
        // Cache
        FCUser *user = client.user;
        NSDictionary *json = [user toDictionary];
         [[UserManager instance] cacheWithUser:json];
        @strongify(self);
        [self loadHomeView];
    } error:^(NSError *error) {
        AppError(error)
        @strongify(self);
        [self moveToLogin];
    }];
}

- (void)themeUpdateUI {
    [[ThemeManager instance] setPDFImageWithName:@"bg_splash_top" view:self.topBgImageView placeholder: nil];
    [[ThemeManager instance] setPDFImageWithName:@"bg_splash_bottom" view:self.bottomBgImageView placeholder: nil];
}

@end
    
