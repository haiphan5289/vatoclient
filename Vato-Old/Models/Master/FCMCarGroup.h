//
//  FCMCarGroup.h
//  FaceCar
//
//  Created by Vu Dang on 6/11/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCMCarGroup;

@interface FCMCarGroup : FCModel
@property(assign, nonatomic) NSInteger id;
@property(strong, nonatomic) NSString* name;
@end
