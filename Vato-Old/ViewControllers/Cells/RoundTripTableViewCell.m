//
//  RoundTripTableViewCell.m
//  FaceCar
//
//  Created by Vu Dang on 6/23/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "RoundTripTableViewCell.h"

@implementation RoundTripTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) loadData:(FCRoundTrip *)roundTrip {
    self.lblStart.text = [NSString stringWithFormat:@"Xuất phát: %@",roundTrip.startPlace.name];
    self.lblEnd.text = [NSString stringWithFormat:@"Điểm đến: %@", roundTrip.endPlace.name];
    self.lblTimeStart.text = [NSString stringWithFormat:@"Khởi hành: %@",[self getTimeString:roundTrip.timeStart]];
}

@end
