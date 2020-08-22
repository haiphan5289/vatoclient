//
//  FCInvoiceDetailViewController.m
//  FaceCar
//
//  Created by facecar on 6/7/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCInvoiceDetailViewController.h"
#import "UserDataHelper.h"

@interface FCInvoiceDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;

@end

@implementation FCInvoiceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.invoice) {
        [self loadData];
    }
    else {
        [IndicatorUtils show];
        [[APIHelper shareInstance] get:API_GET_TRANS_DETAIL
                                params:@{@"id":@(self.invoiceId)}
                              complete:^(FCResponse *response, NSError *error) {
                                  [IndicatorUtils dissmiss];
                                  if (response.status == APIStatusOK) {
                                      FCInvoice* invoice = [[FCInvoice alloc] initWithDictionary:response.data
                                                                                           error:nil];
                                      if (invoice) {
                                          self.invoice = invoice;
                                          [self loadData];
                                      }
                                  }
                              }];
    }
}

- (void) btnLeftClicked: (id) sender {
    if (!self.isPushedView) {
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) loadData {
    NSInteger userid = [[UserDataHelper shareInstance] getCurrentUser].user.id;
    if (_invoice.type == TRANSFER) {
        if (_invoice.accountFrom == userid)
            self.lblTitle.text = [localizedFor(@"Chuyển tiền") uppercaseString];
        else
            self.lblTitle.text = [localizedFor(@"Nhận tiền") uppercaseString];
    }
    else if (_invoice.type == BLOCK ||
             _invoice.type == GET_MONEY ||
             _invoice.type == GET_EXTRA ) {
        self.lblTitle.text = [localizedFor(@"Thu phí") uppercaseString];
    }
    else if (_invoice.type == ZALOPAY_TOPUP) {
        self.lblTitle.text = [localizedFor(@"Nạp tiền") uppercaseString];
    }
    
    NSInteger amount = _invoice.amountCash + _invoice.amountCoin + _invoice.amountCoinP;
    if (_invoice.accountFrom == userid) {
        self.lblAmount.text = [NSString stringWithFormat:@"-%@đ", [self formatPrice:amount withSeperator:@","]];
    }
    else {
        self.lblAmount.text = [NSString stringWithFormat:@"+%@đ", [self formatPrice:amount withSeperator:@","]];
    }
    
    self.lblDate.text = [self getTimeString:_invoice.transactionDate];
    self.lblIdentifier.text = [NSString stringWithFormat:@"%lld", _invoice.id];
    self.lblDesc.text = _invoice.description;
}

@end
