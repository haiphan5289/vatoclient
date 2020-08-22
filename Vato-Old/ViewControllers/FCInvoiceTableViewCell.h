//
//  FCInvoiceTableViewCell.h
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCInvoice.h"

@interface FCInvoiceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *invoiceId;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UILabel *lblAfter;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTransType;
@property (weak, nonatomic) IBOutlet UIView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *img;


- (void) loadData: (FCInvoice*) invoice;

@end
