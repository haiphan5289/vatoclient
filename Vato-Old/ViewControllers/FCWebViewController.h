//
//  FCWebViewController.h
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCSupperViewController.h"
#import "FCWebViewModel.h"

@interface FCWebViewController : FCSupperViewController
@property (strong, nonatomic) NSString* title;
- (instancetype) initViewWithViewModel: (FCWebViewModel*) viewModel;

@end
