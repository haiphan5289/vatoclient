//
//  MenusTableViewController.h
//  FaceCar
//
//  Created by Vu Dang on 6/1/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
@class FCNotification;

typedef enum : NSUInteger {
    Wallet,
    Promotion,
    HistoryBook,
    FavoritePlace,
    Block,
    Invite,
    Notify,
    Supporter,
    Favorite // old list history place much order 
} FCMainMenu;

@protocol FCMenuViewControllerDelegate <NSObject>
- (void) onSelectedMenu: (FCMainMenu) menu;
- (void) onSelectedNotification:(FCNotification*__nullable) data;
@end

@interface MenusTableViewController : UITableViewController

@property (strong, nonatomic) FCHomeViewModel* _Nullable homeViewModel;
@property (weak, nonatomic) id<FCMenuViewControllerDelegate> _Nullable delegate;

- (void) bindingData;

@end
