//
//  FCInputMoneyViewController.h
//  FC
//
//  Created by facecar on 10/27/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCTransferMoney.h"
#import "FCHomeViewModel.h"
#import "FCUserInfo.h"

@interface FCInputMoneyViewController : UIViewController

@property (strong, nonatomic) FCTransferMoney* transfMoney;
@property (strong, nonatomic) FCUserInfo* userInfo;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

@property (assign, nonatomic) NSInteger channel; // kenh rut tien (vivu, zalo,..)
@end
