//
//  NSString+MD5.m
//  FC
//
//  Created by Son Dinh on 4/29/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "UILabel+Helper.h"

@implementation UILabel (Helper)

- (void) crossLable {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@2
                            range:NSMakeRange(0, [attributeString length])];
    self.attributedText = attributeString;
}

@end
