//
//  FCGiftViewModel.h
//  FaceCar
//
//  Created by facecar on 10/3/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCHomeViewModel.h"
#import "FCStationEvent.h"

@interface FCGiftViewModel : NSObject

- (instancetype) initWithRootVC: (UIViewController *)rootVc
                  homeViewModel: (FCHomeViewModel*) homeModel;

- (void) getGift: (NSArray*) requireTypes
        complete: (void (^) (NSMutableArray*)) block;

// tracking open
- (long long) getLastimeShowGiftEvent;
- (void) setLasttimeShowGiftEvent: (long long) timestamp;

@end
