//
//  FCPaymentOptionViewController.m
//  FaceCar
//
//  Created by tony on 8/22/18.
//  Copyright © 2018 Vato. All rights reserved.
//
#import "FCViewController.h"
#import "FCPaymentOptionViewController.h"
#import "FCHomeViewModel.h"
#import "UserDataHelper.h"
#import "UserDataHelper-Private.h"
#import "FCNewWebViewController.h"

#define kCellCashIndex 0
#define kCellWalletIndex 1

@interface FCPaymentOptionViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMethodCash;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMethodVATOPay;

@end

@implementation FCPaymentOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = localizedFor(@"Phương thức thanh toán");
    _methodSelected = _oldSelect ? _oldSelect() : (PaymentMethod)^{
        return [FCHomeViewModel getInstace].client.paymentMethod;
    }();
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) setMethodSelected:(PaymentMethod)methodSelected {
//    [[FCHomeViewModel getInstace] updatePaymentMethod:methodSelected];
    if (self.callback) {
        self.callback(methodSelected);
    }
    [self closePressed:nil];
}

#pragma mark - Check Balance
- (void) checkBalance {
    FCHomeViewModel* homeViewModel = [FCHomeViewModel getInstace];
    [IndicatorUtils show];
    [homeViewModel checkOverBalance:^(BOOL enoughMoney) {
        [IndicatorUtils dissmiss];
        if (enoughMoney) {
            self.methodSelected = PaymentMethodVATOPay;
        }
        else {
            self.cellMethodVATOPay.accessoryType = UITableViewCellAccessoryNone;
            self.cellMethodCash.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [self confirmTopupToWallet];
        }
    }];
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

- (BOOL) canTopupToWallet {
   return [self getLinkTopup] != nil;
}

- (void) confirmTopupToWallet {
    __weak typeof(self) weakSelf = self;
    if ([self canTopupToWallet]) {
        [AlertVC showAlertObjcOn:self
                           title:localizedFor(@"Số dư không đủ")
                         message:localizedFor(@"Tài khoản của bạn không đủ số dư để sử dụng dịch vụ. Nạp thêm vào tài khoản để tiếp tục? Nếu không bạn sẽ thanh toán bằng tiền mặt cho chuyến đi.")
                        actionOk:localizedFor(@"Nạp tiền")
                    actionCancel:localizedFor(@"Bỏ qua")
                      callbackOK:^{
                           [weakSelf showWalletView];
                      }
                  callbackCancel:^{
                      weakSelf.methodSelected = PaymentMethodCash;
                  }];
    }
    else {
        [AlertVC showAlertObjcOn:self
                           title:localizedFor(@"Số dư không đủ")
                         message:localizedFor(@"Tài khoản của bạn không đủ số dư để sử dụng dịch vụ. Bạn vui lòng sử dụng tiền mặt để tiếp tục.")
                        actionOk:localizedFor(@"Đồng ý")
                    actionCancel:localizedFor(@"Bỏ qua")
                      callbackOK:^{
                          weakSelf.methodSelected = PaymentMethodCash;
                      }
                  callbackCancel:^{
                      
                  }];
    }
}

- (void) showWalletView {
    [[UserDataHelper shareInstance] getAuthToken:^(NSString * _Nullable token, NSError * _Nullable error) {
        FCLinkConfigure* link = [self getLinkTopup];
        NSString* newUrl = [NSString stringWithFormat:@"%@?deviceId=%@&accessToken=%@",link.url, [self getDeviceId], token];
        FCNewWebViewController* vc = [[FCNewWebViewController alloc] init];
        vc.title = link.name;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             [vc loadWebview:newUrl];
                         }];
    }];
}

#pragma mark - TableView Delegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kCellCashIndex) {
        if (_methodSelected == PaymentMethodCash) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if (indexPath.row == kCellWalletIndex) {
        if (_methodSelected == PaymentMethodVATOPay) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    if (indexPath.row == kCellCashIndex) {
        self.methodSelected = PaymentMethodCash;
        self.cellMethodVATOPay.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == kCellWalletIndex) {
        self.cellMethodCash.accessoryType = UITableViewCellAccessoryNone;
        self.methodSelected = PaymentMethodVATOPay;
//        [self checkBalance];
    }
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}


@end
