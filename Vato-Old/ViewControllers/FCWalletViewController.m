//
//  AmountViewController.m
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWalletViewModel.h"
#import "FCHomeViewModel.h"
#import "FCWalletViewController.h"
#import "FCDepositViewController.h"
#import "FCInvoiceManagerViewController.h"
#import "FCProfileLevel2ViewController.h"
#import "FCWithdrawViewController.h"
#import "APICall.h"
#import "UserDataHelper.h"
#import "UserDataHelper-Private.h"
#import "FCPasscodeViewController.h"
#import "FCNewWebViewController.h"
#import "FCClientConfig.h"

NSString * const topupSuccessNotification = @"topupSuccessNotification";
@interface FCWalletViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblCash;
@property (weak, nonatomic) IBOutlet UILabel *lblCoin;

// topup
@property (weak, nonatomic) IBOutlet UILabel *lblTopup;
@property (weak, nonatomic) IBOutlet UIView *topupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consTopupHeight;

// tranfer
@property (weak, nonatomic) IBOutlet UILabel *lblTransferMoney;
@property (weak, nonatomic) IBOutlet UIView *tranferMoneyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consTransferMoneyHeight;

@end

@implementation FCWalletViewController {
    BOOL _shouldReloadBalance;
}


- (instancetype) initView:(FCHomeViewModel *)homeModel {
    self = [self initWithNibName:@"FCWalletViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"VATOPay";
    self.homeViewModel = homeModel;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.walletViewModel = [[FCWalletViewModel alloc] initViewModel:self];
    
    NSInteger cash = self.homeViewModel.client.user.cash;
    NSInteger coin = self.homeViewModel.client.user.coin;
    [self.lblAmount setText:[self formatPrice:(cash + coin) withSeperator:@"."]];
    [self.lblCash setText:[self formatPrice:cash withSeperator:@"."]];
    [self.lblCoin setText:[self formatPrice:coin withSeperator:@"."]];
    
    [IndicatorUtils show];
    [self getCurrentBalance];
    [self checkTopupView];
    [self checkTransferMoneyView];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTransferMoneySuccess)
                                                 name:topupSuccessNotification
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_shouldReloadBalance) {
        [self getCurrentBalance];
        _shouldReloadBalance = NO;
    }
}

- (void) getCurrentBalance {
    @weakify(self);
    [self.walletViewModel apiGetMyBalance:^(FCBalance *balance) {
        @strongify(self);
        [IndicatorUtils dissmiss];
        if (balance) {
            [self.lblAmount setText:[self formatPrice:(balance.cash + balance.coin) withSeperator:@"."]];
            [self.lblCash setText:[self formatPrice:balance.cash withSeperator:@"."]];
            [self.lblCoin setText:[self formatPrice:balance.coin withSeperator:@"."]];
            self.homeViewModel.client.user.cash = balance.cash;
            self.homeViewModel.client.user.coin = balance.coin;
            
            [self.delegate onReceiveBalance:balance.cash coin:balance.coin];
        }
    }];
}

#pragma mark - Topup View
- (NSArray <FCLinkConfigure *> *)configure_top_up {
    FirebaseHelper *helper = [FirebaseHelper shareInstance];
    FCAppConfigure *config = helper.appConfigure;
    return config ? config.topup_configure : @[];
}

- (void) checkTopupView {
    [self enableTopupView:NO];
    [[APIHelper shareInstance] get:API_GET_TOPUP_CONFIG params:nil complete:^(FCResponse *response, NSError *error) {
        if (response.status == APIStatusOK && response.data) {
            NSMutableArray* channels = [[NSMutableArray alloc] init];
            for (NSDictionary* dict in response.data) {
                FCLinkConfigure* config = [[FCLinkConfigure alloc] initWithDictionary:dict error:nil];
                if (config && config.active) {
                    [channels addObject:config];
                }
            }
            
            [self enableTopupView:channels.count > 0];
        }
        else {
            [self enableTopupView:NO];
        }
    }];
}

- (void) enableTopupView: (BOOL) enable {
    if (enable) {
        self.topupView.hidden = NO;
        self.consTopupHeight.constant = 50;
        self.lblTopup.text = @"Nạp tiền";
    } else {
        self.topupView.hidden = YES;
        self.consTopupHeight.constant = 0;
        self.lblTopup.text = EMPTY;
    }
}

- (FCLinkConfigure*) getLinkTopup {
    NSArray* links = [FirebaseHelper shareInstance].appConfigure.app_link_configure;
    for (FCLinkConfigure* link in links) {
        if (link.type == LinkConfigureTypeTopup && link.active) {
            return link;
        }
    }
    
    return nil;
}

#pragma mark - Transfer Money View
- (void) checkTransferMoneyView {
    FCClientConfig* config = [self getTransferMoneyConfig];
    if (config) {
        if (config.active) {
            self.tranferMoneyView.hidden = NO;
            self.consTransferMoneyHeight.constant = 50;
            self.lblTransferMoney.text = config.name;
        }
        else {
            self.tranferMoneyView.hidden = YES;
            self.consTransferMoneyHeight.constant = 0;
            self.lblTransferMoney.text = EMPTY;
        }
    }
}
- (FCClientConfig*) getTransferMoneyConfig {
    NSArray* configs = [FirebaseHelper shareInstance].appConfigure.client_config;
    for (FCClientConfig* c in configs) {
        if (c.type == ClientConfigTypeTranferMoney) {
            return c;
        }
    }
    
    return nil;
}

- (void)dealloc
{
    
}

- (void) onTransferMoneySuccess {
    [self getCurrentBalance];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:topupSuccessNotification
//                                                  object:nil];
}

#pragma mark - Action
- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)depositClicked:(id)sender {
//    [FCTrackingHelper trackEvent:@"Topup" value:@{@"ClickButton" : @"Topup"}];
//    TopUpChooseVC *chooseVC = [[TopUpChooseVC alloc] initWith:[self configure_top_up] ];
//    [self.navigationController pushViewController:chooseVC animated:YES];

    
//    [IndicatorUtils show];
//    [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
//        [IndicatorUtils dissmiss];
//        _shouldReloadBalance = YES;
//        FCLinkConfigure* link = [self getLinkTopup];
//        NSString* newUrl = [NSString stringWithFormat:@"%@?deviceId=%@&#%@",link.url, [self getDeviceId], token];
//        FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
//        vc.title = link.name;
//        [self presentViewController:vc
//                           animated:YES
//                         completion:^{
//                             [vc loadWebview:newUrl];
//                         }];
//    }];
}

- (IBAction)withdrawClicked:(id)sender {

}

- (IBAction)transferMoneyClicked:(id)sender {
    @weakify(self);
    [self canTranserCash:^(BOOL can) {
        @strongify(self);
        if (can) {
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(onTransferMoneySuccess)
//                                                         name:topupSuccessNotification
//                                                       object:nil];

            FCWithdrawViewController* vc = (FCWithdrawViewController*) [[NavigatorHelper shareInstance] getViewControllerById:@"FCWithdrawViewController" inStoryboard:@"WithdrawMoney"];
            vc.homeViewModel = self.homeViewModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            [AlertVC showAlertObjcOn: self
                               title:@"Thông báo"
                             message:@"Bạn cần tạo mật khẩu thanh toán để sử dụng chức năng này. Tạo mật khẩu?"
                            actionOk:@"Đồng ý"
                        actionCancel:@"Bỏ qua"
                          callbackOK:^{
                               [self loadCreatePINView];
                          }
                      callbackCancel:^{
                      }];
        }
    }];
}

- (IBAction)historyTransClicked:(id)sender {
    [FCTrackingHelper trackEvent:@"Topup" value:@{@"ClickButton" : @"History"}];
    FCInvoiceManagerViewController* vc = [[FCInvoiceManagerViewController alloc] initView];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void) loadCreatePINView {
    FCPasscodeViewController* passView = [[FCPasscodeViewController alloc] initWithNibName:@"FCPasscodeViewController"
                                                                                    bundle:nil];
    [self.navigationController pushViewController:passView
                                         animated:YES];
}

#pragma mark - Logic

- (void) canTranserCash: (void (^) (BOOL can)) block {
    [IndicatorUtils show];
    [[APIHelper shareInstance] get:API_CHECK_TRANF_CASH
                            params:nil
                          complete:^(FCResponse *response, NSError *error) {
                              [IndicatorUtils dissmiss];
                              if (response.status == APIStatusOK) {
                                  BOOL c = [(NSNumber*)response.data boolValue];
                                  block(c);
                              }
                          }];
}

- (void) loadUpdateProfile {
    FCProfileLevel2ViewController* des = (FCProfileLevel2ViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"FCProfileLevel2ViewController" inStoryboard:STORYBOARD_PROFILE];
    [self.navigationController pushViewController:des animated:YES];
}

@end
