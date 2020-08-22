//
//  FCImageView.m
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCImageView.h"


@implementation FCImageView


- (void) awakeFromNib {
    [super awakeFromNib];
    
    if (self.isCircle) {
        [self circleView:[UIColor clearColor]];
    }
    else {
        [self borderViewWithColor:[UIColor clearColor] andRadius:self.cornerRadius];
    }
}

- (void) setImageWithUrl: (NSString*) url {
    NSURL* requestUrl = [NSURL URLWithString:url];
    if (requestUrl != nil) {
        [self sd_setImageWithURL:requestUrl placeholderImage:[UIImage imageNamed:@"avatar-holder"]];
    } else {
        self.image = [UIImage imageNamed:@"avatar-holder"];
    }
}

- (void) setImageWithUrl: (NSString*) url
                  holder: (UIImage*) holder {
    NSURL* requestUrl = [NSURL URLWithString:url];
    if (requestUrl != nil) {
        [self sd_setImageWithURL:requestUrl placeholderImage:holder];
    } else {
        self.image = holder;
    }
}

@end
