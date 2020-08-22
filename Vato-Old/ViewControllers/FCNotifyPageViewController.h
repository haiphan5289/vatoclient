//
//  FCNotifyPageViewController.h
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

@interface FCNotifyPageViewController : UIViewController

@property (weak, nonatomic) IBOutlet FCProgressView *progressBar;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;

- (instancetype) initView;

@end
