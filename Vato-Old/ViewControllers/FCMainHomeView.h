//
//  FCMainHomeViewController.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"
#import "FCMapViewModel.h"

@interface FCMainHomeView : FCView

@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (assign, nonatomic) BOOL hideView;

- (void) hide;

@end
