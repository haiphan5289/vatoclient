//
//  FCMCarType.h
//  FaceCar
//
//  Created by Vu Dang on 6/11/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCMCarType;

@interface FCMCarType : FCModel
@property(assign, nonatomic) NSInteger id;
@property(assign, nonatomic) BOOL choose;
@property(strong, nonatomic) NSString* name;
@end
