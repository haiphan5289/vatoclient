//
//  FCPaymentOptionViewController.h
//  FaceCar
//
//  Created by tony on 8/22/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectMethod)(PaymentMethod);
typedef PaymentMethod(^PreviousSelect)(void);
@interface FCPaymentOptionViewController : UITableViewController
@property (assign, nonatomic) PaymentMethod methodSelected;
@property (copy, nonatomic) SelectMethod callback;
@property (copy, nonatomic) PreviousSelect oldSelect;
@end
