//
//  FCRegisterStationView.m
//  FaceCar
//
//  Created by facecar on 9/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCPassCodeView.h"
#import "APIHelper.h"
#import "FacecarNavigationViewController.h"

@interface FCPassCodeView () <UITextFieldDelegate>
@end

@implementation FCPassCodeView
{
    UIViewController* supperVC;
}

- (FCPassCodeView*) initView: (UIViewController*) vc {
    self = [[[NSBundle mainBundle] loadNibNamed:@"FCPassCodeView" owner:self options:nil] firstObject];
    supperVC = vc;
    [self.textField becomeFirstResponder];
        self.textField.delegate = self;
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if ([self isPhoneX]) {
        self.consHeight.constant = 500.0f;
    }
    else {
        self.consHeight.constant = 430.0f;
    }
    _lblTitle.text = localizedFor(_lblTitle.text);
    _lblFogotPass.text = localizedFor(_lblFogotPass.text);
    [_btnFogotPass setTitle:localizedFor(@"Gọi 19006667") forState:UIControlStateNormal];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length > self.passcodeView.length) {
        self.textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                      withString:@""];
        return NO;
    }
    return YES;
}


- (void) onKeyboardWillHide: (id) sender {
    
}
- (void) showKeyboard {
    [self.textField becomeFirstResponder];
}

- (void) hideKeyboard {
    [self.textField resignFirstResponder];
}

- (IBAction)textfiledChanged:(UITextField*)textField {
    NSString* fullString = textField.text;

    [self.passcodeView setProgress:fullString.length];
    
    if (self.passcodeView.progress == self.passcodeView.length) {
        [self finishedEnterPasscode:fullString];
    }
}

- (void) setupView:(PasscodeType)type {
    if (type == PasscodeTypeClose) {
        self.bgview.alpha = 0.7;
        self.btnClose.hidden = NO;
        self.btnBack.hidden = YES;
    }
    else {
            self.bgview.alpha = 0.0;
            self.btnClose.hidden = YES;
            self.btnBack.hidden = NO;
    }
}


- (IBAction)onContactFogetClicked:(id)sender {

}

- (IBAction)closeView:(id)sender {
    [self resignFirstResponder];
    [self removeFromSuperview];
}

- (IBAction)backClicked:(id)sender {
    [self removeFromSuperview];
}

-(IBAction)bgTouch:(id)sender {
    [self closeView:sender];
}

- (void) finishedEnterPasscode: (NSString*) pass {
    self.passcode = pass;
}
- (void) removePasscode {
    self.passcodeView.progress = 0;
    self.textField.text = @"";
}

@end
