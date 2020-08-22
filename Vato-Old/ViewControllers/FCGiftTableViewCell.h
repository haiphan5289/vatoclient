//
//  FCGiftTableViewCell.h
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCGift.h"

@interface FCGiftTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageCover;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeRemine;
@property (weak, nonatomic) IBOutlet UIView *bgView;

- (void) loadGift: (FCGift*) gift;

@end
