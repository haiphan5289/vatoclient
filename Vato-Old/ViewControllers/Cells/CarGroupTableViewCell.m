//
//  CarGroupTableViewCell.m
//  FaceCar
//
//  Created by Vu Dang on 6/11/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "CarGroupTableViewCell.h"

@implementation CarGroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void) loadData: (FCMCarGroup*) carGroup {
    self.name.text = carGroup.name;
}

@end
