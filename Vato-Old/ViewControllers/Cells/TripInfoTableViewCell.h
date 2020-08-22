//
//  TripInfoTableViewCell.h
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripInfoTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *startAddress;
@property (strong, nonatomic) IBOutlet UILabel *endAddress;
@property (strong, nonatomic) IBOutlet UILabel *created;

- (void) loadData: (FCTrip*) trip;

@end
