//
//  CarGroupTableViewCell.h
//  FaceCar
//
//  Created by Vu Dang on 6/11/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarGroupTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *name;

- (void) loadData: (FCMCarGroup*) carGroup;

@end
