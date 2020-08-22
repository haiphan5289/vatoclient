//
//  FCSocialConnection.m
//  FaceCar
//
//  Created by facecar on 11/18/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCSocialConnectionView.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface FCSocialConnectionView () <GIDSignInDelegate>

@end

@implementation FCSocialConnectionView

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (void) willMoveToWindow: (UIWindow*) window {
    [super willMoveToWindow:window];
    if (window) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void) show {
    [super show];
}

- (IBAction)backPressed:(id)sender {
    [self hide];
}

#pragma mark - Facebook
- (IBAction)facebookClicked:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithPermissions:@[@"email"] fromViewController:self.viewController handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
                                if (error) {
                                    [self notifyError];
                                }
                                else if (result.isCancelled) {
                                }
                                else {
                                    [IndicatorUtils show];
                                    [self.loginViewModel checkingSocialAuth:[[FirebaseHelper shareInstance] getfacebookCredential]
                                                                      block:^(NSError * err) {
                                                                          [IndicatorUtils dissmiss];
                                                                      }];
                                }
                            }];
}

- (void) notifyError {
    [[FCNotifyBannerView banner] show:nil
                              forType:FCNotifyBannerTypeError
                             autoHide:YES
                              message:@"Xảy ra lỗi trong quá trình xác thực tài khoản. Bạn vui lòng thử lại!"
                           closeClick:nil
                          bannerClick:^{
                              
                          }];
}
   
#pragma mark - Google

- (IBAction)googleClicked:(id)sender {
    [GIDSignIn sharedInstance].delegate = self;
    [[GIDSignIn sharedInstance] signIn];
}

- (void) signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self.viewController presentViewController:viewController
                                      animated:YES
                                    completion:nil];
    
}

- (void) signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES
                                       completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential* credential = [[FirebaseHelper shareInstance] getGoogleCredential:authentication.idToken
                                                                                accessToken:authentication.accessToken];
        
        [IndicatorUtils show];
        [self.loginViewModel checkingSocialAuth:credential
                                          block:^(NSError * err) {
                                              [IndicatorUtils dissmiss];
                                          }];
        
        [self hide];
        [[GIDSignIn sharedInstance] signOut];
    }
    else {
         [self notifyError];
    }
}

@end
