//
//  FCHomeViewController.h
//  FaceCar
//
//  Created by facecar on 12/4/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

@interface FCHomeViewController : UIViewController

@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (void) clearHome;
- (void) forceAnimationReloadMenus;
- (void) onBookClicked;

@end
