//
//  RoundTripTableViewCell.h
//  FaceCar
//
//  Created by Vu Dang on 6/23/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundTripTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblStart;
@property (strong, nonatomic) IBOutlet UILabel *lblEnd;
@property (strong, nonatomic) IBOutlet UILabel *lblTimeStart;

- (void) loadData:(FCRoundTrip*) roundTrip;
@end
