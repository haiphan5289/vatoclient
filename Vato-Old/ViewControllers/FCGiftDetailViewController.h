//
//  FCGiftDetailViewController.h
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCGift.h"
#import "FCHomeViewModel.h"
#import "FCStationEvent.h"
#import "FCFareManifest.h"

@interface FCGiftDetailViewController : UITableViewController

@property (strong, nonatomic) FCFareManifest* gift;
@property (strong, nonatomic) FCStationEvent* stationEvents; // list event for station
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (assign, nonatomic) NSInteger eventId; // for get detail

- (instancetype) initView;

@end
