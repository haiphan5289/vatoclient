//
//  FCNotifyViewController.h
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCHomeViewModel;
@class FCNotifyPageViewController;
@class FCNotifyTableViewCell;

@protocol FCNotifyViewControllerDelegate <NSObject>
- (void) onSelectedNotification:(FCNotification*) data;
@end

@interface FCNotifyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCNotifyPageViewController* pageVC;
@property (weak, nonatomic) id<FCNotifyViewControllerDelegate> delegate;

- (instancetype) initView;

@end
