//
//  FCPasscodeViewController.h
//  FC
//
//  Created by facecar on 10/26/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCPasscodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblError;

@property (strong, nonatomic) NSString* currentPasscode;

@end
