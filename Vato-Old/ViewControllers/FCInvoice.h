//
//  FCInvoice.h
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCInvoice : FCModel

@property (assign, nonatomic) long long id;
@property (assign, nonatomic) long long transactionDate;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* referId;
@property (assign, nonatomic) NSInteger beforeCash;
@property (assign, nonatomic) NSInteger beforeCoin;
@property (assign, nonatomic) NSInteger afterCash;
@property (assign, nonatomic) NSInteger afterCoin;
@property (assign, nonatomic) NSInteger amountCash;
@property (assign, nonatomic) NSInteger amountCoin;
@property (assign, nonatomic) NSInteger amountCoinP;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) NSInteger status;
@property (assign, nonatomic) NSInteger accountFrom;
@property (assign, nonatomic) NSInteger accountTo;

@end
