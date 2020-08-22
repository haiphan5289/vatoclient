//
//  FCNotifyTableViewCell.m
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCNotifyTableViewCell.h"
#import "UIView+Border.h"

@implementation FCNotifyTableViewCell

- (void) loadData:(FCNotification*) notify {
    if (notify.type == 100 || notify.type == 110) {
        _logo.image = [UIImage imageNamed:@"ic_promotion"];
    } else {
        _logo.image = [UIImage imageNamed:@"ic_news"];
    }
    [self.lblTitle setText:notify.title];
    [self.lblBody setText:notify.body];
    [self.lblCreated setText:[self getTimeString:notify.createdAt]];
}

- (void) loadNewStatus: (FCNotification*) notify {
//    [self setBackgroundColor:[UIColor whiteColor]];
}

@end
