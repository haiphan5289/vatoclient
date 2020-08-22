//
//  FCPriceAddition.h
//  FaceCar
//
//  Created by facecar on 5/21/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCPriceAddition;
@interface FCPriceAddition : FCModel
@property (assign, nonatomic) BOOL active;
@property (assign, nonatomic) NSInteger price;
@end
