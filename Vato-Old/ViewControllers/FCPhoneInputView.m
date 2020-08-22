//
//  FCPhoneInputView.m
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPhoneInputView.h"
#import <PhoneCountryCodePicker/PCCPViewController.h>
#import "FCSmsCodeVerifyView.h"
#import "APICall.h"
#import "FCTrackingHelper.h"

@interface FCPhoneInputView ()
@end

@implementation FCPhoneInputView {
    NSString* _phoneCode;
    BOOL _shouldShowKeyboard;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    _shouldShowKeyboard = YES;
    
    RAC(self.btnNext, enabled) = [RACSignal combineLatest:@[self.tfPhone.rac_textSignal]
                                                   reduce:^(NSString* phone){
//                                                       if (phone.length > 0) {
//                                                           NSString* firstChar = [NSString stringWithFormat:@"%c",[phone characterAtIndex:0]];
//                                                           if (![firstChar isEqualToString:@"0"]) {
//                                                               phone = [NSString stringWithFormat:@"0%@", phone];
//                                                           }
//                                                       }
//
//                                                       if (phone.length == 10) {
//                                                           self.lblError.hidden = YES;
//                                                           return  @(YES);
//                                                       }
//
//                                                       return @(NO);
                                                       return @([self validPhone:phone]);
                                                   }];
    
    //first
    NSDictionary * countryDic = [PCCPViewController infoForPhoneCode:VN_PHONE_CODE];
    _phoneCode = [NSString stringWithFormat:@"+%d", [[countryDic valueForKey:@"phone_code"] integerValue]];
    self.icFlag.image = [PCCPViewController imageForCountryCode:countryDic[@"country_code"]];
    self.lblCountrycode.text = [NSString stringWithFormat:@"(%@)", _phoneCode];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void) show {
    [super show];
    
    if (self.loginViewModel.loginType == FCLoginTypeChangePhone) {
        self.lblTitle.text = @"Nhập số điện thoại mới";
    }
}

- (void) willMoveToWindow: (UIWindow*) window {
    [super willMoveToWindow:window];
    if (window && _shouldShowKeyboard) {
        [NSTimer scheduledTimerWithTimeInterval:0.3f
                                         target:self
                                       selector:@selector(onShowKeyboard)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void) onShowKeyboard {
    [self.tfPhone becomeFirstResponder];
}

- (IBAction)onNextClicked:(id)sender {
    [self verifySMS];
}

- (void) verifySMS {
    [self.loginViewModel setPhoneNumber:self.tfPhone.text
                           andPhoneCode:_phoneCode];
    
    if (self.loginViewModel.loginType == FCLoginTypeChangePhone) {
        AppLog([FIRAuth auth].currentUser.phoneNumber)

        NSString* phone = [FIRAuth auth].currentUser.phoneNumber;
        phone = [phone stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
        if ([self.loginViewModel.phoneNumber isEqualToString:phone]) {
            self.lblError.hidden = NO;
            self.lblError.text = @"Không thể đổi sang số điện thoại đang sử dụng!";
            [self.btnNext dismissProcess];
            return;
        }
    }
    
    _shouldShowKeyboard = NO;
    self.btnNext.enabled = NO;
    
    // for apply apple review
    if ([self.loginViewModel.phoneNumber isEqualToString:PHONE_TEST]) {
        [self loadSMSCodeView];
        return;
    }
    
    // for normal login
    [self.loginViewModel getSMSPasscode:^(NSError *err) {
        self.btnNext.enabled = YES;
        
        if (err) {
            [self showError: err];
        }
        else {
            [self loadSMSCodeView];
            
            [FCTrackingHelper trackEvent:@"RequestOTP" value:@{@"Service":[[FirebaseHelper shareInstance] getAuthServiceName],
                                                               @"Result":@"success",
                                                               @"Phone":self.tfPhone.text}];
        }
    }];
}

- (void) loadSMSCodeView {
    FCSmsCodeVerifyView* smsCodeView = [[FCSmsCodeVerifyView alloc] intView];
    smsCodeView.viewController = self.viewController;
    smsCodeView.loginViewModel = self.loginViewModel;
    [self addSubview:smsCodeView];
    [smsCodeView showNext];
    self.smsCodeView = smsCodeView;
}

- (IBAction)countryClicked:(id)sender {
    
    /*
    //second
    PCCPViewController * vc = [[PCCPViewController alloc] initWithCompletion:^(id countryDic) {
        self.icFlag.image = [PCCPViewController imageForCountryCode:countryDic[@"country_code"]];
        _phoneCode = [NSString stringWithFormat:@"+%ld", [[countryDic valueForKey:@"phone_code"] integerValue]];
        self.lblCountrycode.text = [NSString stringWithFormat:@"(%@)", _phoneCode];
    }];
    
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.viewController presentViewController:naviVC animated:YES completion:NULL];
     */
}

- (IBAction)backPressed:(id)sender {
    if ([FIRAuth auth].currentUser) {
        NSError* err;
        [[FIRAuth auth] signOut:&err];

        AppLog(@"User had been logged out.")
        if (err) {
            AppError(err)
        }
    } else {
        AppLogCurrentUser()
    }
    
    [self.tfPhone resignFirstResponder];
    [self hide];
}

- (void) showError: (NSError*) err {
    self.lblError.hidden = NO;
    NSString* errCode;
    if (err.code == FIRAuthErrorCodeInvalidPhoneNumber) {
        self.lblError.text = @"Số điện thoại không đúng.";
        errCode = @"FIRAuthErrorCodeInvalidPhoneNumber";
    }
    else if (err.code == FIRAuthErrorCodeMissingPhoneNumber) {
        self.lblError.text = @"Cung cấp số điện thoại để tiếp tục.";
        errCode = @"FIRAuthErrorCodeMissingPhoneNumber";
    }
    else if (err.code == FIRAuthErrorCodeTooManyRequests) {
        self.lblError.text = @"Số điện thoại này đang bị quấy rối. Quay lại sau.";
        errCode = @"FIRAuthErrorCodeTooManyRequests";
    }
    else if ([err.localizedDescription containsString:@"InvalidPhoneNumberFormatException"]) {
        self.lblError.text = @"Số điện thoại không đúng.";
        errCode = @"InvalidPhoneNumberFormatException";
    }
    else if ([err.localizedDescription containsString:@"MustWaitBeforeRequestAnotherVerifyCodeException"]) {
        self.lblError.text = @"Vui lòng thử lại sau giây lát.";
        errCode = @"MustWaitBeforeRequestAnotherVerifyCodeException";
    }
    else {
        self.lblError.text = @"Xảy ra lỗi. Vui lòng thử lại.";
        
        errCode = err.localizedDescription;
        if (errCode.length == 0) {
            errCode = @"FCLoginResultCodeVerifyPhoneUnknowError";
        }
    }
    
    [FCTrackingHelper trackEvent:@"RequestOTP" value:@{@"Service":[[FirebaseHelper shareInstance] getAuthServiceName],
                                                       @"Result":errCode,
                                                       @"Phone":self.tfPhone.text}];
}
@end
