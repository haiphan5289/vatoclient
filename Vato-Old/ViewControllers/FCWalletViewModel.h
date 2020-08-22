//
//  FCWalletViewModel.h
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zpdk/zpdk/ZaloPaySDK.h>

@interface FCWalletViewModel : NSObject

@property (assign, nonatomic) NSInteger amountForDeposit;
@property (assign, nonatomic) ZPErrorCode depositResult;
@property (assign, nonatomic) BOOL bplusResult;

- (instancetype) initViewModel: (UIViewController*) vc;
- (void) apiGetMyBalance: (void (^) (FCBalance* balance)) block;
- (void) apiGetOder;
- (void) apiGetBplusOrder;

@end
