//
//  FCInvoiceTableViewCell.m
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCInvoiceTableViewCell.h"
#import "UIView+Border.h"
#import "UserDataHelper.h"

@implementation FCInvoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.lblTransType borderViewWithColor:[UIColor clearColor] andRadius:3];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) loadData:(FCInvoice *)invoice {
    [self.invoiceId setText:invoice.description];
    [self.bgImage circleView];
    
    NSInteger value = invoice.amountCash + invoice.amountCoin + invoice.amountCoinP;
    NSInteger after = invoice.afterCash + invoice.afterCoin;
    
    [self.lblAfter setText:[NSString stringWithFormat:@"%@ %@", localizedFor(@"Số dư cuối:"), [self formatPrice:after]]];
    [self.lblDate setText:[self getTimeString:invoice.transactionDate withFormat:@"HH:mm\ndd/MM"]];
    
    if(invoice.status == TRANS_CANCELED){
        self.lblTransType.text = localizedFor(@"Thất bại");
        self.lblTransType.textColor = [UIColor redColor];
    }
    if(invoice.status == TRANS_PENDING){
        self.lblTransType.text = localizedFor(@"Chờ duyệt");
        self.lblTransType.textColor = [UIColor redColor];
    }
    else {
        self.lblTransType.text = localizedFor(@"Thành công");
        self.lblTransType.textColor = DARK_GREEN;
    }
    
    if (invoice.accountTo == [[UserDataHelper shareInstance] getCurrentUser].user.id) {
        [self.lblValue setText:[NSString stringWithFormat:@"+%@", [self formatPrice:value]]];
        [self.img setImage:[UIImage imageNamed:@"cashin"]];
    }
    else {
        [self.lblValue setText:[NSString stringWithFormat:@"-%@", [self formatPrice:value]]];
        [self.img setImage:[UIImage imageNamed:@"cashout"]];
    }
}

@end
