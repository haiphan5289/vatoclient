//
//  TripInfoTableViewCell.m
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "TripInfoTableViewCell.h"

@implementation TripInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void) loadData: (FCTrip*) trip {
    self.startAddress.text = trip.start.name;
    self.endAddress.text = trip.end.name;
    self.created.text = [self getTimeString:trip.created];
}

@end
