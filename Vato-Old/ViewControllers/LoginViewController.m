//
//  ViewController.m
//  FaceCar
//
//  Created by Vu Dang on 5/30/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "FacecarNavigationViewController.h"
#import "FCPhoneInputView.h"
#import "FCSocialConnectionView.h"
#import "UIView+Border.h"
#import <PhoneCountryCodePicker/PCCPViewController.h>
#import "FCRegisterAccountView.h"
#import "FCVivuPrivacyView.h"
#import "APICall.h"
#import "FCTrackingHelper.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *icFlag;
@property (weak, nonatomic) IBOutlet UILabel *lblCountrycode;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIImageView *ic_moto;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consMotoLeft;

@property (strong, nonatomic) GIDGoogleUser* googleUser;
@property (strong, nonatomic) FIRAuthCredential* authCredential;

@end

@implementation LoginViewController {
    FCPhoneInputView* _phoneView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginViewmodel = [[FCLoginViewModel alloc] init];
    self.loginViewmodel.viewController = self;
    [self registerLoginResultListener];
    
    NSDictionary * countryDic = [PCCPViewController infoForPhoneCode:VN_PHONE_CODE];
    NSString* phoneCode = [NSString stringWithFormat:@"(+%ld)", [[countryDic valueForKey:@"phone_code"] integerValue]];
    self.icFlag.image = [PCCPViewController imageForCountryCode:countryDic[@"country_code"]];
    self.lblCountrycode.text = phoneCode;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self animationRunMoto];
    
    [[GIDSignIn sharedInstance] signOut];
}

#pragma mark - Action Handler

- (IBAction)phoneTouch:(id)sender {
    [self loadPhoneView];
    [FCTrackingHelper trackEvent:@"Login" value:@{@"Channel":@"Phone"}];
}

- (IBAction)socialTouch:(id)sender {
    [self loadSocialConnectView];
    [FCTrackingHelper trackEvent:@"Login" value:@{@"Channel":@"Social"}];
}

- (void) animationRunMoto {
    CGRect frame = self.ic_moto.frame;
    self.consMotoLeft.constant = -frame.size.width;
    [UIView animateWithDuration:60
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat animations:^{
                            self.ic_moto.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width + frame.size.width, 0);
    } completion:^(BOOL finished) {}];
    
//    [UIView animateWithDuration:60
//                          delay:0
//                        options:UIViewAnimationOptionCurveLinear
//                     animations:^{
//                         self.ic_moto.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, frame.origin.y, frame.size.width, frame.size.height);
//                         self.consMotoLeft.constant = [UIScreen mainScreen].bounds.size.width;
//                     }
//                     completion:^(BOOL finished) {
//                         [self animationRunMoto];
//                     }];
}

#pragma mark - View Hander
- (void) loadPhoneView {
    if (_phoneView) {
        return;
    }
    _phoneView = [[FCPhoneInputView alloc] intView];
    _phoneView.viewController = self;
    _phoneView.loginViewModel = self.loginViewmodel;
    [self.view addSubview:_phoneView];
    [_phoneView show:^(BOOL finished) {
        _phoneView = nil;
    }];
}

- (void) loadSocialConnectView {
    FCSocialConnectionView* socialView = [[FCSocialConnectionView alloc] intView];
    socialView.viewController = self;
    socialView.loginViewModel = self.loginViewmodel;
    [self.view addSubview:socialView];
    [socialView show];
}

- (void) loadRegisterView {
    FCRegisterAccountView* registerView = [[FCRegisterAccountView alloc] intView];
    registerView.viewController = self;
    registerView.loginViewModel = self.loginViewmodel;
    [self.view addSubview:registerView];
    [registerView showNext];
}

- (void) loadPrivacyView {
    [self.view endEditing:YES];
    FCVivuPrivacyView* privacyView = [[FCVivuPrivacyView alloc] intView];
    privacyView.viewController = self;
    privacyView.loginViewModel = self.loginViewmodel;
    [self.view addSubview:privacyView];
    [privacyView showNext];
}

- (void) gotoHome {
    UIViewController *viewController = [[NavigatorHelper shareInstance] getViewControllerById:MAIN_VIEW_CONTROLLER
                                                                                 inStoryboard:STORYBOARD_MAIN];
    [self presentViewController:viewController
                       animated:NO
                     completion:nil];
}

#pragma mark - New Logic (V2) Handler
- (void) registerLoginResultListener {
    [RACObserve(self.loginViewmodel, resultCode) subscribeNext:^(NSNumber* resultcode) {
        if (resultcode) {
            NSInteger code = [resultcode integerValue];
            if (code == FCLoginResultCodeVerifySMSCodeSuccess) {
                [self checkingAccountWithBackend];
            }
            else if (code == FCLoginResultCodeRegisterAccountCompelted) {
                [self loadPrivacyView];
            }
            else if (code == FCLoginResultCodePrivacyAccepted) {
                [self gotoHome];
            }
            else if (code == FCLoginResultCodeSocialLinkedToPhone) {
                [self gotoHome];
            }
            else if (code == FCLoginResultCodeSocialNotLinkedToPhone) {
                [self loadPhoneView];
            }
            else if (code == FCLoginResultCodeBackendVerifyFailed) {
                [[[FCNotifyBannerView alloc] init] show:self.view
                                                forType:FCNotifyBannerTypeError
                                               autoHide:NO
                                                message:@"Tài khoản của bạn gặp sự cố. Vui lòng liên hệ tổng đài để được hỗ trợ."
                                             closeClick:nil
                                            bannerClick:nil];
            }
        }
    }];
}

- (void) checkingAccountWithBackend {
    [self.loginViewmodel apiCheckAccout:^(BOOL success, BOOL isUpdate, FCClient* client) {
        if (success) {
            if (client.user.fullName.length > 0) {
                if (isUpdate) {
                    [self.loginViewmodel apiUpdateAccount:client
                                                  handler:nil];
                }
                [self gotoHome];
            }
            else {
                [self loadRegisterView];
            }
        }
        else {
            [self checkUserData];
        }
    }];
}

- (void) checkUserData {
    [self.loginViewmodel checkingUserData:^(FCClient * client) {
        if (client) {
            [self gotoHome];
            [self.loginViewmodel apiCreateAccount:client
                                          handler:nil];
        }
        else {
            [self loadRegisterView];
        }
    }];
}

@end
