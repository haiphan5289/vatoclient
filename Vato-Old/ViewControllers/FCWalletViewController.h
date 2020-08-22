//
//  AmountViewController.h
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FCWalletViewModel;
@class FCHomeViewModel;

@protocol FCWalletDelegate
- (void) onReceiveBalance:(double) cash coin:(double) coin;
@end

@interface FCWalletViewController : UIViewController

@property (strong, nonatomic) FCWalletViewModel* walletViewModel;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (weak, nonatomic) id<FCWalletDelegate> delegate;

- (instancetype) initView: (FCHomeViewModel*) homeModel;
@end
