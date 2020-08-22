//
//  FCGiftTableViewCell.m
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGiftTableViewCell.h"
#import "UIView+Helper.h"
#import "NSString+Helper.h"
#import "UIView+Border.h"

@implementation FCGiftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) loadGift:(FCGift *)gift {
    [self.bgView borderViewWithColor:[UIColor clearColor] andRadius:5];
 
//    [self.imageCover setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[gift.banner_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]
//                           placeholderImage:[UIImage imageNamed:@"promo-cover"]
//                                    success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                        self.imageCover.image = image;
//                                        
//                                    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//                                        
//                                    }];
    [self.lblTitle setText:gift.name];
    NSString* time = @"Còn";
    NSInteger dur = (gift.end - [self getCurrentTimeStamp])/1000;
    if (dur > 0) {
        NSInteger day = dur / (3600*24);
        NSInteger hour = (dur % (3600*24))/3600;
        if (day > 0) {
            time = [time stringByAppendingString:[NSString stringWithFormat:@" %ld ngày", day]];
        }
        if (hour > 0) {
            time = [time stringByAppendingString:[NSString stringWithFormat:@" %ld giờ", hour]];
        }
        [self.lblTimeRemine setText:time];
    }
    else {
        [self.lblTimeRemine setText:@"Đã hết hạn"];
    }
    
}

@end
