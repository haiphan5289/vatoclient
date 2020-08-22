//
//  FCGiftViewController.h
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCNotifyPageViewController.h"
#import "FCStationEvent.h"

@interface FCGiftViewController : UIViewController

@property (strong, nonatomic) FCStationEvent* stationEvents; // list event for station
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCNotifyPageViewController* pageVC;

- (instancetype) initView;
- (instancetype) initViewWithNavi;

@end
