//
//  FCHomeSubMenuView.h
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

typedef enum : NSUInteger {
    FCHomeSubMenuBookNow = 1,
    FCHomeSubMenuFavDriver = 2,
    FCHomeSubMenuPromotion = 3,
    FCHomeSubMenuTaxi = 4
} FCHomeSubMenuType;

@interface FCHomeSubMenuView : FCView

@property (weak, nonatomic) FCHomeViewModel* homeViewModel;

- (void) setMenuClickCallback: (void (^) (NSInteger index)) block;

- (void) addItems: (NSArray*) items;

@end
