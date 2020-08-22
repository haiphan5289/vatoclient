//
//  FCUpdateViewController.m
//  FaceCar
//
//  Created by facecar on 6/18/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCUpdateViewController.h"
#import "JVFloatLabeledTextField.h"

@interface FCUpdateViewController ()
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfInput;
@property (weak, nonatomic) IBOutlet FCButton *btnUpdate;
@property (weak, nonatomic) IBOutlet UILabel *lblErrorMessage;

@end

@implementation FCUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == UpdateViewTypeEmail) {
        self.tfInput.placeholder = @"Email";
        self.tfInput.keyboardType = UIKeyboardTypeEmailAddress;
        [self.btnUpdate setTitle:[localizedFor(@"Cập nhật email") uppercaseString] forState:UIControlStateNormal];
    }
    else if (self.type == UpdateViewTypeNickName) {
        self.tfInput.placeholder = @"Nickname";
        [self.btnUpdate setTitle:[localizedFor(@"Cập nhật nickname") uppercaseString] forState:UIControlStateNormal];
    }
    else if (self.type == UpdateViewTypeFullName) {
        self.tfInput.placeholder = localizedFor(@"Họ và tên");
        [self.btnUpdate setTitle:[localizedFor(@"Cập nhật họ tên") uppercaseString] forState:UIControlStateNormal];
    }
    self.tfInput.text = self.currentValue;
}

- (IBAction)textfieldChanged:(id)sender {
    self.lblErrorMessage.hidden = YES;
}

- (IBAction)closeClicked:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)updateClicked:(id)sender {
    NSString* inputStr = [self.tfInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (self.type == UpdateViewTypeEmail) {
        inputStr = [inputStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (![self validEmail:inputStr]) {
            self.lblErrorMessage.text = localizedFor(@"Email không hợp lệ");
            self.lblErrorMessage.hidden = NO;
        }
        else {
            NSString* email = inputStr;
            [IndicatorUtils show];
            [[FirebaseHelper shareInstance] updateUserEmail:email complete:^(NSError *err) {
                [IndicatorUtils dissmiss];
                self.result = email;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdatedNotification" object:nil];
                [self closeClicked:nil];
            }];
        }
    }
    else if (self.type == UpdateViewTypeNickName) {
        if (inputStr.length > 40 || inputStr.length < 5) {
            self.lblErrorMessage.text = localizedFor(@"Nickname phải có ít nhất 5 ký tự và nhiều nhất 40 ký tự");
            self.lblErrorMessage.hidden = NO;
        }
        else {
            NSString* nickname = inputStr;
            [[FirebaseHelper shareInstance] updateNickname:nickname];
            self.result = nickname;
            [self closeClicked:nil];
        }
    }
    else if (self.type == UpdateViewTypeFullName) {
        if (inputStr.length > 40 || inputStr.length < 5) {
            self.lblErrorMessage.text = localizedFor(@"Họ tên phải có ít nhất 5 ký tự và nhiều nhất 40 ký tự");
            self.lblErrorMessage.hidden = NO;
        }
        else {
            NSString* nickname = inputStr;
            [[FirebaseHelper shareInstance] updateFullname:nickname];
            self.result = nickname;
            [self closeClicked:nil];
        }
    }
}

@end
