//
//  FCGiftApplySerivce.h
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCGiftApplySerivce;
@interface FCGiftApplySerivce : FCModel

@property(assign, nonatomic) NSInteger refer_id;
@property(assign, nonatomic) NSInteger refer_type;

@end
