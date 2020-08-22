//
//  FCTripManagerTableViewCell.h
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCTripHistory.h"

@interface FCTripManagerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet FCLabel *lblPaymentOption;
@property (weak, nonatomic) IBOutlet FCLabel *lblPromotion;

- (void) loadData: (FCTripHistory*) trip;

@end
