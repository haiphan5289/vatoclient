//
//  FCTripHistoryViewController.h
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    TripHistoryBooking,
    TripHistoryExpress,
} TripHistoryType;

@interface FCTripHistoryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (instancetype) initView;
- (instancetype)initWithType:(TripHistoryType)type;
@end
