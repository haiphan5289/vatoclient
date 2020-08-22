    //
//  FCWalletViewModel.m
//  FC
//
//  Created by facecar on 6/13/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCWalletViewModel.h"
#import "APIHelper.h"
#import "FCBplusOrder.h"
#import "UserDataHelper.h"

#if (TARGET_OS_SIMULATOR == NO && TARGET_OS_IOS == NO)
#import <BPlusMiniSDK/BPlusMiniSDK.h>
#endif

@interface FCWalletViewModel () <ZaloPaySDKDelegate>
@property (weak, nonatomic) UIViewController* viewController;

@end

@implementation FCWalletViewModel

- (instancetype) initViewModel: (UIViewController*) vc {
    self = [super init];
    self.viewController = vc;
    
    return self;
}

- (void) apiGetMyBalance:(void (^)(FCBalance *))block {
    [[APICall shareInstance] apiGetBalance:^(FCBalance *balance) {
        if (block) {
            block(balance);
        }
    }];
}

#pragma mark - Zalo Pay
- (void) apiGetOder {
    [IndicatorUtils show];
    NSDictionary* params = [NSDictionary dictionaryWithObjects:@[@(self.amountForDeposit), @"Nộp tiền cho lái xe"]
                                                       forKeys:@[@"amount", @"desc"]];
    [[APIHelper shareInstance] post:API_GET_ZALO_ORDER
                               body:params
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                           }];
}

- (void) zaloPayOrder: (NSString*) order {
    if (order.length > 0) {
        [ZaloPaySDK sharedInstance].delegate = self;
        [[ZaloPaySDK sharedInstance] payOrder:order];
    }
    else {
        self.depositResult = ZPErrorCode_Fail;
    }
}

- (void) zalopayCompleteWithErrorCode:(ZPErrorCode)errorCode transactionId:(NSString *)transactionId {
    self.depositResult = errorCode;
}

#pragma mark - BankPlus

- (void) apiGetBplusOrder {
    [IndicatorUtils show];
    NSDictionary* body = @{@"amount":@(self.amountForDeposit),
                           @"description":@"Nộp tiền"};
    [[APIHelper shareInstance] post:API_GET_BPLUS_ORDER
                               body:body
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                           }];
}

- (void) processBplusOrder: (FCBplusOrder*) orderInfo {
    if (!orderInfo) {
        return;
    }
   
#if (TARGET_OS_SIMULATOR == NO && TARGET_OS_IOS == NO)
    NSArray *comp = [orderInfo.key componentsSeparatedByString:@"~"];
    NSString* merchantCode = [comp objectAtIndex:0];    
    NSString* merchantKey = [comp objectAtIndex:1];
    NSString* accessCode = [comp objectAtIndex:2];
   
    [BPlusSDK sharedManager].merchantSecureKey = merchantKey;
    [BPlusSDK sharedManager].accessCode = accessCode;
    [BPlusSDK sharedManager].merchantCode = merchantCode;
    [BPlusSDK sharedManager].isSandbox = NO;
    [BPlusSDK sharedManager].timeout = 30;
    [BPlusSDK sharedManager].presentingViewController = self.viewController;
    
    NSDictionary *payInfo = @{@"serviceName":orderInfo.service_name,
                              @"content":orderInfo.description,
                              @"orderId":[NSString stringWithFormat:@"%ld", (long) orderInfo.order_id],
                              @"amount":[NSString stringWithFormat:@"%ld", (long) orderInfo.amount]};
    
    [[BPlusSDK sharedManager] payMerchantWithInfoComplete:payInfo complete:^(BOOL isSuccess, NSInteger status) {
        self.bplusResult = status == BPSDK_INIT_STATUS_SUCCESSED;
        if (isSuccess)
            NSLog(@"Thanh toán thành công stt: %ld", status);
        else
            NSLog(@"Thanh toán thất bại stt: %ld", status);
    }];
#endif
}

@end
