//
//  DriverDetailViewController.h
//  FaceCar
//
//  Created by Vu Dang on 6/4/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

@interface DriverDetailViewController : UITableViewController

@property(nonatomic, strong) FCFavorite* favorite;
@property(nonatomic, strong) FCHomeViewModel* homeViewModel;
@property(nonatomic, assign) FavViewType type;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblPhone;

@property (weak, nonatomic) IBOutlet UIButton *btnAddnewOne;
@property (weak, nonatomic) IBOutlet FCButton *btnAddBlackList;
@property (weak, nonatomic) IBOutlet UIButton *btnRemoveDriver;


@end
