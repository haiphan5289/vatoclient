//
//  FCPasscodeViewController.m
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPasscodeViewController.h"
#import <PasscodeView/PasscodeView.h>
#import "APIHelper.h"

@interface FCPasscodeViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet PasscodeView *passcodeView;

@end

@implementation FCPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _lblTitle.text = [localizedFor(@"Tạo mật khẩu thanh toán") uppercaseString];
    _lblDesc.text = localizedFor(@"Tạo mật khẩu để thực hiện các giao dịch nạp, chuyển và rút tiền.");

    self.navigationItem.title = localizedFor(@"Tạo mật khẩu");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.lblError.hidden = YES;
    self.textField.delegate = self;
    [self.textField becomeFirstResponder];
    
    if (self.currentPasscode.length > 0) {
        self.lblTitle.text = [localizedFor(@"Xác thực mật khẩu") uppercaseString];
        self.lblDesc.text = localizedFor(@"Mật khẩu phải được giữ bí mật để thực hiện các giao dịch rút và chuyển tiền.");
        self.lblDesc.textAlignment = NSTextAlignmentCenter;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
    self.textField.text = nil;
}

- (void) onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString* fullString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    if ([string isEqualToString:@""]) {
        fullString = [fullString substringToIndex:[fullString length] - 1];
    }
    [self.passcodeView setProgress:fullString.length];
    
    if (self.passcodeView.progress == self.passcodeView.length) {
        if (self.currentPasscode.length == 0) {
            [self loadConfirmPasscode:fullString];
        }
        else {
            if (![self.currentPasscode isEqualToString:fullString]) {
                self.lblError.hidden = NO;
                self.lblError.text = localizedFor(@"Mật khẩu thanh toán chưa trùng khớp!");
            }
            else {
                self.lblError.hidden = YES;
                [self apiCreatePIN];
            }
        }
    }
    
    
    return YES;
}

- (void) loadConfirmPasscode: (NSString*) code {
    FCPasscodeViewController* passView = [[FCPasscodeViewController alloc] initWithNibName:@"FCPasscodeViewController"
                                                                                    bundle:nil];
    
    [passView setCurrentPasscode:code];
    [self.navigationController pushViewController:passView animated:YES];
}

- (void) apiCreatePIN {
    [IndicatorUtils show];
    NSDictionary* body = @{@"pin": self.currentPasscode};
    [[APIHelper shareInstance] post:API_CREATE_PIN body:body complete:^(FCResponse *response, NSError *error) {
        [IndicatorUtils dissmiss];
        if (response.status == APIStatusOK) {
            BOOL ok = [(NSNumber*) response.data boolValue];
            if (ok) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CREATE_PIN_COMPLETED
                                                                    object:nil];
                
                __weak typeof(self) weakSelf = self;
                [AlertVC showAlertObjcOn:self
                                   title:localizedFor(@"Thông báo")
                                 message:localizedFor(@"Chúc mừng bạn đã tạo mật khẩu thanh toán thành công.")
                                actionOk:localizedFor(@"Đóng")
                            actionCancel:nil
                              callbackOK:^{
                                  [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                              }
                          callbackCancel:^{
                          }];
            }
        }
    }];
}

@end
