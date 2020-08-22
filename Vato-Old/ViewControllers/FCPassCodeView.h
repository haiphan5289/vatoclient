//
//  FCRegisterStationView.h
//  FaceCar
//
//  Created by facecar on 9/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PasscodeView/PasscodeView.h>

typedef enum : NSUInteger {
    PasscodeTypeClose = 0,
    PasscodeTypeBack = 1

} PasscodeType;

@interface FCPassCodeView : UIView

- (FCPassCodeView*) initView: (UIViewController*) vc;
- (void) setupView: (PasscodeType) type;

@property (strong, nonatomic) NSString* passcode;
@property (assign, nonatomic) NSInteger viewType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consHeight;
@property (weak, nonatomic) IBOutlet UIView *bgview;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet PasscodeView *passcodeView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblFogotPass;
@property (weak, nonatomic) IBOutlet UIButton *btnFogotPass;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

- (void) showKeyboard;
- (void) removePasscode;
- (void) hideKeyboard;

@end
