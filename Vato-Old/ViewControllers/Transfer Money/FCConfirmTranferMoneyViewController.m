//
//  FCConfirmTranferMoneyViewController.m
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCConfirmTranferMoneyViewController.h"
#import "FCPassCodeView.h"
#import "FCTransferMoneyViewModel.h"

extern NSString *const topupSuccessNotification;
@interface FCConfirmTranferMoneyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblCash;
@property (weak, nonatomic) IBOutlet UILabel *lblReceverName;
@property (weak, nonatomic) IBOutlet UILabel *lblReveiverPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UILabel *lblChannel;

@end

@implementation FCConfirmTranferMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblAmount.text = [self formatPrice:self.transfMoney.cashAmount withSeperator:@"."];
    self.lblCash.text = [self formatPrice:self.homeViewModel.client.user.cash];
    
    if (self.channel == VATO) {
        self.lblReceverName.text = self.userInfo.fullName;
        self.lblReveiverPhone.text = self.transfMoney.phone;
        self.lblChannel.text = @"VATOPay";
    }
    else if (self.channel == ZALOPAY) {
        self.lblReceverName.text = [self.homeViewModel.client.user getDisplayName];
        self.lblReveiverPhone.text = self.homeViewModel.client.user.phone;
        self.lblChannel.text = @"ZaloPay";
    }
    
    [self showPasscodeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)confirmClicked:(id)sender {
    [self showPasscodeView];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showPasscodeView {
    FCPassCodeView* view = [[FCPassCodeView alloc] initView:self];
    view.consHeight.constant = 400;
    view.lblTitle.text = @"Nhập mật khẩu thanh toán";
    view.lblFogotPass.hidden = YES;
    view.btnFogotPass.hidden = YES;
    [view setupView:PasscodeTypeClose];
    [self.navigationController.view addSubview:view];
    
    [RACObserve(view, passcode) subscribeNext:^(NSString* pass) {
        if (pass.length == 6) {
            self.transfMoney.pin = pass;
            if (self.channel == VATO) {
                [self transferMoneyToVivu: view];
            }
            else if (self.channel == ZALOPAY) {
                [self transferMoneyToZalopay: view];
            }
        }
    }];
}

- (void) transferMoneyToZalopay:(FCPassCodeView*) view {
    [IndicatorUtils show];
    [[FCTransferMoneyViewModel shareInstance] apiZalopayWithdraw:self.transfMoney.pin amount:self.transfMoney.cashAmount block:^(BOOL success) {
        [IndicatorUtils dissmiss];
        [view removeFromSuperview];
        if (success) {
        }
    }];
}

- (void) transferMoneyToVivu:(FCPassCodeView*) view {
    [IndicatorUtils show];
    [[FCTransferMoneyViewModel shareInstance] apiTranferMoney:self.transfMoney
                                                        block:^(BOOL success) {
                                                            [IndicatorUtils dissmiss];
                                                            [view removeFromSuperview];
                                                            if (success) {
                                                                [self notifySuccess];
                                                            }
                                                        }];
}

- (void) notifySuccess {
    [[NSNotificationCenter defaultCenter] postNotificationName:topupSuccessNotification
                                                        object:nil];
    __weak typeof(self) weakSelf = self;
    [AlertVC showAlertObjcOn: self
                       title:@"Chúc mừng"
                     message:[NSString stringWithFormat:@"Bạn đã chuyển thành công %@ đến tài khoản %@", [self formatPrice: self.transfMoney.cashAmount], self.transfMoney.phone]
                    actionOk:@"Đóng"
                actionCancel:nil
                  callbackOK:^{
                      [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                  }
              callbackCancel:^{
              }];
}



#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    return 30;
}

@end
