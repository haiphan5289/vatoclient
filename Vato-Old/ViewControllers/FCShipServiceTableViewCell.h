//
//  FCShipServiceTableViewCell.h
//  FaceCar
//
//  Created by facecar on 3/8/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCShipServiceTableViewCell : UITableViewCell

@property (strong, nonatomic) UIViewController* viewcontroller;
@property (strong, nonatomic) FCShipService* service;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end
