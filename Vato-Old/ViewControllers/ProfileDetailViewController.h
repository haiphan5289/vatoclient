//
//  ProfileViewController.h
//  FaceCar
//
//  Created by Vu Dang on 6/1/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const profileUpdatedNotification;
extern NSString *const profileUpdatedAvatarNotification;
@protocol ProfileDetailDelegate <NSObject>
- (void) profileSignOut;
@end

@class FCHomeViewModel;
@interface ProfileDetailViewController : UITableViewController
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (weak, nonatomic) id<ProfileDetailDelegate> delegate;
@end
