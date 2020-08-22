//
//  FCRegisterStationView.h
//  FaceCar
//
//  Created by facecar on 9/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCRegisterStationView : FCView
@property (weak, nonatomic) IBOutlet UITextField *tfUserName;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet FCButton *btnContinue;
@end
