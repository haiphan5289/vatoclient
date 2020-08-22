//
//  FCInputPhoneViewController.h
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCTransferMoney.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@interface FCInputPhoneViewController : UIViewController

@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCTransferMoney* transfMoney;
@property (assign, nonatomic) NSInteger channel; // kenh rut tien (vivu, zalo,..)

@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *tfPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@end
