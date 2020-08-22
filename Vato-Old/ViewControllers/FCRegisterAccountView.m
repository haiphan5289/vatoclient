//
//  FCRegisterAccountView.m
//  FaceCar
//
//  Created by facecar on 11/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCRegisterAccountView.h"
#import "NSString+Helper.h"
#import "JVFloatLabeledTextField.h"

@interface FCRegisterAccountView ()
@property (weak, nonatomic) IBOutlet UITextField *tfFullName;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfNickName;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@end


@implementation FCRegisterAccountView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self.tfFullName becomeFirstResponder];
    
    RAC(self.btnNext, enabled) = [RACSignal combineLatest:@[self.tfFullName.rac_textSignal,
                                                            self.tfNickName.rac_textSignal]
                                                   reduce:^(NSString* f, NSString* n){
                                                       NSString* fullname = [f stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                       NSString* nickname = [n stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                       
                                                       if ([fullname wordCount] < 2) {
                                                           self.lblError.text = @"Nhập đầy đủ họ tên của bạn! (tối thiểu 2 chữ)";
                                                       }
                                                       else if (fullname.length > 40 || fullname.length < 5) {
                                                           self.lblError.text = @"Họ tên có ít nhất 5 ký tự và nhiều nhất 40 ký tự";
                                                       }
                                                       else if (nickname.length > 40 || nickname.length < 5) {
                                                           self.lblError.text = @"Nickname có ít nhất 5 ký tự và nhiều nhất 40 ký tự";
                                                       }
                                                       else {
                                                           self.lblError.text = EMPTY;
                                                       }
                                                       
                                                       return @(self.lblError.text.length == 0);
                                                   }];
}

- (void) showNext {
    [super showNext];
    
    if (self.loginViewModel.client.user.fullName.length > 0) {
        self.tfFullName.text = self.loginViewModel.client.user.fullName;
        self.btnNext.enabled = YES;
    }
}

- (IBAction)backPressed:(id)sender {
    [self hide];
}

- (IBAction)nextClicked:(id)sender {
    NSString* fullname = [self.tfFullName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* nickname = [self.tfNickName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [IndicatorUtils showWithMessage:@"Đang kiểm tra ..."];
    self.loginViewModel.client.user.fullName = fullname;
    self.loginViewModel.client.user.nickname = nickname;
    [self.loginViewModel createUserInfo:^(NSError* error) {
        [IndicatorUtils dissmiss];
        
        if (!error) {
            self.loginViewModel.resultCode = FCLoginResultCodeRegisterAccountCompelted;
        }
        else {
            self.loginViewModel.resultCode = FCLoginResultCodeCreateUserInfoFailed;
        }
    }];
}


@end
