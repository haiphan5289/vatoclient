//
//  FCTextField.m
//  FaceCar
//
//  Created by facecar on 12/14/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTextField.h"

@implementation FCTextField {
    UIEdgeInsets _inset;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    _inset = UIEdgeInsetsZero;
    _inset.left = _padding;
    _inset.right = _padding;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _inset)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, _inset)];
}


@end
