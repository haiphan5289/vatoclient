//
//  FCSupperViewController.h
//  FC
//
//  Created by facecar on 5/8/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCSupperViewController : UIViewController

- (instancetype) initView;

- (void) backPressed: (id) sender;
- (void) closePressed: (id) sender;
- (BOOL) isModal;

@end
