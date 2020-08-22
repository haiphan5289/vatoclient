//
//  FCRegisterStationView.m
//  FaceCar
//
//  Created by facecar on 9/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCRegisterStationView.h"
#import "FCStationEvent.h"
#import "FCGiftViewController.h"
#import "FacecarNavigationViewController.h"
#import "ProfileDetailViewController.h"

@implementation FCRegisterStationView

- (id) init {
    self = [super init];
    return self;
}


- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [self.tfUserName becomeFirstResponder];
    
    [self setupView];
}

- (void) show {
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.25f
                          delay:0.15f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) setupView {
#if DEV
    self.tfUserName.text = @"duong.nguyen";
    self.tfPassword.text = @"465456";
#endif
    
    RAC(self.btnContinue, enabled) = [RACSignal combineLatest:@[self.tfUserName.rac_textSignal,
                                                                self.tfPassword.rac_textSignal]
                                                       reduce:^(NSString* username, NSString* pass){
                                                           return @(username.length > 5 && pass.length > 5);
                                                       }];
}

#pragma mark - Actions

- (IBAction)bgClicked:(id)sender {
    [self endEditing:YES];
    [self removeFromSuperview];
}

- (IBAction) onCancelClicked:(id)sender {
    [self endEditing:YES];
    [self removeFromSuperview];
}

- (IBAction)onContinueClicked:(id)sender {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_VERIFY_OFFICE_ACCOUNT
                               body:@{@"username": self.tfUserName.text,
                                      @"password": self.tfPassword.text}
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                               if (response.status != APIStatusOK) {
                                   self.lblError.text = localizedFor(@"Xảy ra lỗi xác thực. Vui lòng kiểm tra và thử lại!");
                               }
                               else {
                                   FCStationEvent* event = [[FCStationEvent alloc] initWithDictionary:[response valueForKey:@"data"] error:nil];
                                   [self loadEventView:event];
                                   [self onCancelClicked:nil];
                               }
                           }];
}

- (void) loadEventView : (FCStationEvent*) event {
    FCGiftViewController* vc = [[FCGiftViewController alloc] initViewWithNavi];
    vc.homeViewModel = ((ProfileDetailViewController*)self.viewController).homeViewModel;
    vc.stationEvents = event;
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc] initWithRootViewController:vc];
    
    [(UIViewController*)self.viewController presentViewController:navController
                                                         animated:TRUE
                                                       completion:nil];
}


@end
