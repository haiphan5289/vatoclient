//
//  FCShipConfirmViewController.h
//  FaceCar
//
//  Created by facecar on 3/7/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCShipViewModel.h"

@interface FCShipConfirmViewController : UITableViewController
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (strong, nonatomic) FCShipViewModel* viewModel;
@end
