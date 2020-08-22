//
//  FCInvoiceDetailViewController.h
//  FaceCar
//
//  Created by facecar on 6/7/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCInvoice.h"

@interface FCInvoiceDetailViewController : FCViewController
@property (strong, nonatomic) FCInvoice* invoice;
@property (assign, nonatomic) NSInteger invoiceId;
@end
