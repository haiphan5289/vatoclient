//
//  FCInputPhoneViewController.m
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCInputPhoneViewController.h"
#import "FCInputMoneyViewController.h"
#import "FCTransferMoneyViewModel.h"

@interface FCInputPhoneViewController ()

@end

@implementation FCInputPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tfPhone becomeFirstResponder];
    
    RAC(self.btnContinue, enabled) = [RACSignal combineLatest:@[self.tfPhone.rac_textSignal]
                                                       reduce:^ (NSString* phone) {
                                                           
                                                           [self.lblError setHidden:YES];
                                                           
                                                           if ([phone isEqualToString:self.homeViewModel.client.user.phone]) {
                                                               self.lblError.hidden = NO;
                                                               self.lblError.text = @"Không thể chuyển tiền cho chính mình";
                                                               return @(NO);
                                                           }
                                                           
                                                           if (phone.length > 0 && [self validPhone:phone]) {
                                                               return @(YES);
                                                           }
                                                           return @(NO);
                                                       }];
    
    
    @try {
        RAC(self.transfMoney, phone) = self.tfPhone.rac_textSignal;
    }
    @catch (NSException* e) {}
    @finally {}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continueClicked:(id)sender {
    [IndicatorUtils show];
    [[FCTransferMoneyViewModel shareInstance] apiGetPhoneDetail:self.tfPhone.text
                                                          block:^(FCUserInfo *user) {
                                                              [IndicatorUtils dissmiss];
                                                              
                                                              if (user) {
                                                                  FCInputMoneyViewController* des = (FCInputMoneyViewController*) [[NavigatorHelper shareInstance] getViewControllerById:@"FCInputMoneyViewController" inStoryboard:STORYBOARD_WITHDRAW];
                                                                  des.transfMoney = self.transfMoney;
                                                                  des.homeViewModel = self.homeViewModel;
                                                                  des.userInfo = user;
                                                                  des.channel = self.channel;
                                                                  [self.navigationController pushViewController:des animated:YES];
                                                              }
                                                          }];
    
}


@end
